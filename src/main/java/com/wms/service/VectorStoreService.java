package com.wms.service;

import dev.langchain4j.data.document.Document;
import dev.langchain4j.data.document.Metadata;
import dev.langchain4j.data.document.parser.TextDocumentParser;
import dev.langchain4j.data.document.splitter.DocumentSplitters;
import dev.langchain4j.data.embedding.Embedding;
import dev.langchain4j.data.segment.TextSegment;
import dev.langchain4j.model.embedding.onnx.allminilml6v2.AllMiniLmL6V2EmbeddingModel;
import dev.langchain4j.model.embedding.EmbeddingModel;
import dev.langchain4j.store.embedding.EmbeddingStore;
import org.springframework.stereotype.Service;
import jakarta.annotation.PostConstruct;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.List;

@Service
public class VectorStoreService {

    private EmbeddingModel embeddingModel;
    private boolean available = false;

    @PostConstruct
    public void init() {
        try {
            System.out.println("正在初始化本地向量存储服务...");

            // 使用本地 Embedding 模型
            embeddingModel = new AllMiniLmL6V2EmbeddingModel();

            available = true;
            System.out.println("本地 Embedding 模型初始化成功");

            // 加载知识库
            loadKnowledgeBase();

        } catch (Exception e) {
            System.err.println("向量存储服务初始化失败: " + e.getMessage());
            e.printStackTrace();
            available = false;
        }
    }

    private void loadKnowledgeBase() {
        String[] documents = {"knowledge/wms_manual.md", "knowledge/faq.md", "knowledge/warehouse_operations.md"};
        for (String docPath : documents) {
            try {
                loadDocumentFromInputStream(docPath);
            } catch (Exception e) {
                System.err.println("文档加载失败: " + docPath + " - " + e.getMessage());
            }
        }
    }

    private void loadDocumentFromInputStream(String path) throws Exception {
        try (InputStream is = getClass().getClassLoader().getResourceAsStream(path)) {
            if (is == null) {
                System.err.println("文件不存在: " + path);
                return;
            }

            String text = new String(is.readAllBytes(), StandardCharsets.UTF_8);
            Metadata metadata = Metadata.from("source", path);
            Document document = Document.from(text, metadata);
            processDocument(document);
            System.out.println("文档加载成功: " + path + " (" + text.length() + " 字符)");
        }
    }

    private void processDocument(Document document) {
        // 分割文档
        List<TextSegment> segments = DocumentSplitters.recursive(500, 50).split(document);
        System.out.println("文档分割完成，共 " + segments.size() + " 个片段");

        // 生成向量
        int successCount = 0;
        for (TextSegment segment : segments) {
            try {
                Embedding embedding = embeddingModel.embed(segment).content();
                successCount++;

                if (successCount % 10 == 0) {
                    System.out.println("已处理 " + successCount + " 个片段");
                }
            } catch (Exception e) {
                System.err.println("向量化失败: " + e.getMessage());
            }
        }
        System.out.println("向量化完成，成功 " + successCount + "/" + segments.size() + " 个片段");
    }

    public List<TextSegment> searchRelevant(String query, int maxResults) {
        if (!available) {
            return List.of();
        }
        // TODO: 实现搜索逻辑（需要向量存储）
        return List.of();
    }
}