package com.wms.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.wms.context.TenantContextHolder;
import com.wms.dto.TaskDTO;
import com.wms.entity.*;
import com.wms.mapper.*;
import dev.langchain4j.agent.tool.P;
import dev.langchain4j.agent.tool.Tool;
import dev.langchain4j.model.chat.ChatLanguageModel;
import dev.langchain4j.model.openai.OpenAiChatModel;
import dev.langchain4j.service.AiServices;
import org.camunda.bpm.engine.task.Task;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import jakarta.annotation.PostConstruct;
import java.time.LocalDateTime;
import java.util.List;

@Service
public class AiAgentService {

    @Value("${deepseek.api.key:}")
    private String apiKey;

    @Autowired
    private InventoryMapper inventoryMapper;

    @Autowired
    private ReplenishmentOrderMapper replenishmentOrderMapper;

    @Autowired
    private OutboundExceptionMapper outboundExceptionMapper;

    @Autowired
    private OutboundOrderMapper outboundOrderMapper;
    @Autowired
    private OutboundDetailMapper outboundDetailMapper;
    @Autowired
    private WorkflowService workflowService;  // 注入工作流服务

    private ChatLanguageModel chatModel;
    private WarehouseAgent agent;
    private boolean available = false;

    interface WarehouseAgent {
        String chat(String message);
    }

    /**
     * 库存工具类（AI 可调用）
     */
    class InventoryTools {

        @Tool("查询指定商品的库存数量")
        public String queryInventory(@P("商品编码") String skuCode) {
            var inventories = inventoryMapper.selectList(null);
            int total = inventories.stream()
                    .filter(i -> i.getSkuCode().equalsIgnoreCase(skuCode))
                    .mapToInt(i -> i.getQuantity() - i.getLockedQuantity())
                    .sum();
            return String.format("商品 %s 当前可用库存为 %d 件", skuCode, total);
        }

        @Tool("获取所有低库存商品列表")
        public String getLowStockItems() {
            var inventories = inventoryMapper.selectList(null);
            var lowStock = inventories.stream()
                    .filter(i -> i.getQuantity() - i.getLockedQuantity() < 10)
                    .toList();

            if (lowStock.isEmpty()) {
                return "当前没有低库存商品";
            }

            StringBuilder sb = new StringBuilder("低库存商品列表：\n");
            for (Inventory inv : lowStock) {
                sb.append(String.format("- %s: %d件 (当前库存 %d, 已锁定 %d)\n",
                        inv.getSkuCode(),
                        inv.getQuantity() - inv.getLockedQuantity(),
                        inv.getQuantity(),
                        inv.getLockedQuantity()));
            }
            return sb.toString();
        }
    }

    /**
     * 补货工具类
     */
    class ReplenishmentTools {

        @Tool("为商品生成补货建议单")
        public String createReplenishmentSuggestion(@P("需要补货的商品编码") String skuCode) {
            var inventories = inventoryMapper.selectList(null);
            var inv = inventories.stream()
                    .filter(i -> i.getSkuCode().equalsIgnoreCase(skuCode))
                    .findFirst();

            if (inv.isEmpty()) {
                return "商品 " + skuCode + " 不存在";
            }

            int currentStock = inv.get().getQuantity() - inv.get().getLockedQuantity();
            int suggestQuantity = Math.max(0, 20 - currentStock);

            if (suggestQuantity <= 0) {
                return String.format("商品 %s 库存充足（%d件），无需补货", skuCode, currentStock);
            }

            // 生成补货建议单
            ReplenishmentOrder order = new ReplenishmentOrder();
            order.setTenantId(1L);
            order.setOrderNo("REP" + System.currentTimeMillis());
            order.setSkuCode(skuCode);
            order.setSkuName(inv.get().getSkuName());
            order.setCurrentStock(currentStock);
            order.setSuggestQuantity(suggestQuantity);
            order.setReason("低于安全库存阈值（10件）");
            order.setStatus(0); // 待审核
            replenishmentOrderMapper.insert(order);

            return String.format("已生成补货建议单 %s：建议为商品 %s 补货 %d 件，当前库存 %d 件。请前往补货管理页面审核。",
                    order.getOrderNo(), skuCode, suggestQuantity, currentStock);
        }

