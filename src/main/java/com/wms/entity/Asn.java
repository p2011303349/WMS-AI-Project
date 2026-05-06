package com.wms.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("asn")
public class Asn {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long tenantId;
    private String asnNo;
    private String supplierName;
    private LocalDateTime expectedDate;
    private Integer status;
    private Integer totalQuantity;
    private Integer receivedQuantity;
    private String remark;
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
}