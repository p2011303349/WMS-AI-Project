package com.wms.service;

import com.aliyun.dingtalkrobot_1_0.Client;
import com.aliyun.dingtalkrobot_1_0.models.OrgGroupSendHeaders;
import com.aliyun.dingtalkrobot_1_0.models.OrgGroupSendRequest;
import com.aliyun.teaopenapi.models.Config;
import com.aliyun.teautil.models.RuntimeOptions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;
import javax.annotation.PostConstruct;

@Service
public class NotificationService {

    @Autowired(required = false)
    private JavaMailSender mailSender;

    @Value("${alert.email.to:}")
    private String alertEmail;

    @Value("${dingtalk.app.key:}")
    private String appKey;

    @Value("${dingtalk.app.secret:}")
    private String appSecret;

    @Value("${dingtalk.robot.code:}")
    private String robotCode;

    @Value("${dingtalk.open.conversation.id:}")
    private String openConversationId;

    private Client dingTalkClient;

    /**
     * 初始化钉钉客户端
     */
    @PostConstruct
    public void init() {
        try {
            Config config = new Config();
            config.setProtocol("https");
            config.setRegionId("central");
            dingTalkClient = new Client(config);
            System.out.println("钉钉客户端初始化成功");
        } catch (Exception e) {
            System.err.println("钉钉客户端初始化失败: " + e.getMessage());
        }
    }

    /**
     * 获取钉钉访问令牌
     */
    private String getAccessToken() throws Exception {
        com.aliyun.dingtalkoauth2_1_0.Client oauth2Client = createOAuth2Client();
        com.aliyun.dingtalkoauth2_1_0.models.GetAccessTokenRequest getAccessTokenRequest =
                new com.aliyun.dingtalkoauth2_1_0.models.GetAccessTokenRequest()
                        .setAppKey(appKey)
                        .setAppSecret(appSecret);

        com.aliyun.dingtalkoauth2_1_0.models.GetAccessTokenResponse tokenResponse =
                oauth2Client.getAccessToken(getAccessTokenRequest);

        return tokenResponse.getBody().getAccessToken();
    }

    /**
     * 创建OAuth2客户端
     */
    private com.aliyun.dingtalkoauth2_1_0.Client createOAuth2Client() throws Exception {
        com.aliyun.teaopenapi.models.Config config = new com.aliyun.teaopenapi.models.Config()
                .setProtocol("https")
                .setRegionId("central");
        return new com.aliyun.dingtalkoauth2_1_0.Client(config);
    }

    /**
     * 发送告警通知（通用方法）
     */
    public void sendAlert(String message, String alertType) {
        System.out.println("发送告警通知: " + message);

        // 发送邮件
        sendEmail(message);

        // 发送钉钉消息（官方SDK）
        sendDingtalkMessage(message, alertType);
    }

    /**
     * 发送详细的IoT告警（带设备信息和阈值）
     */
    public void sendIotAlert(String deviceId, String alertType,
                             String alertMessage, Double value, Double threshold) {
        String formattedMessage = String.format(
                "【WMS仓库环境告警】\n" +
                        "设备ID: %s\n" +
                        "告警类型: %s\n" +
                        "当前值: %.1f\n" +
                        "阈值: %.1f\n" +
                        "告警时间: %s\n" +
                        "详情: %s\n" +
                        "建议措施: %s",
                deviceId, getAlertTypeName(alertType), value, threshold,
                new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new java.util.Date()),
                alertMessage, getSuggestion(alertType)
        );

        // 发送邮件
        sendEmail(formattedMessage);

