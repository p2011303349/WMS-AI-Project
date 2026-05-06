package com.wms.interceptor;

import com.wms.context.TenantContextHolder;
import com.wms.service.TenantService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@Component
public class TenantInterceptor implements HandlerInterceptor {

    @Autowired
    private TenantService tenantService;

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        // 从请求头获取租户编码
        String tenantCode = request.getHeader("X-Tenant-Code");
        if (tenantCode != null) {
            Long tenantId = tenantService.getTenantIdByCode(tenantCode);
            if (tenantId != null) {
                TenantContextHolder.setTenantId(tenantId);
            }
        }
        return true;
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) {
        TenantContextHolder.clear();
    }
}