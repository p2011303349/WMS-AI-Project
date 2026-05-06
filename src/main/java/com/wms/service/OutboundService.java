package com.wms.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.wms.context.TenantContextHolder;
import com.wms.dto.InventoryFreezeRequest;
import com.wms.dto.WaveRequest;
import com.wms.entity.*;
import com.wms.mapper.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.util.*;
import java.util.stream.Collectors;
import lombok.extern.slf4j.Slf4j;
@Slf4j
@Service
public class OutboundService {

    @Autowired
    private OutboundOrderMapper outboundOrderMapper;

    @Autowired
    private OutboundDetailMapper outboundDetailMapper;

    @Autowired
    private WaveMapper waveMapper;

    @Autowired
    private PickingTaskMapper pickingTaskMapper;

    @Autowired
    private InventoryMapper inventoryMapper;

    @Autowired
    private PickingPathService pathService;

    @Autowired
    private LocationMapper locationMapper;
    @Autowired
    private InventoryManageService inventoryManageService;
    /**
     * 创建出库单
     */
    @Transactional
    public void createOutboundOrder(OutboundOrder order, List<OutboundDetail> details) {
        Long tenantId = TenantContextHolder.getTenantId();
        order.setTenantId(tenantId);
        order.setStatus(0); // 待分配
        order.setPickedQuantity(0);
        order.setTotalQuantity(details.stream().mapToInt(OutboundDetail::getQuantity).sum());
        outboundOrderMapper.insert(order);

        for (OutboundDetail detail : details) {
            detail.setTenantId(tenantId);
            detail.setOrderId(order.getId());
            detail.setPickedQuantity(0);
            outboundDetailMapper.insert(detail);
        }
    }

    @Transactional
    public Wave createWave(WaveRequest request) {
        Long tenantId = TenantContextHolder.getTenantId();

        // 创建波次
        Wave wave = new Wave();
        wave.setTenantId(tenantId);
        wave.setWaveNo("WAVE" + System.currentTimeMillis());
        wave.setWaveType(request.getWaveType());
        wave.setStatus(0); // 待拣货
        wave.setOrderCount(request.getOrderIds().size());

        // 计算总数量并更新订单
        int totalQty = 0;
        for (Long orderId : request.getOrderIds()) {
            OutboundOrder order = outboundOrderMapper.selectById(orderId);
            if (order != null && order.getStatus() == 0) {
                totalQty += order.getTotalQuantity();

                // 关键：先保存波次获取ID，再更新订单
                if (wave.getId() == null) {
                    waveMapper.insert(wave);  // 先插入波次，生成ID
                }

                order.setWaveId(wave.getId());  // 设置订单的wave_id
                order.setStatus(1); // 拣货中
                outboundOrderMapper.updateById(order);
            }
        }

        // 如果波次还没插入，现在插入
        if (wave.getId() == null) {
            waveMapper.insert(wave);
        }

        wave.setTotalQuantity(totalQty);
        waveMapper.updateById(wave);

        return wave;
    }

