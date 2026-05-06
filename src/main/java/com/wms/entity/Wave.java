package com.wms.entity;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("wave")
public class Wave {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long tenantId;
    private String waveNo;
    private Integer waveType;
    private Integer status;
    private Integer orderCount;
    private Integer totalQuantity;
    private LocalDateTime createTime;
}