package com.wms.dto;

import lombok.Data;
import java.util.List;

@Data
public class QualityCheckRequest {
    private Long receivingId;
    private List<QualityCheckResult> results;
}