    /**
     * 创建拣货任务并规划路径
     */
    @Transactional
    public PickingTask createPickingTask(Long waveId) {
        Long tenantId = TenantContextHolder.getTenantId();

        log.info("========== 创建拣货任务开始 ==========");
        log.info("波次ID: {}", waveId);

        // 获取波次中的所有订单
        List<OutboundOrder> orders = outboundOrderMapper.selectList(
                new LambdaQueryWrapper<OutboundOrder>()
                        .eq(OutboundOrder::getTenantId, tenantId)
                        .eq(OutboundOrder::getWaveId, waveId)
        );

        if (orders.isEmpty()) {
            throw new RuntimeException("波次中没有订单");
        }

        log.info("波次中共有 {} 个订单", orders.size());

        Set<String> locationCodes = new HashSet<>();
        List<InventoryFreezeRequest> freezeRequests = new ArrayList<>();

        for (OutboundOrder order : orders) {
            // 获取订单明细
            List<OutboundDetail> details = outboundDetailMapper.selectList(
                    new LambdaQueryWrapper<OutboundDetail>()
                            .eq(OutboundDetail::getOrderId, order.getId())
            );

            log.info("订单 {} 共有 {} 个商品", order.getOrderNo(), details.size());

            for (OutboundDetail detail : details) {
                // 查找库存（按先进先出排序）
                List<Inventory> inventories = inventoryMapper.selectList(
                        new LambdaQueryWrapper<Inventory>()
                                .eq(Inventory::getTenantId, tenantId)
                                .eq(Inventory::getSkuCode, detail.getSkuCode())
                                .gt(Inventory::getQuantity, 0)
                                .orderByAsc(Inventory::getExpiryDate) // 先进先出
                );

                if (inventories.isEmpty()) {
                    throw new RuntimeException("商品 " + detail.getSkuCode() + " 库存不足");
                }

                int needQty = detail.getQuantity();
                log.info("商品 {} 需要数量: {}", detail.getSkuCode(), needQty);

                for (Inventory inv : inventories) {
                    if (needQty <= 0) break;

                    int availableQty = inv.getQuantity() - inv.getLockedQuantity();
                    int lockQty = Math.min(needQty, availableQty);

                    if (lockQty > 0) {
                        // 使用库存冻结服务
                        InventoryFreezeRequest freezeRequest = new InventoryFreezeRequest();
                        freezeRequest.setInventoryId(inv.getId());
                        freezeRequest.setSkuCode(inv.getSkuCode());
                        freezeRequest.setQuantity(lockQty);
                        freezeRequest.setOrderNo(order.getOrderNo());
                        freezeRequest.setReason("出库锁定 - 波次:" + waveId);

                        try {
                            inventoryManageService.freezeInventory(freezeRequest);
                            freezeRequests.add(freezeRequest);
                            log.info("冻结库存成功: inventoryId={}, sku={}, quantity={}",
                                    inv.getId(), inv.getSkuCode(), lockQty);
                        } catch (Exception e) {
                            log.error("冻结库存失败", e);
                            throw new RuntimeException("冻结库存失败: " + e.getMessage());
                        }

                        needQty -= lockQty;

                        // 记录货位（用于路径规划）
                        Location loc = locationMapper.selectById(inv.getLocationId());
                        if (loc != null) {
                            locationCodes.add(loc.getLocationCode());
                            log.debug("添加货位: {}", loc.getLocationCode());
                        }
                    }
                }

                if (needQty > 0) {
                    throw new RuntimeException("商品 " + detail.getSkuCode() + " 库存不足，缺少 " + needQty);
                }
            }
        }

        // 智能路径规划
        List<String> optimizedPath = pathService.optimizePickingPath(
                new ArrayList<>(locationCodes)
        );

        log.info("路径规划完成: {}", String.join(" → ", optimizedPath));

        // 创建拣货任务
        PickingTask task = new PickingTask();
        task.setTenantId(tenantId);
        task.setWaveId(waveId);
        task.setStatus(0);
        task.setRoutePath(String.join(" → ", optimizedPath));
        pickingTaskMapper.insert(task);

        log.info("拣货任务创建成功: taskId={}, 路径长度={}", task.getId(), optimizedPath.size());
        log.info("========== 创建拣货任务结束 ==========");

        return task;
    }

    /**
     * 开始拣货
     */
    @Transactional
    public void startPicking(Long taskId, Long pickerId, String pickerName) {
        PickingTask task = pickingTaskMapper.selectById(taskId);
        task.setPickerId(pickerId);
        task.setPickerName(pickerName);
        task.setStatus(1);
        task.setStartTime(LocalDateTime.now());
        pickingTaskMapper.updateById(task);
    }

    /**
     * 完成拣货
     */
    @Transactional(rollbackFor = Exception.class)
    public void completePicking(Long taskId) {
        log.info("========== 开始完成拣货 ==========");
        log.info("拣货任务ID: {}", taskId);

        // 1. 查询拣货任务
        PickingTask task = pickingTaskMapper.selectById(taskId);
        if (task == null) {
            log.error("拣货任务不存在: taskId={}", taskId);
            throw new RuntimeException("拣货任务不存在");
        }
        log.info("拣货任务信息: waveId={}, status={}", task.getWaveId(), task.getStatus());

        // 2. 查询波次
        Wave wave = waveMapper.selectById(task.getWaveId());
        if (wave == null) {
            log.error("波次不存在: waveId={}", task.getWaveId());
            throw new RuntimeException("波次不存在");
        }
        log.info("波次信息: waveNo={}, status={}", wave.getWaveNo(), wave.getStatus());

        // 3. 更新波次状态
        wave.setStatus(2);
        int waveUpdateCount = waveMapper.updateById(wave);
        log.info("波次更新结果: 影响{}行", waveUpdateCount);

        // 4. 查询订单 - 关键调试信息
        log.info("查询条件: waveId = {}", wave.getId());
        List<OutboundOrder> orders = outboundOrderMapper.selectList(
                new LambdaQueryWrapper<OutboundOrder>()
                        .eq(OutboundOrder::getWaveId, wave.getId())
        );

        log.info("查询到的订单数量: {}", orders.size());

        // 如果查不到订单，尝试查询所有订单查看 wave_id
        if (orders.isEmpty()) {
            log.warn("没有找到 wave_id = {} 的订单，查询所有订单检查", wave.getId());
            List<OutboundOrder> allOrders = outboundOrderMapper.selectList(null);
            for (OutboundOrder o : allOrders) {
                log.warn("订单: id={}, orderNo={}, waveId={}, status={}",
                        o.getId(), o.getOrderNo(), o.getWaveId(), o.getStatus());
            }
        }

        // 5. 更新订单状态
        for (OutboundOrder order : orders) {
            log.info("准备更新订单: id={}, orderNo={}, 原status={}",
                    order.getId(), order.getOrderNo(), order.getStatus());
            order.setStatus(2);
            int updateResult = outboundOrderMapper.updateById(order);
            log.info("订单更新结果: 影响{}行", updateResult);
        }

        // 6. 更新拣货任务
        task.setStatus(2);
        task.setEndTime(LocalDateTime.now());
        int taskUpdateCount = pickingTaskMapper.updateById(task);
        log.info("拣货任务更新结果: 影响{}行", taskUpdateCount);

        log.info("========== 完成拣货成功 ==========");
    }
    /**
     * 出库（发货）- 使用新的库存扣减服务
     */
    @Transactional
    public void shipOut(Long orderId) {
        OutboundOrder order = outboundOrderMapper.selectById(orderId);
        if (order == null) {
            throw new RuntimeException("订单不存在");
        }

        log.info("开始发货，订单号: {}, 订单ID: {}", order.getOrderNo(), orderId);

        // 查询订单明细
        List<OutboundDetail> details = outboundDetailMapper.selectList(
                new LambdaQueryWrapper<OutboundDetail>()
                        .eq(OutboundDetail::getOrderId, orderId)
        );

        for (OutboundDetail detail : details) {
            // 使用库存扣减服务
            // 需要根据订单号和SKU找到对应的冻结记录，然后扣减
            List<InventoryFreezeLog> freezeLogs = inventoryManageService.getFreezeLogs(order.getOrderNo());

            int needDeduct = detail.getQuantity();
            for (InventoryFreezeLog freezeLog : freezeLogs) {
                if (needDeduct <= 0) break;

                if (freezeLog.getStatus() == 0 && freezeLog.getSkuCode().equals(detail.getSkuCode())) {
                    int deductQty = Math.min(needDeduct, freezeLog.getQuantity());

                    // 扣减库存
                    inventoryManageService.deductInventory(
                            freezeLog.getInventoryId(),
                            deductQty,
                            order.getOrderNo()
                    );

                    needDeduct -= deductQty;
                    log.info("扣减库存: inventoryId={}, sku={}, quantity={}",
                            freezeLog.getInventoryId(), detail.getSkuCode(), deductQty);
                }
            }

            if (needDeduct > 0) {
                log.warn("商品 {} 扣减数量不足，剩余: {}", detail.getSkuCode(), needDeduct);
            }
        }

        // 更新订单状态
        order.setStatus(4); // 已出库
        outboundOrderMapper.updateById(order);

        log.info("发货完成，订单号: {}", order.getOrderNo());
    }

