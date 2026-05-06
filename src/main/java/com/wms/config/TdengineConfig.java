package com.wms.config;

import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.datasource.DriverManagerDataSource;
import javax.sql.DataSource;

@Configuration
@ConditionalOnProperty(name = "tdengine.enabled", havingValue = "true", matchIfMissing = false)
public class TdengineConfig {

    @Bean(name = "tdengineDataSource")
    public DataSource tdengineDataSource() {
        DriverManagerDataSource dataSource = new DriverManagerDataSource();
        dataSource.setDriverClassName("com.taosdata.jdbc.TSDBDriver");
        dataSource.setUrl("jdbc:TAOS-RS://localhost:6041/");
        dataSource.setUsername("root");
        dataSource.setPassword("taosdata");
        return dataSource;
    }

    @Bean(name = "tdJdbcTemplate")
    public JdbcTemplate tdJdbcTemplate(@Qualifier("tdengineDataSource") DataSource dataSource) {
        return new JdbcTemplate(dataSource);
    }
}