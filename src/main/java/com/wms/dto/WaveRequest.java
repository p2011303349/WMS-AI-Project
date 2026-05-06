package com.wms.dto;

import lombok.Data;
import java.util.List;

@Data
public class WaveRequest {
    private List<Long> orderIds;
    private Integer waveType;
}