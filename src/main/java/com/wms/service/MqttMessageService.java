package com.wms.service;

import com.alibaba.fastjson.JSONObject;
import com.wms.entity.SensorData;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.integration.annotation.ServiceActivator;
import org.springframework.messaging.handler.annotation.Header;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.stereotype.Service;
import java.sql.Timestamp;

@Service
public class MqttMessageService {

    @Autowired
    private TdengineService tdengineService;

    @Autowired
    private AlertRuleEngine alertRuleEngine;

    @Autowired
    private WebSocketService webSocketService;

    @ServiceActivator(inputChannel = "mqttInputChannel")
    public void handleMessage(@Payload String payload,
                              @Header("mqtt_receivedTopic") String topic) {
        System.out.println("收到MQTT消息 - Topic: " + topic + ", Payload: " + payload);

        try {
            // 解析设备ID
            String deviceId = extractDeviceId(topic);

            // 解析传感器数据
            JSONObject data = JSONObject.parseObject(payload);
            float temperature = data.getFloatValue("temperature");
            float humidity = data.getFloatValue("humidity");
            float battery = data.getFloatValue("battery");

            // 存储到时序数据库
            SensorData sensorData = new SensorData();
            sensorData.setTs(new Timestamp(System.currentTimeMillis()));
            sensorData.setTemperature(temperature);
            sensorData.setHumidity(humidity);
            sensorData.setBattery(battery);
            sensorData.setDeviceId(deviceId);
            sensorData.setLocation(getLocationByDeviceId(deviceId));
            sensorData.setTenantId("1");

            // 创建子表（如果不存在）
            tdengineService.createSubTable(deviceId, sensorData.getLocation(), sensorData.getTenantId());

            // 插入数据
            tdengineService.insertSensorData(sensorData);

            // 告警规则判断
            alertRuleEngine.processSensorData(deviceId, temperature, humidity);

            // WebSocket推送实时数据
            webSocketService.pushSensorData(deviceId, temperature, humidity, battery);

        } catch (Exception e) {
            System.err.println("处理MQTT消息失败: " + e.getMessage());
            e.printStackTrace();
        }
    }

    private String extractDeviceId(String topic) {
        // topic格式: /warehouse/{deviceId}/sensor
        String[] parts = topic.split("/");
        if (parts.length >= 3) {
            return parts[2];
        }
        return "unknown";
    }

    private String getLocationByDeviceId(String deviceId) {
        // 根据设备ID获取位置，可以从配置或数据库读取
        return "A区-01货架";
    }
}