        @Tool("获取所有待审核的补货建议单")
        public String getPendingReplenishmentOrders() {
            var orders = replenishmentOrderMapper.selectList(
                    new LambdaQueryWrapper<ReplenishmentOrder>()
                            .eq(ReplenishmentOrder::getStatus, 0)
            );

            if (orders.isEmpty()) {
                return "当前没有待审核的补货建议单";
            }

            StringBuilder sb = new StringBuilder("待审核补货建议单：\n");
            for (ReplenishmentOrder order : orders) {
                sb.append(String.format("- %s: %s 建议补货 %d件 (当前库存 %d件)\n",
                        order.getOrderNo(), order.getSkuCode(),
                        order.getSuggestQuantity(), order.getCurrentStock()));
            }
            return sb.toString();
        }
    }

    /**
     * 异常处理工具类
     */
    class ExceptionTools {

        @Tool("记录出库异常")
        public String recordOutboundException(
                @P("出库单号") String orderNo,
                @P("异常类型，如 INSUFFICIENT_STOCK, ADDRESS_ERROR") String exceptionType,
                @P("异常详情描述") String detail) {

            var orders = outboundOrderMapper.selectList(
                    new LambdaQueryWrapper<OutboundOrder>()
                            .eq(OutboundOrder::getOrderNo, orderNo)
            );

            if (orders.isEmpty()) {
                return "订单 " + orderNo + " 不存在";
            }

            OutboundOrder order = orders.get(0);

            OutboundException exception = new OutboundException();
            exception.setTenantId(1L);
            exception.setOrderId(order.getId());
            exception.setOrderNo(orderNo);
            exception.setExceptionType(exceptionType);
            exception.setExceptionDetail(detail);
            exception.setStatus(0); // 待处理
            outboundExceptionMapper.insert(exception);

            return String.format("已记录异常，异常ID: %d，请及时处理", exception.getId());
        }

        @Tool("获取待处理的异常列表")
        public String getPendingExceptions() {
            var exceptions = outboundExceptionMapper.selectList(
                    new LambdaQueryWrapper<OutboundException>()
                            .eq(OutboundException::getStatus, 0)
            );

            if (exceptions.isEmpty()) {
                return "当前没有待处理的异常";
            }

            StringBuilder sb = new StringBuilder("待处理异常列表：\n");
            for (OutboundException ex : exceptions) {
                sb.append(String.format("- [%s] 订单 %s: %s\n",
                        ex.getExceptionType(), ex.getOrderNo(), ex.getExceptionDetail()));
            }
            return sb.toString();
        }

        @Tool("生成异常处理建议（AI分析）")
        public String generateExceptionSuggestion(@P("异常ID") Long exceptionId) {
            OutboundException exception = outboundExceptionMapper.selectById(exceptionId);
            if (exception == null) {
                return "异常记录不存在";
            }

            String suggestion;
            switch (exception.getExceptionType()) {
                case "INSUFFICIENT_STOCK":
                    suggestion = "库存不足，建议：1. 联系采购部门紧急补货 2. 联系客户协商部分发货 3. 等待补货后发货";
                    break;
                case "ADDRESS_ERROR":
                    suggestion = "地址错误，建议：1. 联系客户确认正确地址 2. 在系统中更新订单地址";
                    break;
                default:
                    suggestion = "请人工核实异常原因，联系相关部门处理";
            }

            exception.setSuggestion(suggestion);
            outboundExceptionMapper.updateById(exception);

            return "异常处理建议已生成：\n" + suggestion;
        }
    }

