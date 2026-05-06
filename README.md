# 跨境电商智能WMS仓储管理系统

## 📖 项目简介

跨境电商智能WMS是一个面向跨境电商企业的智能化仓储管理平台，依托云计算、物联网（IoT）和人工智能技术，为跨境仓储、物流及供应链管理提供全流程数字化解决方案。

平台覆盖入库、库存管理、拣货、出库、智能调度、数据分析等核心业务，支持多仓库协同、多租户（SaaS）模式，并深度融合AI算法优化仓储效率。

## ✨ 核心功能

### 📦 入库管理
- ASN单（预到货通知）管理
- 收货与质检
- 智能货位分配算法
- 上架与库存更新

### 📤 出库管理
- 出库单管理
- 波次计划（批量拣货）
- 智能拣货路径规划
- 发货与库存扣减

### 📊 库存管理
- 库存查询（按SKU/批次/货位）
- 库存冻结/解冻
- 库存移动（货位调拨）
- 分布式锁防止超卖

### 🤖 AI智能助手
- DeepSeek大模型集成
- 自然语言问答
- 库存实时查询
- 智能补货建议

### 📡 IoT环境监控
- MQTT设备接入
- TDengine时序数据库
- 温湿度实时监控
- 异常告警（邮件/钉钉）
- WebSocket实时推送

### 🔐 系统管理
- 多租户SaaS隔离
- JWT认证授权
- 用户与租户管理
- 操作日志记录

## 🛠 技术栈

| 技术 | 版本 | 说明 |
|------|------|------|
| Spring Boot | 3.4.5 | 后端框架 |
| Spring Security | 6.x | 认证授权 |
| MyBatis-Plus | 3.5.7 | ORM框架 |
| MySQL | 8.0 | 业务数据库 |
| Redis | 7.x | 缓存与分布式锁 |
| TDengine | 3.3.x | 时序数据库 |
| EMQX | 5.x | MQTT Broker |
| DeepSeek API | - | AI大模型 |
| LangChain4j | 0.33.0 | AI框架 |
| ECharts | 5.x | 数据可视化 |
| WebSocket | - | 实时推送 |

## 📁 项目结构
wms-tenant-starter/
├── src/main/java/com/wms/
│ ├── config/ # 配置类（Security、MyBatis-Plus、WebSocket等）
│ ├── controller/ # REST API控制器
│ ├── dto/ # 数据传输对象
│ ├── entity/ # 实体类
│ ├── filter/ # JWT过滤器
│ ├── mapper/ # MyBatis-Plus Mapper
│ ├── security/ # JWT工具、UserDetails
│ ├── service/ # 业务逻辑层
│ └── context/ # 租户上下文
├── src/main/resources/
│ ├── static/ # 前端静态页面（HTML/CSS/JS）
│ ├── knowledge/ # AI知识库文档
│ └── application.yml # 配置文件
└── pom.xml # Maven依赖




## 🚀 快速开始

### 环境要求

* JDK 17+
* Maven 3.6+
* MySQL 8.0+
* Redis 7.x+
* Docker（可选，用于TDengine、EMQX）

### 1. 克隆项目

