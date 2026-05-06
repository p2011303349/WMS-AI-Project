package com.wms.config;

import com.wms.service.AiAgentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
@EnableScheduling
public class AgentScheduler {

    @Autowired
    private AiAgentService aiAgentService;

    /**
     * 每小时执行一次智能补货扫描
     */
    @Scheduled(cron = "0 0 * * * ?")
    public void scheduledReplenishment() {
        System.out.println("定时任务：执行智能补货扫描");
        aiAgentService.autoReplenishment();
    }

    /**
     * 每30分钟执行一次异常扫描
     */
    @Scheduled(cron = "0 */30 * * * ?")
    public void scheduledExceptionScan() {
        System.out.println("定时任务：执行异常出库扫描");
        aiAgentService.scanOutboundExceptions();
    }
}