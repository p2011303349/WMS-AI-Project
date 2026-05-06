package com.wms.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.wms.context.TenantContextHolder;
import com.wms.dto.AsnRequest;
import com.wms.dto.QualityCheckRequest;
import com.wms.dto.ReceiveRequest;
import com.wms.entity.*;
import com.wms.mapper.*;
import com.wms.service.InboundService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/inbound")
public class InboundController {

    @Autowired
    private InboundService inboundService;
    @Autowired
    private AsnDetailMapper asnDetailMapper;
    @Autowired
    private ReceivingMapper receivingMapper;
    @Autowired
    private ReceivingDetailMapper receivingDetailMapper;
    @Autowired
    private InventoryMapper inventoryMapper;
    @Autowired
    private LocationMapper locationMapper;

    /**
     * 创建ASN单
     */
    @PostMapping("/asn")
    public Map<String, Object> createAsn(@RequestBody AsnRequest request) {
        inboundService.createAsn(request.getAsn(), request.getDetails());
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "ASN创建成功");
        return result;
    }

    /**
     * 收货
     */
    @PostMapping("/receive")
    public Map<String, Object> receive(@RequestBody ReceiveRequest request) {
        inboundService.receiveAndShelve(request.getAsnId(), request.getItems());
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "收货成功");
        return result;
    }

    /**
     * 质检上架
     */
    @PostMapping("/quality-check")
    public Map<String, Object> qualityCheck(@RequestBody QualityCheckRequest request) {
        inboundService.qualityCheckAndShelve(request.getReceivingId(), request.getResults());
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "质检上架完成");
        return result;
    }

    /**
     * 查询ASN列表
     */
    @GetMapping("/asn/list")
    public List<Asn> getAsnList(@RequestParam(required = false) Integer status) {
        return inboundService.getAsnList(status);
    }

    /**
     * 查询库存列表
     */
    @GetMapping("/inventory/list")
    public List<Inventory> getInventoryList(@RequestParam(required = false) String skuCode) {
        return inboundService.getInventoryList(skuCode);
    }

    // 获取ASN明细
    @GetMapping("/asn/detail")
    public List<AsnDetail> getAsnDetail(@RequestParam Long asnId) {
        Long tenantId = TenantContextHolder.getTenantId();
        return asnDetailMapper.selectList(
                new LambdaQueryWrapper<AsnDetail>()
                        .eq(AsnDetail::getTenantId, tenantId)
                        .eq(AsnDetail::getAsnId, asnId)
        );
    }

    // 获取收货单列表
    @GetMapping("/receiving/list")
    public List<Receiving> getReceivingList(@RequestParam(required = false) Integer status) {
        Long tenantId = TenantContextHolder.getTenantId();
        LambdaQueryWrapper<Receiving> wrapper = new LambdaQueryWrapper<Receiving>()
                .eq(Receiving::getTenantId, tenantId);
        if (status != null) {
            wrapper.eq(Receiving::getStatus, status);
        }
        return receivingMapper.selectList(wrapper.orderByDesc(Receiving::getCreateTime));
    }

    // 获取收货明细
    @GetMapping("/receiving/detail")
    public List<ReceivingDetail> getReceivingDetail(@RequestParam Long receivingId) {
        Long tenantId = TenantContextHolder.getTenantId();
        return receivingDetailMapper.selectList(
                new LambdaQueryWrapper<ReceivingDetail>()
                        .eq(ReceivingDetail::getTenantId, tenantId)
                        .eq(ReceivingDetail::getReceivingId, receivingId)
        );
    }

    @GetMapping("/location/list")
    public List<Location> getLocationList() {
        Long tenantId = TenantContextHolder.getTenantId();
        return locationMapper.selectList(
                new LambdaQueryWrapper<Location>()
                        .eq(Location::getTenantId, tenantId)
        );
    }
}