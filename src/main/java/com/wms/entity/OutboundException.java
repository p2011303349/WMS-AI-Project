package com.wms.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("outbound_exception")
public class OutboundException {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long tenantId;
    private Long orderId;
    private String orderNo;
    private String exceptionType;
    private String exceptionDetail;
    private Integer status;
    private String suggestion;
    private String handler;
    private LocalDateTime createTime;
    private LocalDateTime handleTime;
}