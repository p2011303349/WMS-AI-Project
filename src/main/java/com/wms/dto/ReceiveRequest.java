package com.wms.dto;

import lombok.Data;
import java.util.List;

@Data
public class ReceiveRequest {
    private Long asnId;
    private List<ReceivingItem> items;
}