        // 发送钉钉（Markdown格式）
        sendDingtalkMarkdown(deviceId, alertType, alertMessage, value, threshold);
    }

    /**
     * 发送钉钉文本消息
     */
    private void sendDingtalkMessage(String message, String alertType) {
        try {
            String accessToken = getAccessToken();

            OrgGroupSendRequest orgGroupSendRequest = new OrgGroupSendRequest()
                    .setOpenConversationId(openConversationId)
                    .setRobotCode(robotCode)
                    .setMsgParam("{\"content\":\"" + message + "\"}")
                    .setMsgKey("sampleText");

            OrgGroupSendHeaders orgGroupSendHeaders = new OrgGroupSendHeaders();
            orgGroupSendHeaders.xAcsDingtalkAccessToken = accessToken;

            dingTalkClient.orgGroupSendWithOptions(orgGroupSendRequest, orgGroupSendHeaders, new RuntimeOptions());
            System.out.println("钉钉告警发送成功");
        } catch (Exception e) {
            System.err.println("钉钉告警发送失败: " + e.getMessage());
            // 降级：使用HTTP方式发送
            sendDingtalkHttpFallback(message);
        }
    }

    /**
     * 发送钉钉Markdown消息
     */
    private void sendDingtalkMarkdown(String deviceId, String alertType,
                                      String alertMessage, Double value, Double threshold) {
        try {
            String accessToken = getAccessToken();

            String markdownContent = String.format(
                    "## ⚠️ WMS仓库环境告警\n" +
                            "- **设备ID**: %s\n" +
                            "- **告警类型**: %s\n" +
                            "- **当前值**: %.1f\n" +
                            "- **阈值**: %.1f\n" +
                            "- **告警时间**: %s\n" +
                            "- **详情**: %s\n" +
                            "- **建议措施**: %s",
                    deviceId, getAlertTypeName(alertType), value, threshold,
                    new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new java.util.Date()),
                    alertMessage, getSuggestion(alertType)
            );

            OrgGroupSendRequest orgGroupSendRequest = new OrgGroupSendRequest()
                    .setOpenConversationId(openConversationId)
                    .setRobotCode(robotCode)
                    .setMsgParam("{\"title\":\"WMS告警\",\"text\":\"" + markdownContent + "\"}")
                    .setMsgKey("sampleMarkdown");

            OrgGroupSendHeaders orgGroupSendHeaders = new OrgGroupSendHeaders();
            orgGroupSendHeaders.xAcsDingtalkAccessToken = accessToken;

            dingTalkClient.orgGroupSendWithOptions(orgGroupSendRequest, orgGroupSendHeaders, new RuntimeOptions());
            System.out.println("钉钉Markdown告警发送成功");
        } catch (Exception e) {
            System.err.println("钉钉Markdown告警发送失败: " + e.getMessage());
            sendDingtalkHttpFallback(alertMessage);
        }
    }

    /**
     * 降级方案：使用HTTP Webhook发送钉钉消息
     */
    private void sendDingtalkHttpFallback(String message) {
        try {
            String webhook = System.getenv("DINGTALK_WEBHOOK");
            if (webhook == null || webhook.isEmpty()) {
                System.out.println("未配置钉钉webhook降级方案");
                return;
            }

            org.springframework.web.client.RestTemplate restTemplate = new org.springframework.web.client.RestTemplate();
            java.util.Map<String, Object> requestBody = new java.util.HashMap<>();
            requestBody.put("msgtype", "text");

            java.util.Map<String, String> text = new java.util.HashMap<>();
            text.put("content", message);
            requestBody.put("text", text);

            restTemplate.postForObject(webhook, requestBody, String.class);
            System.out.println("钉钉HTTP降级发送成功");
        } catch (Exception e) {
            System.err.println("钉钉HTTP降级发送失败: " + e.getMessage());
        }
    }

    /**
     * 发送邮件
     */
    private void sendEmail(String message) {
        if (mailSender == null) {
            System.out.println("邮件服务未配置，跳过邮件通知");
            return;
        }

        if (alertEmail == null || alertEmail.isEmpty()) {
            System.out.println("未配置收件邮箱，跳过邮件通知");
            return;
        }

        try {
            SimpleMailMessage mailMessage = new SimpleMailMessage();
            mailMessage.setTo(alertEmail);
            mailMessage.setSubject("WMS仓库环境告警");
            mailMessage.setText(message + "\n\n此邮件由WMS系统自动发送，请及时处理。");
            mailSender.send(mailMessage);
            System.out.println("邮件告警发送成功: " + alertEmail);
        } catch (Exception e) {
            System.err.println("邮件发送失败: " + e.getMessage());
        }
    }

    /**
     * 获取告警类型的中文名称
     */
    private String getAlertTypeName(String alertType) {
        switch (alertType) {
            case "HIGH_TEMP":
                return "温度过高告警";
            case "LOW_TEMP":
                return "温度过低告警";
            case "HIGH_HUMIDITY":
                return "湿度过高告警";
            case "LOW_HUMIDITY":
                return "湿度过低告警";
            default:
                return alertType;
        }
    }

    /**
     * 根据告警类型获取处理建议
     */
    private String getSuggestion(String alertType) {
        switch (alertType) {
            case "HIGH_TEMP":
                return "请检查空调/通风设备，开启降温措施，确保仓库温度恢复正常范围（0-30℃）。";
            case "LOW_TEMP":
                return "请检查供暖设备，开启升温措施，防止货物受冻，确保仓库温度不低于0℃。";
            case "HIGH_HUMIDITY":
                return "请开启除湿设备，加强通风，防止货物受潮发霉，确保湿度在30%-80%之间。";
            case "LOW_HUMIDITY":
                return "请开启加湿设备，防止静电积累和货物干裂，确保湿度不低于30%。";
            default:
                return "请现场检查确认，及时处理异常情况。";
        }
    }

    /**
     * 测试告警功能（用于调试）
     */
    public void sendTestAlert() {
        sendAlert("WMS系统测试告警，如果您收到此消息，说明告警功能正常工作。", "TEST");
    }
}