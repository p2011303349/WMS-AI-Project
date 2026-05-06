package com.wms.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("receiving")
public class Receiving {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long tenantId;
    private String receivingNo;
    private Long asnId;
    private String supplierName;
    private LocalDateTime receivingTime;
    private Integer status;
    private String operator;
    private LocalDateTime createTime;
}