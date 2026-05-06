package com.wms.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.wms.entity.IotAlert;
import com.wms.entity.SensorData;
import com.wms.mapper.IotAlertMapper;
import com.wms.service.TdengineService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/iot")
public class IotController {

    @Autowired(required = false)
    private TdengineService tdengineService;

    @Autowired
    private IotAlertMapper alertMapper;

    /**
     * 获取最新传感器数据
     */
    @GetMapping("/sensor/latest/{deviceId}")
    public List<SensorData> getLatestData(@PathVariable String deviceId,
                                          @RequestParam(defaultValue = "100") int limit) {
        return tdengineService.getLatestData(deviceId, limit);
    }

    /**
     * 获取历史数据（用于图表）
     */
    @GetMapping("/sensor/history/{deviceId}")
    public List<SensorData> getHistoryData(@PathVariable String deviceId,
                                           @RequestParam long startTime,
                                           @RequestParam long endTime) {
        return tdengineService.getHistoryData(deviceId, startTime, endTime);
    }

    /**
     * 获取告警列表
     */
    @GetMapping("/alert/list")
    public List<IotAlert> getAlertList(@RequestParam(required = false) Integer status) {
        if (status != null) {
            return alertMapper.selectList(
                    new LambdaQueryWrapper<IotAlert>()
                            .eq(IotAlert::getStatus, status)
                            .orderByDesc(IotAlert::getCreateTime)
            );
        }
        return alertMapper.selectList(
                new LambdaQueryWrapper<IotAlert>()
                        .orderByDesc(IotAlert::getCreateTime)
        );
    }

    /**
     * 处理告警（标记为已处理）
     */
    @PostMapping("/alert/handle/{id}")
    public Map<String, Object> handleAlert(@PathVariable Long id) {
        IotAlert alert = alertMapper.selectById(id);
        alert.setStatus(1);
        alert.setHandleTime(LocalDateTime.now());
        alert.setHandler("system");
        alertMapper.updateById(alert);

        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        return result;
    }
}