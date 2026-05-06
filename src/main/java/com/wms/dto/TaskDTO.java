package com.wms.dto;

import lombok.Data;
import java.util.Date;

@Data
public class TaskDTO {
    private String id;
    private String name;
    private String assignee;
    private String processInstanceId;
    private Date createTime;
    private String taskDefinitionKey;
    private String executionId;
    private String processDefinitionId;
    private Integer priority;
    private Date dueDate;
    private String description;
}