package com.wms.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("receiving_detail")
public class ReceivingDetail {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long tenantId;
    private Long receivingId;
    private String skuCode;
    private String skuName;
    private Integer quantity;
    private Integer qualifiedQuantity;
    private Integer defectiveQuantity;
    private String batchNo;
    private LocalDateTime productionDate;
    private LocalDateTime expiryDate;
}