    @PostConstruct
    public void init() {
        if (apiKey == null || apiKey.isEmpty()) {
            System.err.println("DeepSeek API Key 未配置");
            return;
        }

        try {
            chatModel = OpenAiChatModel.builder()
                    .apiKey(apiKey)
                    .baseUrl("https://api.deepseek.com/v1")
                    .modelName("deepseek-chat")
                    .temperature(0.5)
                    .build();

            agent = AiServices.builder(WarehouseAgent.class)
                    .chatLanguageModel(chatModel)
                    .tools(new InventoryTools(), new ReplenishmentTools(), new ExceptionTools())
                    .build();

            available = true;
            System.out.println("AI Agent 初始化完成，已注册库存、补货、异常处理工具");
        } catch (Exception e) {
            System.err.println("AI Agent 初始化失败: " + e.getMessage());
            available = false;
        }
    }





    // ==================== AI 对话 ====================

    public String chat(String message) {
        if (!available || agent == null) {
            return "AI Agent 服务暂时不可用";
        }
        try {
            return agent.chat(message);
        } catch (Exception e) {
            return "处理失败: " + e.getMessage();
        }
    }
    // ==================== 补货管理方法 ====================

    /**
     * 获取补货建议列表
     */
    public List<ReplenishmentOrder> getReplenishmentList(Integer status) {
        Long tenantId = TenantContextHolder.getTenantId();
        LambdaQueryWrapper<ReplenishmentOrder> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ReplenishmentOrder::getTenantId, tenantId);
        if (status != null) {
            wrapper.eq(ReplenishmentOrder::getStatus, status);
        }
        wrapper.orderByDesc(ReplenishmentOrder::getCreateTime);
        return replenishmentOrderMapper.selectList(wrapper);
    }

    /**
     * 智能补货扫描 - 自动生成补货建议单
     */
    @Transactional
    public int autoReplenishment() {
        System.out.println("=== 智能补货 Agent 开始扫描 ===");

        Long tenantId = TenantContextHolder.getTenantId();
        var inventories = inventoryMapper.selectList(
                new LambdaQueryWrapper<Inventory>()
                        .eq(Inventory::getTenantId, tenantId)
        );

        int generatedCount = 0;

        for (Inventory inv : inventories) {
            int available = inv.getQuantity() - inv.getLockedQuantity();
            if (available < 10) {
                // 检查是否已有待审核的补货建议
                long existingCount = replenishmentOrderMapper.selectCount(
                        new LambdaQueryWrapper<ReplenishmentOrder>()
                                .eq(ReplenishmentOrder::getSkuCode, inv.getSkuCode())
                                .eq(ReplenishmentOrder::getStatus, 0)
                                .eq(ReplenishmentOrder::getTenantId, tenantId)
                );

                if (existingCount == 0) {
                    ReplenishmentOrder order = new ReplenishmentOrder();
                    order.setTenantId(tenantId);
                    order.setOrderNo("REP" + System.currentTimeMillis() + generatedCount);
                    order.setSkuCode(inv.getSkuCode());
                    order.setSkuName(inv.getSkuName());
                    order.setCurrentStock(available);
                    order.setSuggestQuantity(20 - available);
                    order.setReason("智能补货Agent扫描发现库存低于安全阈值（10件）");
                    order.setStatus(0); // 待审核
                    replenishmentOrderMapper.insert(order);

                    // ========== 新增：启动工作流 ==========
                    try {
                        String processInstanceId = workflowService.startReplenishmentApproval(
                                order.getId(),
                                "system"
                        );
                        order.setProcessInstanceId(processInstanceId);
                        replenishmentOrderMapper.updateById(order);
                        System.out.println("启动工作流: " + processInstanceId);
                    } catch (Exception e) {
                        System.err.println("启动工作流失败: " + e.getMessage());
                    }
                    // ==================================
                    System.out.println("生成补货建议单: " + order.getOrderNo() + " - " + inv.getSkuCode());
                    generatedCount++;
                }
            }
        }

        System.out.println("智能补货 Agent 扫描完成，共生成 " + generatedCount + " 条补货建议");
        return generatedCount;
    }

    /**
     * 审核补货建议
     */
    @Transactional
    public String approveReplenishment(Long orderId, boolean approved, String comment) {
        ReplenishmentOrder order = replenishmentOrderMapper.selectById(orderId);
        if (order == null) {
            return "补货建议单不存在";
        }

        if (approved) {
            order.setStatus(1); // 已审核
            System.out.println("补货建议已审核通过: " + order.getOrderNo());
        } else {
            order.setStatus(2); // 已驳回
            System.out.println("补货建议已驳回: " + order.getOrderNo());
        }

        order.setAuditTime(LocalDateTime.now());
        order.setAuditor(getCurrentUser());
        replenishmentOrderMapper.updateById(order);

        return approved ? "补货建议已审核通过" : "补货建议已驳回";
    }

