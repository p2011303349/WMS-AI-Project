package com.wms.controller;

import com.wms.dto.TaskDTO;
import com.wms.service.WorkflowService;
import org.camunda.bpm.engine.runtime.ProcessInstance;
import org.camunda.bpm.engine.task.Task;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/workflow")
public class WorkflowController {

    @Autowired
    private WorkflowService workflowService;

    /**
     * 启动补货审批流程
     */
    @PostMapping("/replenishment/start")
    public Map<String, Object> startReplenishmentApproval(
            @RequestParam Long orderId,
            @RequestParam(defaultValue = "system") String applicant) {

        String processInstanceId = workflowService.startReplenishmentApproval(orderId, applicant);

        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("processInstanceId", processInstanceId);
        return result;
    }

    /**
     * 获取待办任务
     */
    @GetMapping("/tasks")
    public List<TaskDTO> getTasks(@RequestParam(required = false) String assignee,
                                  @RequestParam(required = false) String candidateGroup) {
        if (assignee != null && !assignee.isEmpty()) {
            return workflowService.getTasksByAssignee(assignee);
        } else if (candidateGroup != null && !candidateGroup.isEmpty()) {
            return workflowService.getTasksByCandidateGroup(candidateGroup);
        }
        return List.of();
    }

    /**
     * 认领任务
     */
    @PostMapping("/task/claim")
    public Map<String, Object> claimTask(@RequestParam String taskId,
                                         @RequestParam String userId) {
        workflowService.claimTask(taskId, userId);
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "任务已认领");
        return result;
    }

    /**
     * 完成任务审批
     */
    @PostMapping("/task/complete")
    public Map<String, Object> completeTask(@RequestBody Map<String, Object> request) {
        String taskId = (String) request.get("taskId");
        Boolean approved = (Boolean) request.get("approved");
        String comment = (String) request.get("comment");

        workflowService.completeTask(taskId, approved, comment);

        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", approved ? "审批通过" : "审批驳回");
        return result;
    }
}