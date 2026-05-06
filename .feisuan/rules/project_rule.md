
# 开发规范指南

为保证代码质量、可维护性、安全性与可扩展性，请在开发过程中严格遵循以下规范。

## 一、项目环境与工具

- **操作系统**：Windows 11
- **工作目录**：`D:\project\wms-tenant-starter`
- **JDK 版本**：17.0.18
- **构建工具**：Maven
- **代码作者**：p2011

## 二、技术栈要求

- **主框架**：Spring Boot 3.5.13
- **语言版本**：Java 17
- **核心依赖**：
  - `spring-boot-starter-web`
  - `spring-boot-starter-data-jpa`
  - `mybatis-plus-spring-boot3-starter` (MyBatis-Plus 3.5.16)
  - `spring-boot-starter-security` (安全框架)
  - `lombok`
- **缓存与分布式**：
  - `spring-boot-starter-data-redis`
  - `redisson-spring-boot-starter`
- **数据存储**：
  - `mysql-connector-j` (MySQL)
  - `taos-jdbcdriver` (TDengine 时序数据库)
- **AI 与智能**：
  - `spring-ai-starter-model-openai`
  - `langchain4j-spring-boot-starter`
  - `langchain4j-embeddings-all-minilm-l6-v2` (本地 Embedding 模型)
  - `milvus-sdk-java`
- **消息与集成**：
  - `spring-boot-starter-websocket`
  - `spring-boot-starter-mail`
  - `spring-boot-starter-thymeleaf`
  - `spring-integration-mqtt`
- **工具与安全**：
  - `jjwt-api` (JWT 0.12.6)
  - `commonmark` (Markdown 解析)
  - `dingtalk` (钉钉 SDK)

## 三、目录结构规范

项目采用标准的 Maven 结构，并遵循模块化设计。

```tree
wms-tenant-starter
└── src
    ├── main
    │   ├── java
    │   │   └── com
    │   │       └── wms
    │   │           ├── config          # 配置类
    │   │           ├── context         # 上下文/租户相关
    │   │           ├── controller      # 控制器层
    │   │           ├── dto             # 数据传输对象
    │   │           ├── entity          # 数据库实体
    │   │           ├── filter          # 过滤器
    │   │           ├── interceptor     # 拦截器
    │   │           ├── mapper          # MyBatis Mapper 接口
    │   │           ├── security        # 安全、认证相关
    │   │           ├── service         # 业务逻辑层
    │   │           └── util            # 工具类
    │   └── resources
    │       ├── knowledge      # 知识库
    │       ├── static         # 静态资源
    │       │   ├── css
    │       │   └── js
    │       └── templates      # Thymeleaf 模板
    └── test
        └── java
            └── com
                └── wms            # 测试代码
```

## 四、分层架构规范

| 层级        | 职责说明                         | 开发约束与注意事项                                               |
|-------------|----------------------------------|------------------------------------------------------------------|
| **Controller** | 处理 HTTP 请求与响应，定义 API 接口 | 不得直接访问数据库，必须通过 Service 层调用；返回 DTO             |
| **Service**    | 实现业务逻辑、事务管理与数据校验   | 必须通过 Mapper 或 Repository 层访问数据库；返回 DTO             |
| **Mapper**     | 数据库访问与持久化操作             | 继承 `BaseMapper`；配置 XML 映射文件位于 `resources/mapper`       |
| **Entity**     | 映射数据库表结构                   | 不得直接返回给前端（需转换为 DTO）；使用 Lombok 简化               |

### 接口与实现分离

- 所有业务逻辑通过接口定义，具体实现放在接口所在包下的 `impl` 子包中。

## 五、安全与性能规范

### 输入校验

- 使用 `@Valid` 与 JSR-303 校验注解（如 `@NotBlank`, `@Size` 等）。
  - 注意：Spring Boot 3.x 中校验注解位于 `jakarta.validation.constraints.*`
- 禁止手动拼接 SQL 字符串，防止 SQL 注入攻击。

### 事务管理

- `@Transactional` 注解仅用于 **Service 层**方法。
- 避免在循环中频繁提交事务。

### JWT 与安全

- 使用 `io.jsonwebtoken` (jjwt 0.12.6) 生成与验证 Token。
- 配置文件中严禁明文存储敏感信息（如 API Key、数据库密码）。

## 六、代码风格规范

### 命名规范

| 类型       | 命名方式             | 示例                  |
|------------|----------------------|-----------------------|
| 类名       | UpperCamelCase       | `UserServiceImpl`     |
| 方法/变量  | lowerCamelCase       | `saveUser()`          |
| 常量       | UPPER_SNAKE_CASE     | `MAX_LOGIN_ATTEMPTS`  |
| Mapper     | 接口以 `Mapper` 结尾 | `InventoryMapper`     |

### 注释规范

- 所有类、方法、字段需添加 **Javadoc** 注释。
- 注释使用 **中文**。

### 类型命名规范（阿里巴巴风格）

| 后缀 | 用途说明                     | 示例         |
|------|------------------------------|--------------|
| DTO  | 数据传输对象                 | `UserDTO`    |
| DO   | 数据库实体对象               | `UserDO`     |
| BO   | 业务逻辑封装对象             | `UserBO`     |
| VO   | 视图展示对象                 | `UserVO`     |
| Query| 查询参数封装对象             | `UserQuery`  |

### 实体类简化工具

- 使用 Lombok 注解替代手动编写 getter/setter/构造方法：
  - `@Data`
  - `@NoArgsConstructor`
  - `@AllArgsConstructor`

## 七、通用规则总结

1.  **MyBatis-Plus 配置**：
    - 使用 `@EntityGraph` 避免 N+1 查询问题。
    - 全局配置 `id-type: auto` (自增主键)。
    - Mapper XML 文件位置：`classpath*:/mapper/**/*.xml`。
2.  **多租户与缓存**：
    - 优先使用 Redis 缓存数据。
    - 使用 Redisson 处理分布式锁。
3.  **AI 集成**：
    - 使用 DeepSeek API (兼容 OpenAI 协议)。
    - 支持 LangChain4j 进行 LLM 调用与本地 Embedding (All-MiniLM-L6-v2)。
4.  **IoT 与消息**：
    - 使用 MQTT 协议与 Paho 客户端与设备通信。
    - 集成 TDengine 处理时序数据。
5.  **文档与通知**：
    - 支持发送邮件与钉钉消息。
    - 支持 Markdown 文档解析。

## 八、扩展性与日志规范

### 接口优先原则

- 所有业务逻辑通过接口定义，具体实现放在 `impl` 包中。

### 日志记录

- 使用 `@Slf4j` 注解代替 `System.out.println`。
- 日志级别：`com.wms` 为 `DEBUG`。

## 九、编码原则总结

| 原则       | 说明                                       |
|------------|--------------------------------------------|
| **SOLID**  | 高内聚、低耦合，增强可维护性与可扩展性     |
| **DRY**    | 避免重复代码，提高复用性                   |
| **KISS**   | 保持代码简洁易懂                           |
| **YAGNI**  | 不实现当前不需要的功能                     |
| **OWASP**  | 防范常见安全漏洞，如 SQL 注入、XSS 等      |
