package com.wms.dto;

import com.wms.entity.OutboundDetail;
import com.wms.entity.OutboundOrder;
import lombok.Data;
import java.util.List;

@Data
public class OutboundRequest {
    private OutboundOrder order;
    private List<OutboundDetail> details;
}