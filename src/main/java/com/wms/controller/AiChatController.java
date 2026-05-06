package com.wms.controller;

import com.wms.entity.OutboundException;
import com.wms.entity.ReplenishmentOrder;
import com.wms.service.AiAgentService;
import com.wms.service.AiAssistantService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/ai")
public class AiChatController {

    @Autowired
    private AiAssistantService assistantService;

    @Autowired
    private AiAgentService agentService;


    /**
     * 智能问答
     */
    @PostMapping("/chat")
    public Map<String, String> chat(@RequestBody Map<String, String> request) {
        String question = request.get("question");
        String answer = assistantService.askQuestion(question);

        Map<String, String> response = new HashMap<>();
        response.put("answer", answer);
        return response;
    }

    /**
     * Agent 对话
     */
    @PostMapping("/agent/chat")
    public Map<String, String> agentChat(@RequestBody Map<String, String> request) {
        String message = request.get("message");
        String response = agentService.chat(message);

        Map<String, String> result = new HashMap<>();
        result.put("response", response);
        return result;
    }

    /**
     * 触发智能补货
     */
    @PostMapping("/replenishment/scan")
    public Map<String, String> scanReplenishment() {
        agentService.autoReplenishment();
        Map<String, String> result = new HashMap<>();
        result.put("message", "补货扫描完成，请查看控制台日志");
        return result;
    }
    // ==================== 补货管理接口 ====================

    @GetMapping("/replenishment/list")
    public List<ReplenishmentOrder> getReplenishmentList(@RequestParam(required = false) Integer status) {
        return agentService.getReplenishmentList(status);
    }



    @PostMapping("/replenishment/audit")
    public Map<String, Object> auditReplenishment(@RequestBody Map<String, Object> request) {
        Long orderId = Long.valueOf(request.get("orderId").toString());
        Boolean approved = (Boolean) request.get("approved");
        String comment = (String) request.get("comment");
        String result = agentService.approveReplenishment(orderId, approved, comment);
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", result);
        return response;
    }

    // ==================== 异常管理接口 ====================

    @GetMapping("/exception/list")
    public List<OutboundException> getExceptionList(@RequestParam(required = false) Integer status) {
        return agentService.getExceptionList(status);
    }

    @PostMapping("/exception/scan")
    public Map<String, Object> scanException() {
        int count = agentService.scanOutboundExceptions();
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "扫描完成，发现 " + count + " 条异常");
        return result;
    }

    @PostMapping("/exception/suggestion")
    public Map<String, Object> generateSuggestion(@RequestParam Long exceptionId) {
        String suggestion = agentService.generateExceptionSuggestion(exceptionId);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", suggestion);
        return result;
    }

    @PostMapping("/exception/handle")
    public Map<String, Object> handleException(@RequestBody Map<String, Object> request) {
        Long exceptionId = Long.valueOf(request.get("exceptionId").toString());
        String remark = (String) request.get("remark");
        String result = agentService.handleException(exceptionId, remark);
        Map<String, Object> response = new HashMap<>();
        response.put("success", true);
        response.put("message", result);
        return response;
    }
}