```bash
git clone https://github.com/p2011303349/WMS-AI-Project.git)
cd wms-tenant-starter

2. 创建数据库
sql
执行 src/main/resources/db.sql 初始化数据库表结构和测试数据。

3. 配置文件
修改 application.yml 中的数据库配置：

yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/wms_tenant?useUnicode=true&characterEncoding=utf-8&serverTimezone=Asia/Shanghai
    username: root
    password: your-password
4. 启动依赖服务（Docker方式）
bash
# 启动 Redis
docker run -d --name redis -p 6379:6379 redis:latest

# 启动 TDengine
docker run -d --name tdengine -p 6030:6030 -p 6041:6041 tdengine/tdengine:latest

# 启动 EMQX (MQTT)
docker run -d --name emqx -p 1883:1883 -p 8083:8083 -p 18083:18083 emqx/emqx:latest
5. 配置 DeepSeek API Key
在 application.yml 中配置：

yaml
deepseek:
  api:
    key: your-deepseek-api-key
6. 启动应用
bash
mvn clean install
mvn spring-boot:run
7. 访问系统
页面	URL	说明
登录页面	http://localhost:8080/login.html	用户登录
仪表盘	http://localhost:8080/index.html	数据概览
入库管理	http://localhost:8080/inbound.html	入库操作
出库管理	http://localhost:8080/outbound.html	出库操作
库存查询	http://localhost:8080/inventory.html	库存查询
AI助手	http://localhost:8080/ai-chat.html	智能问答
AI智能体	http://localhost:8080/ai-agent.html	工具调用
IoT监控	http://localhost:8080/iot-dashboard.html	环境监控
8. 测试账号
租户编码	用户名	密码	角色
tenantA	admin	123456	管理员
tenantB	admin	123456	管理员
📡 模拟传感器数据
运行模拟设备程序发送测试数据：

bash
# 使用 curl 发送模拟数据
curl -u root:taosdata http://localhost:6041/rest/sql \
  -d "INSERT INTO wms_iot.sensor_sensor_01 VALUES (NOW, 25.5, 60.0, 95.0)"
🤝 开发指南
添加新功能
创建对应的实体类和Mapper

编写Service业务逻辑

创建Controller接口

添加前端页面（可选）

API接口规范
使用 RESTful 风格

请求头携带 JWT Token：Authorization: Bearer <token>

多租户请求头：X-Tenant-Code: tenantA

📚 主要API接口
模块	接口	说明
认证	POST /auth/login	用户登录
入库	POST /api/inbound/asn	创建ASN单
入库	POST /api/inbound/receive	收货
入库	POST /api/inbound/quality-check	质检上架
出库	POST /api/outbound/order	创建出库单
出库	POST /api/outbound/wave	创建波次
出库	POST /api/outbound/ship	发货
库存	GET /api/inbound/inventory/list	库存查询
AI	POST /api/ai/chat	AI问答
AI	POST /api/ai/agent/chat	AI智能体
IoT	GET /api/iot/sensor/latest/{deviceId}	最新传感器数据
⚙️ 配置说明
应用配置
yaml
# JWT 配置
jwt:
  secret: your-jwt-secret
  expiration: 86400000  # 24小时

# MQTT 配置
mqtt:
  broker:
    url: tcp://localhost:1883
  topics: /warehouse/+/sensor

# AI 配置
deepseek:
  api:
    key: your-api-key
日志配置
yaml
logging:
  level:
    com.wms: DEBUG
  pattern:
    console: "%d{yyyy-MM-dd HH:mm:ss} - %msg%n"
🐛 常见问题
1. Redis 连接失败
确保 Redis 服务已启动：

bash
docker start redis
2. TDengine 连接失败
bash
# 检查容器状态
docker ps | grep tdengine

# 重启 TDengine
docker restart tdengine
3. JWT Token 过期
重新登录获取新 Token，或修改配置延长过期时间。

4. 邮件发送失败
检查邮箱配置，或注释邮件发送功能。

📄 License
MIT License

👥 作者
作者：p2011303349

邮箱：p2011303349@126.com

GitHub：https://github.com/p2011303349

🙏 致谢
Spring Boot

DeepSeek

Camunda

TDengine

text

## 快速开始

### 环境要求
- JDK 17+
- MySQL 8.0+
- Redis 7.x


### 启动步骤

1. 创建数据库并执行 SQL 脚本
2. 修改 `application.yml` 中的数据库密码
3. 启动 Redis、TDengine、EMQX（可选）
4. 运行 `mvn spring-boot:run`

### 访问地址
- 登录页面: http://localhost:8080/login.html
- 测试账号: tenantA / admin / 123456
