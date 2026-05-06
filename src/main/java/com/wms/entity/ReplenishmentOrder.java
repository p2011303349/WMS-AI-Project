package com.wms.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("replenishment_order")
public class ReplenishmentOrder {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long tenantId;
    private String orderNo;
    private String skuCode;
    private String skuName;
    private Integer currentStock;
    private Integer suggestQuantity;
    private String reason;
    private Integer status;
    private LocalDateTime createTime;
    private LocalDateTime auditTime;
    private String auditor;
    private String auditComment;        // 审核意见
    // 添加这个字段
    private String processInstanceId;  // 工作流实例ID
}