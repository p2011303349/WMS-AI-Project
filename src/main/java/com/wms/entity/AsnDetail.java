package com.wms.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

@Data
@TableName("asn_detail")
public class AsnDetail {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long tenantId;
    private Long asnId;
    private String skuCode;
    private String skuName;
    private Integer expectedQuantity;
    private Integer receivedQuantity;
    private Integer qualifiedQuantity;
    private String unit;
    private String remark;
}