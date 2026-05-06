package com.wms.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.wms.entity.Tenant;
import com.wms.service.TenantService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/tenant")
@PreAuthorize("hasRole('ADMIN')")
public class TenantController {

    @Autowired
    private TenantService tenantService;

    @GetMapping("/list")
    public List<Tenant> list() {
        return tenantService.list();
    }

    @PostMapping("/add")
    public boolean add(@RequestBody Tenant tenant) {
        return tenantService.save(tenant);
    }

    @PutMapping("/update")
    public boolean update(@RequestBody Tenant tenant) {
        return tenantService.updateById(tenant);
    }

    @DeleteMapping("/delete/{id}")
    public boolean delete(@PathVariable Long id) {
        return tenantService.removeById(id);
    }
}