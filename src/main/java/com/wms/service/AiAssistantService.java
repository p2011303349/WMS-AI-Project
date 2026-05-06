package com.wms.service;

import com.wms.mapper.InventoryMapper;
import dev.langchain4j.model.chat.ChatLanguageModel;
import dev.langchain4j.model.openai.OpenAiChatModel;
import dev.langchain4j.service.AiServices;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import jakarta.annotation.PostConstruct;

@Service
public class AiAssistantService {

    @Value("${deepseek.api.key:}")
    private String apiKey;

    @Autowired
    private InventoryMapper inventoryMapper;

    @Autowired
    private VectorStoreService vectorStoreService;

    private ChatLanguageModel chatModel;
    private WmsAssistant assistant;
    private boolean available = false;

    interface WmsAssistant {
        String chat(String message);
    }

    @PostConstruct
    public void init() {
        if (apiKey == null || apiKey.isEmpty()) {
            System.err.println("DeepSeek API Key 未配置，AI 助手功能禁用");
            return;
        }

        try {
            System.out.println("正在初始化 AI 助手...");

            chatModel = OpenAiChatModel.builder()
                    .apiKey(apiKey)
                    .baseUrl("https://api.deepseek.com/v1")
                    .modelName("deepseek-chat")
                    .temperature(0.7)
                    .maxRetries(1)
                    .build();

            assistant = AiServices.builder(WmsAssistant.class)
                    .chatLanguageModel(chatModel)
                    .build();

            available = true;
            System.out.println("AI 助手初始化成功！");

            // 测试
            String testResponse = assistant.chat("你好");
            System.out.println("AI 测试响应: " + testResponse);

        } catch (Exception e) {
            System.err.println("AI 助手初始化失败: " + e.getMessage());
            e.printStackTrace();
            available = false;
        }
    }

    public String askQuestion(String question) {
        if (!available || assistant == null) {
            return "AI 助手服务正在初始化中，请稍后再试。";
        }

        try {
            // 1. 从数据库查询
            String dbResult = queryDatabase(question);
            if (dbResult != null) {
                return dbResult;
            }

            // 2. 从知识库搜索相关内容
            String context = "";
            try {
                var relevantDocs = vectorStoreService.searchRelevant(question, 3);
                if (!relevantDocs.isEmpty()) {
                    context = "\n\n相关知识：\n" + relevantDocs.stream()
                            .map(doc -> doc.text())
                            .collect(java.util.stream.Collectors.joining("\n---\n"));
                }
            } catch (Exception e) {
                System.err.println("知识库搜索失败: " + e.getMessage());
            }

            // 3. 调用 AI
            String fullPrompt = question + context;
            return assistant.chat(fullPrompt);

        } catch (Exception e) {
            System.err.println("AI 处理失败: " + e.getMessage());
            return "抱歉，处理请求时出错: " + e.getMessage();
        }
    }

    private String queryDatabase(String question) {
        // 库存查询
        if (question.contains("库存") || question.contains("还剩")) {
            java.util.regex.Pattern pattern = java.util.regex.Pattern.compile("SKU[0-9A-Z]+");
            var matcher = pattern.matcher(question.toUpperCase());
            if (matcher.find()) {
                String skuCode = matcher.group();
                var inventories = inventoryMapper.selectList(null);
                int total = inventories.stream()
                        .filter(i -> i.getSkuCode().equalsIgnoreCase(skuCode))  // 忽略大小写
                        .mapToInt(i -> i.getQuantity() - i.getLockedQuantity())
                        .sum();
                return String.format("商品 %s 当前可用库存为 %d 件。", skuCode, total);
            }
        }
        return null;
    }
}