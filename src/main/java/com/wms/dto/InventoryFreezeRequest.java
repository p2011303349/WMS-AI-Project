package com.wms.dto;

import lombok.Data;

@Data
public class InventoryFreezeRequest {
    private Long inventoryId;    // 库存ID
    private String skuCode;       // SKU编码
    private Integer quantity;     // 冻结数量
    private String orderNo;       // 关联订单号
    private String reason;        // 冻结原因
}