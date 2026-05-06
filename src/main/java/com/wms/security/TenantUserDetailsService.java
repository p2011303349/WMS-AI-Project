package com.wms.security;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.wms.context.TenantContextHolder;
import com.wms.entity.User;
import com.wms.mapper.UserMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;
import java.util.ArrayList;

@Service
public class TenantUserDetailsService implements UserDetailsService {

    @Autowired
    private UserMapper userMapper;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {
        Long tenantId = TenantContextHolder.getTenantId();

        System.out.println("=== loadUserByUsername 被调用 ===");
        System.out.println("用户名: " + username);
        System.out.println("租户ID: " + tenantId);

        if (tenantId == null) {
            throw new UsernameNotFoundException("缺少租户信息，请提供租户编码");
        }

        User user = userMapper.selectOne(new LambdaQueryWrapper<User>()
                .eq(User::getTenantId, tenantId)
                .eq(User::getUsername, username));

        System.out.println("查询到的用户: " + (user != null ? user.getUsername() : "null"));
        System.out.println("数据库中的密码: " + (user != null ? user.getPassword() : "null"));
        System.out.println("密码长度: " + (user != null && user.getPassword() != null ? user.getPassword().length() : 0));

        if (user == null) {
            throw new UsernameNotFoundException("用户不存在: " + username);
        }

        return new org.springframework.security.core.userdetails.User(
                user.getUsername(),
                user.getPassword(),
                new ArrayList<>()
        );
    }
}