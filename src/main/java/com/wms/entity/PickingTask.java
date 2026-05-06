package com.wms.entity;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@TableName("picking_task")
public class PickingTask {
    @TableId(type = IdType.AUTO)
    private Long id;
    private Long tenantId;
    private Long waveId;
    private Long pickerId;
    private String pickerName;
    private String routePath;
    private Integer status;
    private LocalDateTime startTime;
    private LocalDateTime endTime;

    // 添加这个字段
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createTime;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updateTime;
}