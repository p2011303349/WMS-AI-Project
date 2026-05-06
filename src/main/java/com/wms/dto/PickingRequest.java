package com.wms.dto;

import lombok.Data;

@Data
public class PickingRequest {
    private Long taskId;
    private Long pickerId;
    private String pickerName;
}