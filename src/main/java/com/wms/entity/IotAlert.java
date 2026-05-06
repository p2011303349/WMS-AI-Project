package com.wms.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("iot_alert")
public class IotAlert {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long tenantId;
    private String deviceId;
    private String deviceType;
    private String alertType;
    private Double alertValue;
    private Double thresholdValue;
    private String alertMessage;
    private Integer status;
    private LocalDateTime createTime;
    private LocalDateTime handleTime;
    private String handler;
}