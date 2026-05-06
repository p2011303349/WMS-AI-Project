package com.wms.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("inventory_freeze_log")
public class InventoryFreezeLog {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long tenantId;
    private Long inventoryId;
    private String skuCode;
    private Integer quantity;
    private String orderNo;
    private String reason;
    private Integer status;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
}