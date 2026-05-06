package com.wms.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;
import java.util.HashMap;
import java.util.Map;

@Service
public class WebSocketService {

    @Autowired
    private SimpMessagingTemplate messagingTemplate;

    /**
     * 推送传感器数据
     */
    public void pushSensorData(String deviceId, float temperature, float humidity, float battery) {
        Map<String, Object> data = new HashMap<>();
        data.put("deviceId", deviceId);
        data.put("temperature", temperature);
        data.put("humidity", humidity);
        data.put("battery", battery);
        data.put("timestamp", System.currentTimeMillis());

        messagingTemplate.convertAndSend("/topic/sensor/" + deviceId, data);
        messagingTemplate.convertAndSend("/topic/sensor/all", data);
    }

    /**
     * 推送告警信息
     */
    public void pushAlert(Map<String, Object> alert) {
        messagingTemplate.convertAndSend("/topic/alert", alert);
    }

    /**
     * 推送历史数据
     */
    public void pushHistoryData(String deviceId, Object historyData) {
        messagingTemplate.convertAndSend("/topic/history/" + deviceId, historyData);
    }
}