// ==================== 异常管理方法 ====================

    /**
     * 获取异常列表
     */
    public List<OutboundException> getExceptionList(Integer status) {
        Long tenantId = TenantContextHolder.getTenantId();
        LambdaQueryWrapper<OutboundException> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(OutboundException::getTenantId, tenantId);
        if (status != null) {
            wrapper.eq(OutboundException::getStatus, status);
        }
        wrapper.orderByDesc(OutboundException::getCreateTime);
        return outboundExceptionMapper.selectList(wrapper);
    }

    /**
     * 扫描异常出库订单
     */
    @Transactional
    public int scanOutboundExceptions() {
        System.out.println("=== 异常出库 Agent 开始扫描 ===");

        Long tenantId = TenantContextHolder.getTenantId();
        int exceptionCount = 0;

        // 扫描待处理的出库订单
        var orders = outboundOrderMapper.selectList(
                new LambdaQueryWrapper<OutboundOrder>()
                        .eq(OutboundOrder::getTenantId, tenantId)
                        .eq(OutboundOrder::getStatus, 1) // 拣货中状态
        );

        for (OutboundOrder order : orders) {
            // 获取订单明细
            var details = outboundDetailMapper.selectList(
                    new LambdaQueryWrapper<OutboundDetail>()
                            .eq(OutboundDetail::getOrderId, order.getId())
            );

            for (var detail : details) {
                // 检查库存是否充足
                var inventories = inventoryMapper.selectList(
                        new LambdaQueryWrapper<Inventory>()
                                .eq(Inventory::getTenantId, tenantId)
                                .eq(Inventory::getSkuCode, detail.getSkuCode())
                );

                int totalAvailable = inventories.stream()
                        .mapToInt(i -> i.getQuantity() - i.getLockedQuantity())
                        .sum();

                if (totalAvailable < detail.getQuantity()) {
                    // 检查是否已存在未处理的异常
                    long existingCount = outboundExceptionMapper.selectCount(
                            new LambdaQueryWrapper<OutboundException>()
                                    .eq(OutboundException::getOrderId, order.getId())
                                    .eq(OutboundException::getExceptionType, "INSUFFICIENT_STOCK")
                                    .in(OutboundException::getStatus, 0, 1)
                    );

                    if (existingCount == 0) {
                        OutboundException exception = new OutboundException();
                        exception.setTenantId(tenantId);
                        exception.setOrderId(order.getId());
                        exception.setOrderNo(order.getOrderNo());
                        exception.setExceptionType("INSUFFICIENT_STOCK");
                        exception.setExceptionDetail(String.format("商品 %s 库存不足，需要 %d 件，可用库存 %d 件",
                                detail.getSkuCode(), detail.getQuantity(), totalAvailable));
                        exception.setStatus(0); // 待处理
                        outboundExceptionMapper.insert(exception);
                        exceptionCount++;

                        System.out.println("发现异常: 订单 " + order.getOrderNo() + " - " + detail.getSkuCode() + " 库存不足");
                    }
                }
            }
        }

        System.out.println("异常出库 Agent 扫描完成，发现 " + exceptionCount + " 条异常");
        return exceptionCount;
    }

    /**
     * 生成异常处理建议（AI分析）
     */
    @Transactional
    public String generateExceptionSuggestion(Long exceptionId) {
        OutboundException exception = outboundExceptionMapper.selectById(exceptionId);
        if (exception == null) {
            return "异常记录不存在";
        }

        String suggestion;
        switch (exception.getExceptionType()) {
            case "INSUFFICIENT_STOCK":
                suggestion = "库存不足，建议：\n1. 联系采购部门紧急补货\n2. 联系客户协商部分发货\n3. 等待补货后发货\n4. 如急需，可考虑调拨其他仓库库存";
                break;
            case "ADDRESS_ERROR":
                suggestion = "地址错误，建议：\n1. 联系客户确认正确地址\n2. 在系统中更新订单地址\n3. 如联系不上，暂停发货并标记";
                break;
            default:
                suggestion = "请人工核实异常原因，联系相关部门处理";
        }

        exception.setSuggestion(suggestion);
        outboundExceptionMapper.updateById(exception);

        return "异常处理建议已生成：\n" + suggestion;
    }

    /**
     * 处理异常
     */
    @Transactional
    public String handleException(Long exceptionId, String remark) {
        OutboundException exception = outboundExceptionMapper.selectById(exceptionId);
        if (exception == null) {
            return "异常记录不存在";
        }

        exception.setStatus(2); // 已处理
        exception.setHandler(getCurrentUser());
        exception.setHandleTime(LocalDateTime.now());
        outboundExceptionMapper.updateById(exception);

        return "异常已处理完成";
    }

    /**
     * 获取当前用户
     */
    private String getCurrentUser() {
        try {
            Long tenantId = TenantContextHolder.getTenantId();
            return "user_" + tenantId;
        } catch (Exception e) {
            return "system";
        }
    }
    /**
     * 创建补货建议单（自动启动工作流）
     */
    @Transactional
    public String createReplenishmentOrderWithWorkflow(String skuCode) {
        // 1. 创建补货建议单
        ReplenishmentOrder order = new ReplenishmentOrder();
        order.setOrderNo("REP" + System.currentTimeMillis());
        order.setSkuCode(skuCode);
        order.setCurrentStock(5);
        order.setSuggestQuantity(15);
        order.setStatus(0); // 待审核
        replenishmentOrderMapper.insert(order);

        // 2. 启动工作流审批流程
        String processInstanceId = workflowService.startReplenishmentApproval(
                order.getId(),
                "system"
        );

        // 3. 关联工作流ID
        order.setProcessInstanceId(processInstanceId);
        replenishmentOrderMapper.updateById(order);

        return "补货建议单已创建，等待主管审批，流程ID: " + processInstanceId;
    }

    /**
     * 审核补货建议（通过工作流）
     * @param orderId 补货建议单ID
     * @param approved 是否通过
     * @param comment 审批意见
     * @param approver 审批人用户名
     * @return 审批结果
     */
    @Transactional
    public String approveByWorkflow(Long orderId, boolean approved, String comment, String approver) {
        ReplenishmentOrder order = replenishmentOrderMapper.selectById(orderId);
        if (order == null) {
            return "补货建议单不存在";
        }

        // 获取当前用户的待办任务（使用 DTO）
        List<TaskDTO> tasks = workflowService.getTasksByAssignee(approver);

        for (TaskDTO task : tasks) {
            // 判断任务是否属于这个补货单（从流程变量中获取 orderId）
            Object variable = workflowService.getProcessVariable(
                    task.getProcessInstanceId(), "orderId");

            Long taskOrderId = null;
            if (variable instanceof Long) {
                taskOrderId = (Long) variable;
            } else if (variable instanceof Number) {
                taskOrderId = ((Number) variable).longValue();
            }

            if (taskOrderId != null && taskOrderId.equals(orderId)) {
                // 完成任务审批
                workflowService.completeTask(task.getId(), approved, comment);

                // 更新补货单状态
                if (approved) {
                    order.setStatus(1); // 已审核
                } else {
                    order.setStatus(2); // 已驳回
                }
                order.setAuditTime(LocalDateTime.now());
                order.setAuditor(approver);
                order.setAuditComment(comment);
                replenishmentOrderMapper.updateById(order);

                return approved ? "审批通过" : "审批驳回";
            }
        }

        return "未找到待审批任务，请确认您有待审批的补货申请";
    }
}