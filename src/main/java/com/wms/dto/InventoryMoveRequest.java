package com.wms.dto;

import lombok.Data;

@Data
public class InventoryMoveRequest {
    private Long inventoryId;     // 库存ID
    private Long fromLocationId;  // 源货位
    private Long toLocationId;    // 目标货位
    private Integer quantity;     // 移动数量
    private String reason;        // 移动原因
}