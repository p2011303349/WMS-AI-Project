package com.wms.service;

import com.wms.dto.TaskDTO;
import org.camunda.bpm.engine.RuntimeService;
import org.camunda.bpm.engine.TaskService;
import org.camunda.bpm.engine.runtime.ProcessInstance;
import org.camunda.bpm.engine.task.Task;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
public class WorkflowService {

    @Autowired
    private RuntimeService runtimeService;

    @Autowired
    private TaskService taskService;

    /**
     * 启动补货审批流程
     * @param orderId 补货建议单ID
     * @param applicant 申请人
     * @return 流程实例ID
     */
    public String startReplenishmentApproval(Long orderId, String applicant) {
        Map<String, Object> variables = new HashMap<>();
        variables.put("orderId", orderId);
        variables.put("applicant", applicant);
        variables.put("approved", false);

        ProcessInstance processInstance = runtimeService
                .startProcessInstanceByKey("replenishment-approval",
                        String.valueOf(orderId), variables);

        return processInstance.getId();
    }

    /**
     * 获取用户的待办任务
     * @param assignee 用户ID
     * @return 任务列表（DTO）
     */
    public List<TaskDTO> getTasksByAssignee(String assignee) {
        List<Task> tasks = taskService.createTaskQuery()
                .taskAssignee(assignee)
                .orderByTaskCreateTime()
                .desc()
                .list();

        return tasks.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * 获取候选组的任务
     * @param candidateGroup 候选组（manager/director）
     * @return 任务列表（DTO）
     */
    public List<TaskDTO> getTasksByCandidateGroup(String candidateGroup) {
        List<Task> tasks = taskService.createTaskQuery()
                .taskCandidateGroup(candidateGroup)
                .orderByTaskCreateTime()
                .desc()
                .list();

        return tasks.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    /**
     * 认领任务
     * @param taskId 任务ID
     * @param userId 用户ID
     */
    public void claimTask(String taskId, String userId) {
        taskService.claim(taskId, userId);
    }

    /**
     * 完成任务审批
     * @param taskId 任务ID
     * @param approved 是否通过
     * @param comment 审批意见
     */
    public void completeTask(String taskId, boolean approved, String comment) {
        Map<String, Object> variables = new HashMap<>();
        variables.put("approved", approved);
        variables.put("comment", comment);
        taskService.complete(taskId, variables);
    }

    /**
     * 获取流程变量
     * @param processInstanceId 流程实例ID
     * @param variableName 变量名
     * @return 变量值
     */
    public Object getProcessVariable(String processInstanceId, String variableName) {
        return runtimeService.getVariable(processInstanceId, variableName);
    }
    /**
     * 完成任务审批
     */
    public void approveTask(String taskId, boolean approved, String comment) {
        Map<String, Object> variables = new HashMap<>();
        variables.put("approved", approved);
        variables.put("comment", comment);
        taskService.complete(taskId, variables);
    }
    /**
     * 转换 Task 为 TaskDTO
     */
    private TaskDTO convertToDTO(Task task) {
        if (task == null) {
            return null;
        }
        TaskDTO dto = new TaskDTO();
        dto.setId(task.getId());
        dto.setName(task.getName());
        dto.setAssignee(task.getAssignee());
        dto.setProcessInstanceId(task.getProcessInstanceId());
        dto.setCreateTime(task.getCreateTime());
        dto.setTaskDefinitionKey(task.getTaskDefinitionKey());
        dto.setExecutionId(task.getExecutionId());
        dto.setProcessDefinitionId(task.getProcessDefinitionId());
        dto.setPriority(task.getPriority());
        dto.setDueDate(task.getDueDate());
        dto.setDescription(task.getDescription());
        return dto;
    }
}