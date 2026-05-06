package com.wms.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@TableName("location")
public class Location {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long tenantId;
    private String locationCode;
    private String zone;
    private String rowNo;
    private String colNo;
    private String levelNo;
    private Integer status;
    private BigDecimal maxWeight;
    private BigDecimal maxVolume;
    private String currentSkuCode;
    private Integer currentQuantity;
    private LocalDateTime createTime;
}