package com.wms.dto;

import lombok.Data;
import java.util.List;


@Data
public class QualityCheckResult {
    private Long detailId;
    private Integer qualifiedQuantity;
    private Integer defectiveQuantity;
    private String preferredZone;
}