package com.wms.entity;

import lombok.Data;
import java.sql.Timestamp;

@Data
public class SensorData {
    private Timestamp ts;
    private Float temperature;
    private Float humidity;
    private Float battery;
    private String deviceId;
    private String location;
    private String tenantId;
}