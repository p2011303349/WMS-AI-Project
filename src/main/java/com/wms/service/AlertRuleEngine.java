package com.wms.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.wms.entity.IotAlert;
import com.wms.mapper.IotAlertMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import java.time.LocalDateTime;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class AlertRuleEngine {

    @Autowired
    private IotAlertMapper alertMapper;

    @Autowired
    private NotificationService notificationService;

    // 记录连续超阈值次数
    private Map<String, Integer> consecutiveExceedCount = new ConcurrentHashMap<>();

    // 温度阈值
    @Value("${iot.alert.temp.max:30}")
    private double maxTemp;

    @Value("${iot.alert.temp.min:0}")
    private double minTemp;

    @Value("${iot.alert.humidity.max:80}")
    private double maxHumidity;

    @Value("${iot.alert.humidity.min:30}")
    private double minHumidity;

    // 连续告警次数阈值
    @Value("${iot.alert.consecutive.count:3}")
    private int consecutiveCount;

    /**
     * 处理传感器数据，触发告警
     */
    public void processSensorData(String deviceId, double temperature, double humidity) {
        String key = deviceId;

        // 检查温度告警
        checkTemperatureAlert(deviceId, temperature, key);

        // 检查湿度告警
        checkHumidityAlert(deviceId, humidity, key);

        // 重置连续计数（如果都正常）
        if (isNormal(temperature, humidity)) {
            consecutiveExceedCount.put(key, 0);
        }
    }

    private void checkTemperatureAlert(String deviceId, double temperature, String key) {
        String alertType = null;
        String alertMessage = null;

        if (temperature > maxTemp) {
            alertType = "HIGH_TEMP";
            alertMessage = String.format("温度过高告警：当前温度 %.1f℃ > 阈值 %.1f℃", temperature, maxTemp);
        } else if (temperature < minTemp) {
            alertType = "LOW_TEMP";
            alertMessage = String.format("温度过低告警：当前温度 %.1f℃ < 阈值 %.1f℃", temperature, minTemp);
        }

        if (alertType != null) {
            handleAlert(deviceId, "temp", alertType, temperature, alertMessage, key);
        }
    }

    private void checkHumidityAlert(String deviceId, double humidity, String key) {
        String alertType = null;
        String alertMessage = null;

        if (humidity > maxHumidity) {
            alertType = "HIGH_HUMIDITY";
            alertMessage = String.format("湿度过高告警：当前湿度 %.1f%% > 阈值 %.1f%%", humidity, maxHumidity);
        } else if (humidity < minHumidity) {
            alertType = "LOW_HUMIDITY";
            alertMessage = String.format("湿度过低告警：当前湿度 %.1f%% < 阈值 %.1f%%", humidity, minHumidity);
        }

        if (alertType != null) {
            handleAlert(deviceId, "humidity", alertType, humidity, alertMessage, key);
        }
    }

    private void handleAlert(String deviceId, String deviceType, String alertType,
                             double value, String message, String key) {
        // 更新连续告警计数
        int count = consecutiveExceedCount.getOrDefault(key, 0) + 1;
        consecutiveExceedCount.put(key, count);

        // 只有连续超过阈值才发送告警
        if (count >= consecutiveCount) {
            // 检查是否已存在未处理的告警
            if (!hasActiveAlert(deviceId, alertType)) {
                // 保存告警记录
                IotAlert alert = new IotAlert();
                alert.setTenantId(1L);
                alert.setDeviceId(deviceId);
                alert.setDeviceType(deviceType);
                alert.setAlertType(alertType);
                alert.setAlertValue(value);
                alert.setThresholdValue(getThreshold(alertType));
                alert.setAlertMessage(message);
                alert.setStatus(0);
                alert.setCreateTime(LocalDateTime.now());
                alertMapper.insert(alert);

                // 发送通知
                notificationService.sendAlert(message, alertType);

                // 通过WebSocket推送告警
                pushAlertToWebSocket(alert);
            }
        }
    }

    private boolean hasActiveAlert(String deviceId, String alertType) {
        Long count = alertMapper.selectCount(
                new LambdaQueryWrapper<IotAlert>()
                        .eq(IotAlert::getDeviceId, deviceId)
                        .eq(IotAlert::getAlertType, alertType)
                        .eq(IotAlert::getStatus, 0)
        );
        return count > 0;
    }

    private double getThreshold(String alertType) {
        switch (alertType) {
            case "HIGH_TEMP": return maxTemp;
            case "LOW_TEMP": return minTemp;
            case "HIGH_HUMIDITY": return maxHumidity;
            case "LOW_HUMIDITY": return minHumidity;
            default: return 0;
        }
    }

    private boolean isNormal(double temperature, double humidity) {
        return temperature >= minTemp && temperature <= maxTemp &&
                humidity >= minHumidity && humidity <= maxHumidity;
    }

    private void pushAlertToWebSocket(IotAlert alert) {
        // 通过WebSocket推送到前端
        // 将在WebSocketService中实现
    }
}