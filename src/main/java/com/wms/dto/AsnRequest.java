package com.wms.dto;

import com.wms.entity.Asn;
import com.wms.entity.AsnDetail;
import lombok.Data;
import java.util.List;

@Data
public class AsnRequest {
    private Asn asn;
    private List<AsnDetail> details;
}