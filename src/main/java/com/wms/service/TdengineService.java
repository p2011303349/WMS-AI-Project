package com.wms.service;

import com.wms.entity.SensorData;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import javax.annotation.PostConstruct;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

@Service
@ConditionalOnProperty(name = "tdengine.enabled", havingValue = "true", matchIfMissing = false)
public class TdengineService {

    @Autowired(required = false)
    @Qualifier("tdJdbcTemplate")
    private JdbcTemplate tdJdbcTemplate;

    private boolean tdengineAvailable = false;

    @PostConstruct
    public void init() {
        if (tdJdbcTemplate == null) {
            System.err.println("TDengine JdbcTemplate 未配置，跳过初始化");
            return;
        }

        try {
            // 测试连接
            testConnection();

            // 创建数据库
            createDatabase();

            // 创建超级表（在SQL中直接指定数据库名）
            createSuperTable();

            tdengineAvailable = true;
            System.out.println("TDengine 初始化成功，IoT功能可用");
        } catch (Exception e) {
            System.err.println("TDengine 初始化失败: " + e.getMessage());
            System.err.println("IoT功能将不可用，可设置 tdengine.enabled=false 禁用");
            tdengineAvailable = false;
        }
    }

    private void testConnection() {
        try {
            String result = tdJdbcTemplate.queryForObject("SELECT SERVER_VERSION()", String.class);
            System.out.println("TDengine 连接成功，版本: " + result);
        } catch (Exception e) {
            System.err.println("TDengine 连接测试失败: " + e.getMessage());
            throw new RuntimeException("TDengine 连接失败", e);
        }
    }

    private void createDatabase() {
        try {
            String sql = "CREATE DATABASE IF NOT EXISTS wms_iot";
            tdJdbcTemplate.execute(sql);
            System.out.println("TDengine 数据库 wms_iot 创建/已存在");
        } catch (Exception e) {
            System.err.println("创建数据库失败: " + e.getMessage());
            throw new RuntimeException("创建数据库失败", e);
        }
    }

    private void createSuperTable() {
        try {
            // 直接在 SQL 中指定数据库名，避免 USE 命令的问题
            String sql = "CREATE STABLE IF NOT EXISTS wms_iot.sensor_data (" +
                    "    ts TIMESTAMP," +
                    "    temperature FLOAT," +
                    "    humidity FLOAT," +
                    "    battery FLOAT" +
                    ") TAGS (" +
                    "    device_id BINARY(32)," +
                    "    location BINARY(64)," +
                    "    tenant_id BINARY(20)" +
                    ")";
            tdJdbcTemplate.execute(sql);
            System.out.println("TDengine 超级表 sensor_data 创建/已存在");
        } catch (Exception e) {
            System.err.println("创建超级表失败: " + e.getMessage());
            throw new RuntimeException("创建超级表失败", e);
        }
    }

    public void createSubTable(String deviceId, String location, String tenantId) {
        if (!tdengineAvailable || tdJdbcTemplate == null) {
            return;
        }

        String tableName = "sensor_" + deviceId.replace("-", "_");
        try {
            // 直接在 SQL 中指定数据库名
            String sql = String.format(
                    "CREATE TABLE IF NOT EXISTS wms_iot.%s USING wms_iot.sensor_data TAGS ('%s', '%s', '%s')",
                    tableName, deviceId, location, tenantId
            );
            tdJdbcTemplate.execute(sql);
            System.out.println("子表创建成功: " + tableName);
        } catch (Exception e) {
            System.err.println("创建子表失败: " + e.getMessage());
        }
    }

    public void insertSensorData(SensorData data) {
        if (!tdengineAvailable || tdJdbcTemplate == null) {
            return;
        }

        try {
            String tableName = "sensor_" + data.getDeviceId().replace("-", "_");
            createSubTable(data.getDeviceId(), data.getLocation(), data.getTenantId());

            // 直接在 SQL 中指定数据库名
            String sql = String.format("INSERT INTO wms_iot.%s VALUES (?, ?, ?, ?)", tableName);
            int result = tdJdbcTemplate.update(sql, data.getTs(), data.getTemperature(),
                    data.getHumidity(), data.getBattery());
            if (result > 0) {
                System.out.println("传感器数据插入成功: " + data.getDeviceId());
            }
        } catch (Exception e) {
            System.err.println("插入传感器数据失败: " + e.getMessage());
        }
    }

    public List<SensorData> getLatestData(String deviceId, int limit) {
        if (!tdengineAvailable || tdJdbcTemplate == null) {
            return new ArrayList<>();
        }

        try {
            String tableName = "sensor_" + deviceId.replace("-", "_");
            // 直接在 SQL 中指定数据库名
            String sql = String.format(
                    "SELECT ts, temperature, humidity, battery FROM wms_iot.%s ORDER BY ts DESC LIMIT %d",
                    tableName, limit
            );
            return tdJdbcTemplate.query(sql, (rs, rowNum) -> {
                SensorData data = new SensorData();
                data.setTs(rs.getTimestamp("ts"));
                data.setTemperature(rs.getFloat("temperature"));
                data.setHumidity(rs.getFloat("humidity"));
                data.setBattery(rs.getFloat("battery"));
                data.setDeviceId(deviceId);
                return data;
            });
        } catch (Exception e) {
            System.err.println("查询最新数据失败: " + e.getMessage());
            return new ArrayList<>();
        }
    }

    public List<SensorData> getHistoryData(String deviceId, long startTime, long endTime) {
        if (!tdengineAvailable || tdJdbcTemplate == null) {
            return new ArrayList<>();
        }

        try {
            String tableName = "sensor_" + deviceId.replace("-", "_");
            // 直接在 SQL 中指定数据库名
            String sql = String.format(
                    "SELECT ts, temperature, humidity, battery FROM wms_iot.%s WHERE ts >= ? AND ts <= ? ORDER BY ts ASC",
                    tableName
            );
            return tdJdbcTemplate.query(sql, (rs, rowNum) -> {
                SensorData data = new SensorData();
                data.setTs(rs.getTimestamp("ts"));
                data.setTemperature(rs.getFloat("temperature"));
                data.setHumidity(rs.getFloat("humidity"));
                data.setBattery(rs.getFloat("battery"));
                data.setDeviceId(deviceId);
                return data;
            }, new Timestamp(startTime), new Timestamp(endTime));
        } catch (Exception e) {
            System.err.println("查询历史数据失败: " + e.getMessage());
            return new ArrayList<>();
        }
    }

    public boolean isAvailable() {
        return tdengineAvailable;
    }
}