package com.wms.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("inventory")
public class Inventory {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long tenantId;
    private String skuCode;
    private String skuName;
    private Long locationId;
    private String batchNo;
    private Integer quantity;
    private Integer lockedQuantity;
    private LocalDateTime productionDate;
    private LocalDateTime expiryDate;
    private LocalDateTime lastUpdateTime;

    // 可用库存 = quantity - lockedQuantity
    public Integer getAvailableQuantity() {
        return quantity - (lockedQuantity != null ? lockedQuantity : 0);
    }
}