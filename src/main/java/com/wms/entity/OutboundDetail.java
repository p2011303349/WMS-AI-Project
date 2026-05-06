package com.wms.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

@Data
@TableName("outbound_detail")
public class OutboundDetail {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long tenantId;
    private Long orderId;
    private String skuCode;
    private String skuName;
    private Integer quantity;
    private Integer pickedQuantity;
    private Long inventoryId;
    private String batchNo;
    private String locationCode;
}