    /**
     * 查询出库单列表
     */
    public List<OutboundOrder> getOutboundOrders(Integer status) {
        Long tenantId = TenantContextHolder.getTenantId();
        LambdaQueryWrapper<OutboundOrder> wrapper = new LambdaQueryWrapper<OutboundOrder>()
                .eq(OutboundOrder::getTenantId, tenantId);
        if (status != null) {
            wrapper.eq(OutboundOrder::getStatus, status);
        }
        return outboundOrderMapper.selectList(wrapper.orderByDesc(OutboundOrder::getCreateTime));
    }

    /**
     * 查询波次列表
     */
    public List<Wave> getWaveList() {
        Long tenantId = TenantContextHolder.getTenantId();
        return waveMapper.selectList(
                new LambdaQueryWrapper<Wave>()
                        .eq(Wave::getTenantId, tenantId)
                        .orderByDesc(Wave::getCreateTime)
        );
    }

    /**
     * 查询拣货任务列表
     */
    public List<PickingTask> getPickingTasks() {
        Long tenantId = TenantContextHolder.getTenantId();
        return pickingTaskMapper.selectList(
                new LambdaQueryWrapper<PickingTask>()
                        .eq(PickingTask::getTenantId, tenantId)
                        .orderByDesc(PickingTask::getCreateTime)
        );
    }
    /**
     * 取消订单（解冻库存）
     */
    @Transactional
    public void cancelOrder(Long orderId) {
        OutboundOrder order = outboundOrderMapper.selectById(orderId);
        if (order == null) {
            throw new RuntimeException("订单不存在");
        }

        // 只有待分配(0)或拣货中(1)的订单可以取消
        if (order.getStatus() != 0 && order.getStatus() != 1) {
            throw new RuntimeException("订单状态不允许取消，当前状态：" + order.getStatus());
        }

        log.info("取消订单，订单号: {}, 订单ID: {}", order.getOrderNo(), orderId);

        // 查询该订单的所有冻结记录
        List<InventoryFreezeLog> freezeLogs = inventoryManageService.getFreezeLogs(order.getOrderNo());

        int unfrozenCount = 0;
        for (InventoryFreezeLog freezeLog : freezeLogs) {
            if (freezeLog.getStatus() == 0) {
                // 解冻库存
                inventoryManageService.unfreezeInventory(freezeLog.getId());
                unfrozenCount++;
                log.info("解冻库存: freezeLogId={}, inventoryId={}, quantity={}",
                        freezeLog.getId(), freezeLog.getInventoryId(), freezeLog.getQuantity());
            }
        }

        // 更新订单状态
        order.setStatus(5); // 已取消
        outboundOrderMapper.updateById(order);

        log.info("订单取消完成，订单号: {}, 解冻记录数: {}", order.getOrderNo(), unfrozenCount);
    }
}