package com.wms.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.wms.context.TenantContextHolder;
import com.wms.dto.QualityCheckResult;
import com.wms.dto.ReceivingItem;
import com.wms.entity.*;
import com.wms.mapper.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Service
public class InboundService {

    @Autowired
    private AsnMapper asnMapper;

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

    @Autowired
    private LocationService locationService;

    /**
     * 创建ASN单
     */
    @Transactional
    public void createAsn(Asn asn, List<AsnDetail> details) {
        Long tenantId = TenantContextHolder.getTenantId();
        asn.setTenantId(tenantId);
        asn.setStatus(0); // 待收货
        asn.setReceivedQuantity(0);
        asnMapper.insert(asn);

        for (AsnDetail detail : details) {
            detail.setTenantId(tenantId);
            detail.setAsnId(asn.getId());
            detail.setReceivedQuantity(0);
            detail.setQualifiedQuantity(0);
            asnDetailMapper.insert(detail);
        }
    }

    /**
     * 收货
     */
    @Transactional
    public void receiveAndShelve(Long asnId, List<ReceivingItem> items) {
        Long tenantId = TenantContextHolder.getTenantId();

        // 1. 创建收货单
        Receiving receiving = new Receiving();
        receiving.setTenantId(tenantId);
        receiving.setReceivingNo("REC" + System.currentTimeMillis());
        receiving.setAsnId(asnId);
        receiving.setReceivingTime(LocalDateTime.now());
        receiving.setStatus(0); // 待质检
        receivingMapper.insert(receiving);

        // 2. 保存收货明细
        for (ReceivingItem item : items) {
            ReceivingDetail detail = new ReceivingDetail();
            detail.setTenantId(tenantId);
            detail.setReceivingId(receiving.getId());
            detail.setSkuCode(item.getSkuCode());
            detail.setSkuName(item.getSkuName());
            detail.setQuantity(item.getQuantity());
            detail.setQualifiedQuantity(0);
            detail.setDefectiveQuantity(0);
            detail.setBatchNo(item.getBatchNo());

            // 解析日期
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm:ss");
            if (item.getProductionDate() != null) {
                detail.setProductionDate(LocalDateTime.parse(item.getProductionDate(), formatter));
            }
            if (item.getExpiryDate() != null) {
                detail.setExpiryDate(LocalDateTime.parse(item.getExpiryDate(), formatter));
            }
            receivingDetailMapper.insert(detail);
        }

        // 3. 更新ASN收货数量
        Asn asn = asnMapper.selectById(asnId);
        int totalReceived = items.stream().mapToInt(ReceivingItem::getQuantity).sum();
        asn.setReceivedQuantity(asn.getReceivedQuantity() + totalReceived);
        if (asn.getReceivedQuantity() >= asn.getTotalQuantity()) {
            asn.setStatus(2); // 已完成
        }
        asnMapper.updateById(asn);
    }

    /**
     * 质检通过并上架
     */
    @Transactional
    public void qualityCheckAndShelve(Long receivingId, List<QualityCheckResult> results) {
        Long tenantId = TenantContextHolder.getTenantId();

        for (QualityCheckResult result : results) {
            // 1. 获取收货明细
            ReceivingDetail detail = receivingDetailMapper.selectById(result.getDetailId());
            if (detail == null) {
                throw new RuntimeException("收货明细不存在: " + result.getDetailId());
            }

            // 2. 更新收货明细的合格数量
            detail.setQualifiedQuantity(result.getQualifiedQuantity());
            detail.setDefectiveQuantity(result.getDefectiveQuantity());
            receivingDetailMapper.updateById(detail);

            // 3. 智能货位分配
            Location location = locationService.recommendLocation(
                    detail.getSkuCode(),
                    result.getPreferredZone()
            );

            if (location == null) {
                throw new RuntimeException("没有可用的货位");
            }

            // 4. 更新或创建库存
            Inventory inventory = inventoryMapper.selectOne(
                    new LambdaQueryWrapper<Inventory>()
                            .eq(Inventory::getTenantId, tenantId)
                            .eq(Inventory::getSkuCode, detail.getSkuCode())
                            .eq(Inventory::getLocationId, location.getId())
                            .eq(Inventory::getBatchNo, detail.getBatchNo())
            );

            if (inventory == null) {
                inventory = new Inventory();
                inventory.setTenantId(tenantId);
                inventory.setSkuCode(detail.getSkuCode());
                inventory.setSkuName(detail.getSkuName());
                inventory.setLocationId(location.getId());
                inventory.setBatchNo(detail.getBatchNo());
                inventory.setQuantity(result.getQualifiedQuantity());
                inventory.setLockedQuantity(0);
                inventory.setProductionDate(detail.getProductionDate());
                inventory.setExpiryDate(detail.getExpiryDate());
                inventoryMapper.insert(inventory);
            } else {
                inventory.setQuantity(inventory.getQuantity() + result.getQualifiedQuantity());
                inventoryMapper.updateById(inventory);
            }

            // 5. 更新货位信息
            location.setCurrentSkuCode(detail.getSkuCode());
            location.setCurrentQuantity(
                    (location.getCurrentQuantity() != null ? location.getCurrentQuantity() : 0)
                            + result.getQualifiedQuantity()
            );
            locationMapper.updateById(location);
        }

        // 6. 更新收货单状态为已完成
        Receiving receiving = receivingMapper.selectById(receivingId);
        receiving.setStatus(2);
        receivingMapper.updateById(receiving);
    }

    /**
     * 查询ASN列表
     */
    public List<Asn> getAsnList(Integer status) {
        Long tenantId = TenantContextHolder.getTenantId();
        LambdaQueryWrapper<Asn> wrapper = new LambdaQueryWrapper<Asn>()
                .eq(Asn::getTenantId, tenantId);
        if (status != null) {
            wrapper.eq(Asn::getStatus, status);
        }
        return asnMapper.selectList(wrapper.orderByDesc(Asn::getCreateTime));
    }

    /**
     * 查询库存列表
     */
    public List<Inventory> getInventoryList(String skuCode) {
        Long tenantId = TenantContextHolder.getTenantId();
        LambdaQueryWrapper<Inventory> wrapper = new LambdaQueryWrapper<Inventory>()
                .eq(Inventory::getTenantId, tenantId);
        if (skuCode != null && !skuCode.isEmpty()) {
            wrapper.eq(Inventory::getSkuCode, skuCode);
        }
        return inventoryMapper.selectList(wrapper);
    }
}