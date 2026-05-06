package com.wms.controller;

import com.wms.context.TenantContextHolder;
import com.wms.dto.LoginRequest;
import com.wms.dto.LoginResponse;
import com.wms.security.JwtTokenUtil;
import com.wms.service.TenantService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/auth")
public class AuthController {

    @Autowired
    private AuthenticationManager authenticationManager;

    @Autowired
    private JwtTokenUtil jwtTokenUtil;

    @Autowired
    private TenantService tenantService;

    @PostMapping("/login")
    public LoginResponse login(@RequestBody LoginRequest request) {
        System.out.println("========== 1. 收到登录请求 ==========");
        System.out.println("租户编码: " + request.getTenantCode());
        System.out.println("用户名: " + request.getUsername());
        System.out.println("密码: " + request.getPassword());

        // 1. 根据租户编码设置租户上下文
        Long tenantId = tenantService.getTenantIdByCode(request.getTenantCode());
        System.out.println("2. 查询租户ID: " + tenantId);

        if (tenantId == null) {
            System.out.println("3. 租户不存在！");
            throw new RuntimeException("租户不存在");
        }
        TenantContextHolder.setTenantId(tenantId);
        System.out.println("3. 租户上下文已设置: " + TenantContextHolder.getTenantId());

        // 2. 认证
        try {
            System.out.println("4. 开始认证...");
            UsernamePasswordAuthenticationToken authToken =
                    new UsernamePasswordAuthenticationToken(request.getUsername(), request.getPassword());
            Authentication authentication = authenticationManager.authenticate(authToken);
            UserDetails userDetails = (UserDetails) authentication.getPrincipal();
            System.out.println("5. 认证成功: " + userDetails.getUsername());

            // 3. 生成Token
            System.out.println("6. 开始生成Token...");
            String token = jwtTokenUtil.generateToken(userDetails, tenantId);
            System.out.println("7. Token生成成功: " + token);

            return new LoginResponse(token);
        } catch (Exception e) {
            System.out.println("认证失败: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException("用户名或密码错误");
        }
    }
}