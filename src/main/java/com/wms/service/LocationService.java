package com.wms.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.wms.context.TenantContextHolder;
import com.wms.entity.Location;
import com.wms.mapper.LocationMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class LocationService {

    @Autowired
    private LocationMapper locationMapper;

    /**
     * 智能货位分配算法
     */
    public Location recommendLocation(String skuCode, String preferredZone) {
        Long tenantId = TenantContextHolder.getTenantId();

        // 策略1：查找同一商品已有的货位
        List<Location> existingLocations = locationMapper.selectList(new LambdaQueryWrapper<Location>()
                .eq(Location::getTenantId, tenantId)
                .eq(Location::getCurrentSkuCode, skuCode)
                .eq(Location::getStatus, 1));

        if (!existingLocations.isEmpty()) {
            // 返回数量最少的货位（负载均衡）
            return existingLocations.stream()
                    .min(Comparator.comparing(l -> l.getCurrentQuantity() != null ? l.getCurrentQuantity() : 0))
                    .orElse(null);
        }

        // 策略2：查找同库区的空货位
        if (preferredZone != null && !preferredZone.isEmpty()) {
            List<Location> emptyInZone = locationMapper.selectList(new LambdaQueryWrapper<Location>()
                    .eq(Location::getTenantId, tenantId)
                    .eq(Location::getZone, preferredZone)
                    .eq(Location::getStatus, 1)
                    .isNull(Location::getCurrentSkuCode)
                    .last("limit 1"));

            if (!emptyInZone.isEmpty()) {
                return emptyInZone.get(0);
            }
        }

        // 策略3：查找任意空货位
        List<Location> emptyLocations = locationMapper.selectList(new LambdaQueryWrapper<Location>()
                .eq(Location::getTenantId, tenantId)
                .eq(Location::getStatus, 1)
                .isNull(Location::getCurrentSkuCode)
                .last("limit 1"));

        return emptyLocations.isEmpty() ? null : emptyLocations.get(0);
    }
}