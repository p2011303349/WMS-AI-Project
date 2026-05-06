package com.wms.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.wms.entity.Tenant;
import com.wms.mapper.TenantMapper;
import org.springframework.cache.annotation.Cacheable;
import org.springframework.stereotype.Service;

@Service
public class TenantService extends ServiceImpl<TenantMapper, Tenant> {

    @Cacheable(value = "tenantId", key = "#tenantCode")
    public Long getTenantIdByCode(String tenantCode) {
        Tenant tenant = lambdaQuery().eq(Tenant::getTenantCode, tenantCode).one();
        return tenant != null ? tenant.getId() : null;
    }
}