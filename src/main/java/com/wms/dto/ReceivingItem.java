package com.wms.dto;

import lombok.Data;
import java.util.List;


@Data
public class ReceivingItem {
    private String skuCode;
    private String skuName;
    private Integer quantity;
    private String batchNo;
    private String productionDate;
    private String expiryDate;
}