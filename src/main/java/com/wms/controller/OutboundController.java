package com.wms.controller;

import com.wms.dto.OutboundRequest;
import com.wms.dto.PickingRequest;
import com.wms.dto.WaveRequest;
import com.wms.entity.OutboundOrder;
import com.wms.entity.PickingTask;
import com.wms.entity.Wave;
import com.wms.service.OutboundService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import lombok.extern.slf4j.Slf4j;

@Slf4j
@RestController
@RequestMapping("/api/outbound")
public class OutboundController {

    @Autowired
    private OutboundService outboundService;

    @PostMapping("/order")
    public Map<String, Object> createOrder(@RequestBody OutboundRequest request) {
        outboundService.createOutboundOrder(request.getOrder(), request.getDetails());
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "出库单创建成功");
        return result;
    }

    @GetMapping("/order/list")
    public List<OutboundOrder> getOrders(@RequestParam(required = false) Integer status) {
        return outboundService.getOutboundOrders(status);
    }

    @PostMapping("/wave")
    public Wave createWave(@RequestBody WaveRequest request) {
        return outboundService.createWave(request);
    }

    @GetMapping("/wave/list")
    public List<Wave> getWaves() {
        return outboundService.getWaveList();
    }

    @PostMapping("/picking-task")
    public PickingTask createPickingTask(@RequestParam Long waveId) {
        return outboundService.createPickingTask(waveId);
    }

    @GetMapping("/picking-task/list")
    public List<PickingTask> getPickingTasks() {
        return outboundService.getPickingTasks();
    }

    @PostMapping("/picking/start")
    public Map<String, Object> startPicking(@RequestBody PickingRequest request) {
        outboundService.startPicking(request.getTaskId(), request.getPickerId(), request.getPickerName());
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "开始拣货");
        return result;
    }

    @PostMapping("/picking/complete")
    public Map<String, Object> completePicking(@RequestParam Long taskId) {
        outboundService.completePicking(taskId);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "拣货完成");
        return result;
    }

    @PostMapping("/ship")
    public Map<String, Object> shipOut(@RequestParam Long orderId) {
        outboundService.shipOut(orderId);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "出库成功");
        return result;
    }
    // ========== 新增：取消订单接口 ==========
    /**
     * 取消订单（解冻库存）
     */
    @PostMapping("/order/cancel")
    public Map<String, Object> cancelOrder(@RequestParam Long orderId) {
        outboundService.cancelOrder(orderId);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "订单已取消，库存已解冻");
        return result;
    }

    /**
     * 批量取消订单
     */
    @PostMapping("/order/batch-cancel")
    public Map<String, Object> batchCancelOrder(@RequestBody List<Long> orderIds) {
        int successCount = 0;
        int failCount = 0;

        for (Long orderId : orderIds) {
            try {
                outboundService.cancelOrder(orderId);
                successCount++;
            } catch (Exception e) {
                log.error("取消订单失败: orderId={}", orderId, e);
                failCount++;
            }
        }

        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", String.format("成功取消 %d 个订单，失败 %d 个", successCount, failCount));
        result.put("successCount", successCount);
        result.put("failCount", failCount);
        return result;
    }

}