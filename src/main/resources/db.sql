/*
SQLyog Community v13.1.6 (64 bit)
MySQL - 8.4.4 : Database - wms_tenant
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/`wms_tenant` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `wms_tenant`;

/*Table structure for table `act_ge_bytearray` */

DROP TABLE IF EXISTS `act_ge_bytearray`;

CREATE TABLE `act_ge_bytearray` (
                                    `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                    `REV_` int DEFAULT NULL,
                                    `NAME_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                    `DEPLOYMENT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                    `BYTES_` longblob,
                                    `GENERATED_` tinyint DEFAULT NULL,
                                    `TENANT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                    `TYPE_` int DEFAULT NULL,
                                    `CREATE_TIME_` datetime DEFAULT NULL,
                                    `ROOT_PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                    `REMOVAL_TIME_` datetime DEFAULT NULL,
                                    PRIMARY KEY (`ID_`),
                                    KEY `ACT_FK_BYTEARR_DEPL` (`DEPLOYMENT_ID_`),
                                    KEY `ACT_IDX_BYTEARRAY_ROOT_PI` (`ROOT_PROC_INST_ID_`),
                                    KEY `ACT_IDX_BYTEARRAY_RM_TIME` (`REMOVAL_TIME_`),
                                    KEY `ACT_IDX_BYTEARRAY_NAME` (`NAME_`),
                                    CONSTRAINT `ACT_FK_BYTEARR_DEPL` FOREIGN KEY (`DEPLOYMENT_ID_`) REFERENCES `act_re_deployment` (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*Data for the table `act_ge_bytearray` */

insert  into `act_ge_bytearray`(`ID_`,`REV_`,`NAME_`,`DEPLOYMENT_ID_`,`BYTES_`,`GENERATED_`,`TENANT_ID_`,`TYPE_`,`CREATE_TIME_`,`ROOT_PROC_INST_ID_`,`REMOVAL_TIME_`) values
    ('e0fbe3c6-4398-11f1-a600-c894025bbc03',1,'D:\\project\\wms-tenant-starter\\target\\classes\\processes\\replenishment-approval.bpmn','e0f999d5-4398-11f1-a600-c894025bbc03','<?xml version=\"1.0\" encoding=\"UTF-8\"?>\r\n<bpmn:definitions\r\n    xmlns:bpmn=\"http://www.omg.org/spec/BPMN/20100524/MODEL\"\r\n    xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"\r\n    xmlns:camunda=\"http://camunda.org/schema/1.0/bpmn\"\r\n    id=\"Definitions_1\"\r\n    targetNamespace=\"http://bpmn.io/schema/bpmn\">\r\n\r\n  <bpmn:process id=\"replenishment-approval\" name=\"补货审批流程\" isExecutable=\"true\" camunda:historyTimeToLive=\"30\">\r\n\r\n    <!-- 开始事件 -->\r\n    <bpmn:startEvent id=\"StartEvent\" name=\"提交补货申请\">\r\n      <bpmn:outgoing>Flow_to_manager</bpmn:outgoing>\r\n    </bpmn:startEvent>\r\n\r\n    <!-- 主管审批 -->\r\n    <bpmn:userTask id=\"ManagerApprove\" name=\"主管审批\" camunda:candidateGroups=\"manager\">\r\n      <bpmn:incoming>Flow_to_manager</bpmn:incoming>\r\n      <bpmn:outgoing>Flow_to_director</bpmn:outgoing>\r\n    </bpmn:userTask>\r\n\r\n    <!-- 经理审批 -->\r\n    <bpmn:userTask id=\"DirectorApprove\" name=\"经理审批\" camunda:candidateGroups=\"director\">\r\n      <bpmn:incoming>Flow_to_director</bpmn:incoming>\r\n      <bpmn:outgoing>Flow_to_gateway</bpmn:outgoing>\r\n    </bpmn:userTask>\r\n\r\n    <!-- 排他网关 -->\r\n    <bpmn:exclusiveGateway id=\"ExclusiveGateway\" name=\"审批结果判断\">\r\n      <bpmn:incoming>Flow_to_gateway</bpmn:incoming>\r\n      <bpmn:outgoing>Flow_approved</bpmn:outgoing>\r\n      <bpmn:outgoing>Flow_rejected</bpmn:outgoing>\r\n    </bpmn:exclusiveGateway>\r\n\r\n    <!-- 审批通过 -->\r\n    <bpmn:endEvent id=\"ApprovedEnd\" name=\"审批通过\">\r\n      <bpmn:incoming>Flow_approved</bpmn:incoming>\r\n    </bpmn:endEvent>\r\n\r\n    <!-- 审批驳回 -->\r\n    <bpmn:endEvent id=\"RejectedEnd\" name=\"审批驳回\">\r\n      <bpmn:incoming>Flow_rejected</bpmn:incoming>\r\n    </bpmn:endEvent>\r\n\r\n    <!-- 连线 -->\r\n    <bpmn:sequenceFlow id=\"Flow_to_manager\" sourceRef=\"StartEvent\" targetRef=\"ManagerApprove\" />\r\n    <bpmn:sequenceFlow id=\"Flow_to_director\" sourceRef=\"ManagerApprove\" targetRef=\"DirectorApprove\" />\r\n    <bpmn:sequenceFlow id=\"Flow_to_gateway\" sourceRef=\"DirectorApprove\" targetRef=\"ExclusiveGateway\" />\r\n\r\n    <bpmn:sequenceFlow id=\"Flow_approved\" sourceRef=\"ExclusiveGateway\" targetRef=\"ApprovedEnd\">\r\n      <bpmn:conditionExpression xsi:type=\"bpmn:tFormalExpression\">\r\n        ${approved == true}\r\n      </bpmn:conditionExpression>\r\n    </bpmn:sequenceFlow>\r\n\r\n    <bpmn:sequenceFlow id=\"Flow_rejected\" sourceRef=\"ExclusiveGateway\" targetRef=\"RejectedEnd\">\r\n      <bpmn:conditionExpression xsi:type=\"bpmn:tFormalExpression\">\r\n        ${approved == false}\r\n      </bpmn:conditionExpression>\r\n    </bpmn:sequenceFlow>\r\n\r\n  </bpmn:process>\r\n</bpmn:definitions>',0,NULL,1,'2026-04-29 14:58:51',NULL,NULL);

/*Table structure for table `act_ge_property` */

DROP TABLE IF EXISTS `act_ge_property`;

CREATE TABLE `act_ge_property` (
                                   `NAME_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                   `VALUE_` varchar(300) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `REV_` int DEFAULT NULL,
                                   PRIMARY KEY (`NAME_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*Data for the table `act_ge_property` */

insert  into `act_ge_property`(`NAME_`,`VALUE_`,`REV_`) values
                                                            ('camunda.installation.id','2de33319-bcfd-4b39-af99-9077e3f8ea8a',1),
                                                            ('deployment.lock','0',1),
                                                            ('history.cleanup.job.lock','0',1),
                                                            ('historyLevel','3',1),
                                                            ('installationId.lock','0',1),
                                                            ('next.dbid','1',1),
                                                            ('schema.history','create(fox)',1),
                                                            ('schema.version','fox',1),
                                                            ('startup.lock','0',1);

/*Table structure for table `act_ge_schema_log` */

DROP TABLE IF EXISTS `act_ge_schema_log`;

CREATE TABLE `act_ge_schema_log` (
                                     `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                     `TIMESTAMP_` datetime DEFAULT NULL,
                                     `VERSION_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                     PRIMARY KEY (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*Data for the table `act_ge_schema_log` */

insert  into `act_ge_schema_log`(`ID_`,`TIMESTAMP_`,`VERSION_`) values
    ('0','2026-04-29 14:58:43','7.24.0');

/*Table structure for table `act_hi_actinst` */

DROP TABLE IF EXISTS `act_hi_actinst`;

CREATE TABLE `act_hi_actinst` (
                                  `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                  `PARENT_ACT_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `PROC_DEF_KEY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `PROC_DEF_ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                  `ROOT_PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                  `EXECUTION_ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                  `ACT_ID_` varchar(255) COLLATE utf8mb3_bin NOT NULL,
                                  `TASK_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `CALL_PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `CALL_CASE_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `ACT_NAME_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `ACT_TYPE_` varchar(255) COLLATE utf8mb3_bin NOT NULL,
                                  `ASSIGNEE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `START_TIME_` datetime NOT NULL,
                                  `END_TIME_` datetime DEFAULT NULL,
                                  `DURATION_` bigint DEFAULT NULL,
                                  `ACT_INST_STATE_` int DEFAULT NULL,
                                  `SEQUENCE_COUNTER_` bigint DEFAULT NULL,
                                  `TENANT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `REMOVAL_TIME_` datetime DEFAULT NULL,
                                  PRIMARY KEY (`ID_`),
                                  KEY `ACT_IDX_HI_ACTINST_ROOT_PI` (`ROOT_PROC_INST_ID_`),
                                  KEY `ACT_IDX_HI_ACT_INST_START_END` (`START_TIME_`,`END_TIME_`),
                                  KEY `ACT_IDX_HI_ACT_INST_END` (`END_TIME_`),
                                  KEY `ACT_IDX_HI_ACT_INST_PROCINST` (`PROC_INST_ID_`,`ACT_ID_`),
                                  KEY `ACT_IDX_HI_ACT_INST_COMP` (`EXECUTION_ID_`,`ACT_ID_`,`END_TIME_`,`ID_`),
                                  KEY `ACT_IDX_HI_ACT_INST_STATS` (`PROC_DEF_ID_`,`PROC_INST_ID_`,`ACT_ID_`,`END_TIME_`,`ACT_INST_STATE_`),
                                  KEY `ACT_IDX_HI_ACT_INST_TENANT_ID` (`TENANT_ID_`),
                                  KEY `ACT_IDX_HI_ACT_INST_PROC_DEF_KEY` (`PROC_DEF_KEY_`),
                                  KEY `ACT_IDX_HI_AI_PDEFID_END_TIME` (`PROC_DEF_ID_`,`END_TIME_`),
                                  KEY `ACT_IDX_HI_ACT_INST_RM_TIME` (`REMOVAL_TIME_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*Data for the table `act_hi_actinst` */

insert  into `act_hi_actinst`(`ID_`,`PARENT_ACT_INST_ID_`,`PROC_DEF_KEY_`,`PROC_DEF_ID_`,`ROOT_PROC_INST_ID_`,`PROC_INST_ID_`,`EXECUTION_ID_`,`ACT_ID_`,`TASK_ID_`,`CALL_PROC_INST_ID_`,`CALL_CASE_INST_ID_`,`ACT_NAME_`,`ACT_TYPE_`,`ASSIGNEE_`,`START_TIME_`,`END_TIME_`,`DURATION_`,`ACT_INST_STATE_`,`SEQUENCE_COUNTER_`,`TENANT_ID_`,`REMOVAL_TIME_`) values
                                                                                                                                                                                                                                                                                                                                                               ('ApprovedEnd:2b9aa3fc-439c-11f1-a8d7-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03','replenishment-approval','replenishment-approval:1:e11deab7-4398-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03','ApprovedEnd',NULL,NULL,NULL,'审批通过','noneEndEvent',NULL,'2026-04-29 15:22:25','2026-04-29 15:22:25',0,1,9,NULL,'2026-05-29 15:22:25'),
                                                                                                                                                                                                                                                                                                                                                               ('DirectorApprove:192636d5-439c-11f1-a8d7-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03','replenishment-approval','replenishment-approval:1:e11deab7-4398-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03','DirectorApprove','19279666-439c-11f1-a8d7-c894025bbc03',NULL,NULL,'经理审批','userTask',NULL,'2026-04-29 15:21:54','2026-04-29 15:22:25',31071,4,5,NULL,'2026-05-29 15:22:25'),
                                                                                                                                                                                                                                                                                                                                                               ('ExclusiveGateway:2b9aa3fb-439c-11f1-a8d7-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03','replenishment-approval','replenishment-approval:1:e11deab7-4398-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03','ExclusiveGateway',NULL,NULL,NULL,'审批结果判断','exclusiveGateway',NULL,'2026-04-29 15:22:25','2026-04-29 15:22:25',0,4,7,NULL,'2026-05-29 15:22:25'),
                                                                                                                                                                                                                                                                                                                                                               ('ManagerApprove:634ca260-4399-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03','replenishment-approval','replenishment-approval:1:e11deab7-4398-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03','ManagerApprove','634cc971-4399-11f1-a600-c894025bbc03',NULL,NULL,'主管审批','userTask',NULL,'2026-04-29 15:02:30','2026-04-29 15:21:54',1164103,4,3,NULL,'2026-05-29 15:22:25'),
                                                                                                                                                                                                                                                                                                                                                               ('StartEvent:634aa78f-4399-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03','replenishment-approval','replenishment-approval:1:e11deab7-4398-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03','StartEvent',NULL,NULL,NULL,'提交补货申请','startEvent',NULL,'2026-04-29 15:02:30','2026-04-29 15:02:30',12,4,1,NULL,'2026-05-29 15:22:25');

/*Table structure for table `act_hi_attachment` */

DROP TABLE IF EXISTS `act_hi_attachment`;

CREATE TABLE `act_hi_attachment` (
                                     `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                     `REV_` int DEFAULT NULL,
                                     `USER_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                     `NAME_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                     `DESCRIPTION_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
                                     `TYPE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                     `TASK_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                     `ROOT_PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                     `PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                     `URL_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
                                     `CONTENT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                     `TENANT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                     `CREATE_TIME_` datetime DEFAULT NULL,
                                     `REMOVAL_TIME_` datetime DEFAULT NULL,
                                     PRIMARY KEY (`ID_`),
                                     KEY `ACT_IDX_HI_ATTACHMENT_CONTENT` (`CONTENT_ID_`),
                                     KEY `ACT_IDX_HI_ATTACHMENT_ROOT_PI` (`ROOT_PROC_INST_ID_`),
                                     KEY `ACT_IDX_HI_ATTACHMENT_PROCINST` (`PROC_INST_ID_`),
                                     KEY `ACT_IDX_HI_ATTACHMENT_TASK` (`TASK_ID_`),
                                     KEY `ACT_IDX_HI_ATTACHMENT_RM_TIME` (`REMOVAL_TIME_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*Data for the table `act_hi_attachment` */

/*Table structure for table `act_hi_batch` */

DROP TABLE IF EXISTS `act_hi_batch`;

CREATE TABLE `act_hi_batch` (
                                `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                `TYPE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                `TOTAL_JOBS_` int DEFAULT NULL,
                                `JOBS_PER_SEED_` int DEFAULT NULL,
                                `INVOCATIONS_PER_JOB_` int DEFAULT NULL,
                                `SEED_JOB_DEF_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                `MONITOR_JOB_DEF_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                `BATCH_JOB_DEF_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                `TENANT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                `CREATE_USER_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                `START_TIME_` datetime NOT NULL,
                                `END_TIME_` datetime DEFAULT NULL,
                                `REMOVAL_TIME_` datetime DEFAULT NULL,
                                `EXEC_START_TIME_` datetime DEFAULT NULL,
                                PRIMARY KEY (`ID_`),
                                KEY `ACT_HI_BAT_RM_TIME` (`REMOVAL_TIME_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*Data for the table `act_hi_batch` */

/*Table structure for table `act_hi_caseactinst` */

DROP TABLE IF EXISTS `act_hi_caseactinst`;

CREATE TABLE `act_hi_caseactinst` (
                                      `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                      `PARENT_ACT_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                      `CASE_DEF_ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                      `CASE_INST_ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                      `CASE_ACT_ID_` varchar(255) COLLATE utf8mb3_bin NOT NULL,
                                      `TASK_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                      `CALL_PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                      `CALL_CASE_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                      `CASE_ACT_NAME_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                      `CASE_ACT_TYPE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                      `CREATE_TIME_` datetime NOT NULL,
                                      `END_TIME_` datetime DEFAULT NULL,
                                      `DURATION_` bigint DEFAULT NULL,
                                      `STATE_` int DEFAULT NULL,
                                      `REQUIRED_` tinyint(1) DEFAULT NULL,
                                      `TENANT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                      PRIMARY KEY (`ID_`),
                                      KEY `ACT_IDX_HI_CAS_A_I_CREATE` (`CREATE_TIME_`),
                                      KEY `ACT_IDX_HI_CAS_A_I_END` (`END_TIME_`),
                                      KEY `ACT_IDX_HI_CAS_A_I_COMP` (`CASE_ACT_ID_`,`END_TIME_`,`ID_`),
                                      KEY `ACT_IDX_HI_CAS_A_I_CASEINST` (`CASE_INST_ID_`,`CASE_ACT_ID_`),
                                      KEY `ACT_IDX_HI_CAS_A_I_TENANT_ID` (`TENANT_ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*Data for the table `act_hi_caseactinst` */

/*Table structure for table `act_hi_caseinst` */

DROP TABLE IF EXISTS `act_hi_caseinst`;

CREATE TABLE `act_hi_caseinst` (
                                   `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                   `CASE_INST_ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                   `BUSINESS_KEY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `CASE_DEF_ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                   `CREATE_TIME_` datetime NOT NULL,
                                   `CLOSE_TIME_` datetime DEFAULT NULL,
                                   `DURATION_` bigint DEFAULT NULL,
                                   `STATE_` int DEFAULT NULL,
                                   `CREATE_USER_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `SUPER_CASE_INSTANCE_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `SUPER_PROCESS_INSTANCE_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `TENANT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                   PRIMARY KEY (`ID_`),
                                   UNIQUE KEY `CASE_INST_ID_` (`CASE_INST_ID_`),
                                   KEY `ACT_IDX_HI_CAS_I_CLOSE` (`CLOSE_TIME_`),
                                   KEY `ACT_IDX_HI_CAS_I_BUSKEY` (`BUSINESS_KEY_`),
                                   KEY `ACT_IDX_HI_CAS_I_TENANT_ID` (`TENANT_ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*Data for the table `act_hi_caseinst` */

/*Table structure for table `act_hi_comment` */

DROP TABLE IF EXISTS `act_hi_comment`;

CREATE TABLE `act_hi_comment` (
                                  `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                  `TYPE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `TIME_` datetime NOT NULL,
                                  `USER_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `TASK_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `ROOT_PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `ACTION_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `MESSAGE_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `FULL_MSG_` longblob,
                                  `TENANT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `REMOVAL_TIME_` datetime DEFAULT NULL,
                                  `REV_` int NOT NULL DEFAULT '1',
                                  PRIMARY KEY (`ID_`),
                                  KEY `ACT_IDX_HI_COMMENT_TASK` (`TASK_ID_`),
                                  KEY `ACT_IDX_HI_COMMENT_ROOT_PI` (`ROOT_PROC_INST_ID_`),
                                  KEY `ACT_IDX_HI_COMMENT_PROCINST` (`PROC_INST_ID_`),
                                  KEY `ACT_IDX_HI_COMMENT_RM_TIME` (`REMOVAL_TIME_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*Data for the table `act_hi_comment` */

/*Table structure for table `act_hi_dec_in` */

DROP TABLE IF EXISTS `act_hi_dec_in`;

CREATE TABLE `act_hi_dec_in` (
                                 `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                 `DEC_INST_ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                 `CLAUSE_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `CLAUSE_NAME_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `VAR_TYPE_` varchar(100) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `BYTEARRAY_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `DOUBLE_` double DEFAULT NULL,
                                 `LONG_` bigint DEFAULT NULL,
                                 `TEXT_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `TEXT2_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `TENANT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `CREATE_TIME_` datetime DEFAULT NULL,
                                 `ROOT_PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `REMOVAL_TIME_` datetime DEFAULT NULL,
                                 PRIMARY KEY (`ID_`),
                                 KEY `ACT_IDX_HI_DEC_IN_INST` (`DEC_INST_ID_`),
                                 KEY `ACT_IDX_HI_DEC_IN_CLAUSE` (`DEC_INST_ID_`,`CLAUSE_ID_`),
                                 KEY `ACT_IDX_HI_DEC_IN_ROOT_PI` (`ROOT_PROC_INST_ID_`),
                                 KEY `ACT_IDX_HI_DEC_IN_RM_TIME` (`REMOVAL_TIME_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*Data for the table `act_hi_dec_in` */

/*Table structure for table `act_hi_dec_out` */

DROP TABLE IF EXISTS `act_hi_dec_out`;

CREATE TABLE `act_hi_dec_out` (
                                  `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                  `DEC_INST_ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                  `CLAUSE_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `CLAUSE_NAME_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `RULE_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `RULE_ORDER_` int DEFAULT NULL,
                                  `VAR_NAME_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `VAR_TYPE_` varchar(100) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `BYTEARRAY_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `DOUBLE_` double DEFAULT NULL,
                                  `LONG_` bigint DEFAULT NULL,
                                  `TEXT_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `TEXT2_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `TENANT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `CREATE_TIME_` datetime DEFAULT NULL,
                                  `ROOT_PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `REMOVAL_TIME_` datetime DEFAULT NULL,
                                  PRIMARY KEY (`ID_`),
                                  KEY `ACT_IDX_HI_DEC_OUT_INST` (`DEC_INST_ID_`),
                                  KEY `ACT_IDX_HI_DEC_OUT_RULE` (`RULE_ORDER_`,`CLAUSE_ID_`),
                                  KEY `ACT_IDX_HI_DEC_OUT_ROOT_PI` (`ROOT_PROC_INST_ID_`),
                                  KEY `ACT_IDX_HI_DEC_OUT_RM_TIME` (`REMOVAL_TIME_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*Data for the table `act_hi_dec_out` */

/*Table structure for table `act_hi_decinst` */

DROP TABLE IF EXISTS `act_hi_decinst`;

CREATE TABLE `act_hi_decinst` (
                                  `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                  `DEC_DEF_ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                  `DEC_DEF_KEY_` varchar(255) COLLATE utf8mb3_bin NOT NULL,
                                  `DEC_DEF_NAME_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `PROC_DEF_KEY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `PROC_DEF_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `CASE_DEF_KEY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `CASE_DEF_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `CASE_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `ACT_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `ACT_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `EVAL_TIME_` datetime NOT NULL,
                                  `REMOVAL_TIME_` datetime DEFAULT NULL,
                                  `COLLECT_VALUE_` double DEFAULT NULL,
                                  `USER_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `ROOT_DEC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `ROOT_PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `DEC_REQ_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `DEC_REQ_KEY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `TENANT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                  PRIMARY KEY (`ID_`),
                                  KEY `ACT_IDX_HI_DEC_INST_ID` (`DEC_DEF_ID_`),
                                  KEY `ACT_IDX_HI_DEC_INST_KEY` (`DEC_DEF_KEY_`),
                                  KEY `ACT_IDX_HI_DEC_INST_PI` (`PROC_INST_ID_`),
                                  KEY `ACT_IDX_HI_DEC_INST_CI` (`CASE_INST_ID_`),
                                  KEY `ACT_IDX_HI_DEC_INST_ACT` (`ACT_ID_`),
                                  KEY `ACT_IDX_HI_DEC_INST_ACT_INST` (`ACT_INST_ID_`),
                                  KEY `ACT_IDX_HI_DEC_INST_TIME` (`EVAL_TIME_`),
                                  KEY `ACT_IDX_HI_DEC_INST_TENANT_ID` (`TENANT_ID_`),
                                  KEY `ACT_IDX_HI_DEC_INST_ROOT_ID` (`ROOT_DEC_INST_ID_`),
                                  KEY `ACT_IDX_HI_DEC_INST_REQ_ID` (`DEC_REQ_ID_`),
                                  KEY `ACT_IDX_HI_DEC_INST_REQ_KEY` (`DEC_REQ_KEY_`),
                                  KEY `ACT_IDX_HI_DEC_INST_ROOT_PI` (`ROOT_PROC_INST_ID_`),
                                  KEY `ACT_IDX_HI_DEC_INST_RM_TIME` (`REMOVAL_TIME_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*Data for the table `act_hi_decinst` */

/*Table structure for table `act_hi_detail` */

DROP TABLE IF EXISTS `act_hi_detail`;

CREATE TABLE `act_hi_detail` (
                                 `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                 `TYPE_` varchar(255) COLLATE utf8mb3_bin NOT NULL,
                                 `PROC_DEF_KEY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `PROC_DEF_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `ROOT_PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `EXECUTION_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `CASE_DEF_KEY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `CASE_DEF_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `CASE_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `CASE_EXECUTION_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `TASK_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `ACT_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `VAR_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `NAME_` varchar(255) COLLATE utf8mb3_bin NOT NULL,
                                 `VAR_TYPE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `REV_` int DEFAULT NULL,
                                 `TIME_` datetime NOT NULL,
                                 `BYTEARRAY_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `DOUBLE_` double DEFAULT NULL,
                                 `LONG_` bigint DEFAULT NULL,
                                 `TEXT_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `TEXT2_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `SEQUENCE_COUNTER_` bigint DEFAULT NULL,
                                 `TENANT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `OPERATION_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `REMOVAL_TIME_` datetime DEFAULT NULL,
                                 `INITIAL_` tinyint(1) DEFAULT NULL,
                                 PRIMARY KEY (`ID_`),
                                 KEY `ACT_IDX_HI_DETAIL_ROOT_PI` (`ROOT_PROC_INST_ID_`),
                                 KEY `ACT_IDX_HI_DETAIL_PROC_INST` (`PROC_INST_ID_`),
                                 KEY `ACT_IDX_HI_DETAIL_ACT_INST` (`ACT_INST_ID_`),
                                 KEY `ACT_IDX_HI_DETAIL_CASE_INST` (`CASE_INST_ID_`),
                                 KEY `ACT_IDX_HI_DETAIL_CASE_EXEC` (`CASE_EXECUTION_ID_`),
                                 KEY `ACT_IDX_HI_DETAIL_TIME` (`TIME_`),
                                 KEY `ACT_IDX_HI_DETAIL_NAME` (`NAME_`),
                                 KEY `ACT_IDX_HI_DETAIL_TASK_ID` (`TASK_ID_`),
                                 KEY `ACT_IDX_HI_DETAIL_TENANT_ID` (`TENANT_ID_`),
                                 KEY `ACT_IDX_HI_DETAIL_PROC_DEF_KEY` (`PROC_DEF_KEY_`),
                                 KEY `ACT_IDX_HI_DETAIL_BYTEAR` (`BYTEARRAY_ID_`),
                                 KEY `ACT_IDX_HI_DETAIL_RM_TIME` (`REMOVAL_TIME_`),
                                 KEY `ACT_IDX_HI_DETAIL_TASK_BYTEAR` (`BYTEARRAY_ID_`,`TASK_ID_`),
                                 KEY `ACT_IDX_HI_DETAIL_VAR_INST_ID` (`VAR_INST_ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*Data for the table `act_hi_detail` */

insert  into `act_hi_detail`(`ID_`,`TYPE_`,`PROC_DEF_KEY_`,`PROC_DEF_ID_`,`ROOT_PROC_INST_ID_`,`PROC_INST_ID_`,`EXECUTION_ID_`,`CASE_DEF_KEY_`,`CASE_DEF_ID_`,`CASE_INST_ID_`,`CASE_EXECUTION_ID_`,`TASK_ID_`,`ACT_INST_ID_`,`VAR_INST_ID_`,`NAME_`,`VAR_TYPE_`,`REV_`,`TIME_`,`BYTEARRAY_ID_`,`DOUBLE_`,`LONG_`,`TEXT_`,`TEXT2_`,`SEQUENCE_COUNTER_`,`TENANT_ID_`,`OPERATION_ID_`,`REMOVAL_TIME_`,`INITIAL_`) values
                                                                                                                                                                                                                                                                                                                                                                                                                   ('191c4bc2-439c-11f1-a8d7-c894025bbc03','VariableUpdate','replenishment-approval','replenishment-approval:1:e11deab7-4398-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03',NULL,NULL,NULL,NULL,NULL,'ManagerApprove:634ca260-4399-11f1-a600-c894025bbc03','6345c589-4399-11f1-a600-c894025bbc03','approved','boolean',1,'2026-04-29 15:21:54',NULL,NULL,1,NULL,NULL,2,NULL,NULL,'2026-05-29 15:22:25',0),
                                                                                                                                                                                                                                                                                                                                                                                                                   ('191ff544-439c-11f1-a8d7-c894025bbc03','VariableUpdate','replenishment-approval','replenishment-approval:1:e11deab7-4398-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03',NULL,NULL,NULL,NULL,NULL,'ManagerApprove:634ca260-4399-11f1-a600-c894025bbc03','191d8443-439c-11f1-a8d7-c894025bbc03','comment','string',0,'2026-04-29 15:21:54',NULL,NULL,NULL,'审批通过',NULL,1,NULL,NULL,'2026-05-29 15:22:25',0),
                                                                                                                                                                                                                                                                                                                                                                                                                   ('2b994469-439c-11f1-a8d7-c894025bbc03','VariableUpdate','replenishment-approval','replenishment-approval:1:e11deab7-4398-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03',NULL,NULL,NULL,NULL,NULL,'DirectorApprove:192636d5-439c-11f1-a8d7-c894025bbc03','6345c589-4399-11f1-a600-c894025bbc03','approved','boolean',2,'2026-04-29 15:22:25',NULL,NULL,1,NULL,NULL,3,NULL,NULL,'2026-05-29 15:22:25',0),
                                                                                                                                                                                                                                                                                                                                                                                                                   ('2b99b99a-439c-11f1-a8d7-c894025bbc03','VariableUpdate','replenishment-approval','replenishment-approval:1:e11deab7-4398-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03',NULL,NULL,NULL,NULL,NULL,'DirectorApprove:192636d5-439c-11f1-a8d7-c894025bbc03','191d8443-439c-11f1-a8d7-c894025bbc03','comment','string',1,'2026-04-29 15:22:25',NULL,NULL,NULL,'审批通过',NULL,2,NULL,NULL,'2026-05-29 15:22:25',0),
                                                                                                                                                                                                                                                                                                                                                                                                                   ('6347251a-4399-11f1-a600-c894025bbc03','VariableUpdate','replenishment-approval','replenishment-approval:1:e11deab7-4398-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03',NULL,NULL,NULL,NULL,NULL,'6343a2a8-4399-11f1-a600-c894025bbc03','6345c589-4399-11f1-a600-c894025bbc03','approved','boolean',0,'2026-04-29 15:02:30',NULL,NULL,0,NULL,NULL,1,NULL,NULL,'2026-05-29 15:22:25',1),
                                                                                                                                                                                                                                                                                                                                                                                                                   ('6349e43c-4399-11f1-a600-c894025bbc03','VariableUpdate','replenishment-approval','replenishment-approval:1:e11deab7-4398-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03',NULL,NULL,NULL,NULL,NULL,'6343a2a8-4399-11f1-a600-c894025bbc03','6349e43b-4399-11f1-a600-c894025bbc03','orderId','long',0,'2026-04-29 15:02:30',NULL,NULL,3,'3',NULL,1,NULL,NULL,'2026-05-29 15:22:25',1),
                                                                                                                                                                                                                                                                                                                                                                                                                   ('6349e43e-4399-11f1-a600-c894025bbc03','VariableUpdate','replenishment-approval','replenishment-approval:1:e11deab7-4398-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03',NULL,NULL,NULL,NULL,NULL,'6343a2a8-4399-11f1-a600-c894025bbc03','6349e43d-4399-11f1-a600-c894025bbc03','applicant','string',0,'2026-04-29 15:02:30',NULL,NULL,NULL,'system',NULL,1,NULL,NULL,'2026-05-29 15:22:25',1);

/*Table structure for table `act_hi_ext_task_log` */

DROP TABLE IF EXISTS `act_hi_ext_task_log`;

CREATE TABLE `act_hi_ext_task_log` (
                                       `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                       `TIMESTAMP_` timestamp NOT NULL,
                                       `EXT_TASK_ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                       `RETRIES_` int DEFAULT NULL,
                                       `TOPIC_NAME_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                       `WORKER_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                       `PRIORITY_` bigint NOT NULL DEFAULT '0',
                                       `ERROR_MSG_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
                                       `ERROR_DETAILS_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                       `ACT_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                       `ACT_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                       `EXECUTION_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                       `ROOT_PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                       `PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                       `PROC_DEF_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                       `PROC_DEF_KEY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                       `TENANT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                       `STATE_` int DEFAULT NULL,
                                       `REV_` int DEFAULT NULL,
                                       `REMOVAL_TIME_` datetime DEFAULT NULL,
                                       PRIMARY KEY (`ID_`),
                                       KEY `ACT_HI_EXT_TASK_LOG_ROOT_PI` (`ROOT_PROC_INST_ID_`),
                                       KEY `ACT_HI_EXT_TASK_LOG_PROCINST` (`PROC_INST_ID_`),
                                       KEY `ACT_HI_EXT_TASK_LOG_PROCDEF` (`PROC_DEF_ID_`),
                                       KEY `ACT_HI_EXT_TASK_LOG_PROC_DEF_KEY` (`PROC_DEF_KEY_`),
                                       KEY `ACT_HI_EXT_TASK_LOG_TENANT_ID` (`TENANT_ID_`),
                                       KEY `ACT_IDX_HI_EXTTASKLOG_ERRORDET` (`ERROR_DETAILS_ID_`),
                                       KEY `ACT_HI_EXT_TASK_LOG_RM_TIME` (`REMOVAL_TIME_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*Data for the table `act_hi_ext_task_log` */

/*Table structure for table `act_hi_identitylink` */

DROP TABLE IF EXISTS `act_hi_identitylink`;

CREATE TABLE `act_hi_identitylink` (
                                       `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                       `TIMESTAMP_` timestamp NOT NULL,
                                       `TYPE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                       `USER_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                       `GROUP_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                       `TASK_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                       `ROOT_PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                       `PROC_DEF_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                       `OPERATION_TYPE_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                       `ASSIGNER_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                       `PROC_DEF_KEY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                       `TENANT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                       `REMOVAL_TIME_` datetime DEFAULT NULL,
                                       PRIMARY KEY (`ID_`),
                                       KEY `ACT_IDX_HI_IDENT_LNK_ROOT_PI` (`ROOT_PROC_INST_ID_`),
                                       KEY `ACT_IDX_HI_IDENT_LNK_USER` (`USER_ID_`),
                                       KEY `ACT_IDX_HI_IDENT_LNK_GROUP` (`GROUP_ID_`),
                                       KEY `ACT_IDX_HI_IDENT_LNK_TENANT_ID` (`TENANT_ID_`),
                                       KEY `ACT_IDX_HI_IDENT_LNK_PROC_DEF_KEY` (`PROC_DEF_KEY_`),
                                       KEY `ACT_IDX_HI_IDENT_LINK_TASK` (`TASK_ID_`),
                                       KEY `ACT_IDX_HI_IDENT_LINK_RM_TIME` (`REMOVAL_TIME_`),
                                       KEY `ACT_IDX_HI_IDENT_LNK_TIMESTAMP` (`TIMESTAMP_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*Data for the table `act_hi_identitylink` */

insert  into `act_hi_identitylink`(`ID_`,`TIMESTAMP_`,`TYPE_`,`USER_ID_`,`GROUP_ID_`,`TASK_ID_`,`ROOT_PROC_INST_ID_`,`PROC_DEF_ID_`,`OPERATION_TYPE_`,`ASSIGNER_ID_`,`PROC_DEF_KEY_`,`TENANT_ID_`,`REMOVAL_TIME_`) values
                                                                                                                                                                                                                       ('19279668-439c-11f1-a8d7-c894025bbc03','2026-04-29 15:21:54','candidate',NULL,'director','19279666-439c-11f1-a8d7-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03','replenishment-approval:1:e11deab7-4398-11f1-a600-c894025bbc03','add',NULL,'replenishment-approval',NULL,'2026-05-29 15:22:25'),
                                                                                                                                                                                                                       ('634ddae3-4399-11f1-a600-c894025bbc03','2026-04-29 15:02:30','candidate',NULL,'manager','634cc971-4399-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03','replenishment-approval:1:e11deab7-4398-11f1-a600-c894025bbc03','add',NULL,'replenishment-approval',NULL,'2026-05-29 15:22:25');

/*Table structure for table `act_hi_incident` */

DROP TABLE IF EXISTS `act_hi_incident`;

CREATE TABLE `act_hi_incident` (
                                   `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                   `PROC_DEF_KEY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `PROC_DEF_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `ROOT_PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `EXECUTION_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `CREATE_TIME_` timestamp NOT NULL,
                                   `END_TIME_` timestamp NULL DEFAULT NULL,
                                   `INCIDENT_MSG_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `INCIDENT_TYPE_` varchar(255) COLLATE utf8mb3_bin NOT NULL,
                                   `ACTIVITY_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `FAILED_ACTIVITY_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `CAUSE_INCIDENT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `ROOT_CAUSE_INCIDENT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `CONFIGURATION_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `HISTORY_CONFIGURATION_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `INCIDENT_STATE_` int DEFAULT NULL,
                                   `TENANT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `JOB_DEF_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `ANNOTATION_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `REMOVAL_TIME_` datetime DEFAULT NULL,
                                   PRIMARY KEY (`ID_`),
                                   KEY `ACT_IDX_HI_INCIDENT_TENANT_ID` (`TENANT_ID_`),
                                   KEY `ACT_IDX_HI_INCIDENT_PROC_DEF_KEY` (`PROC_DEF_KEY_`),
                                   KEY `ACT_IDX_HI_INCIDENT_ROOT_PI` (`ROOT_PROC_INST_ID_`),
                                   KEY `ACT_IDX_HI_INCIDENT_PROCINST` (`PROC_INST_ID_`),
                                   KEY `ACT_IDX_HI_INCIDENT_RM_TIME` (`REMOVAL_TIME_`),
                                   KEY `ACT_IDX_HI_INCIDENT_CREATE_TIME` (`CREATE_TIME_`),
                                   KEY `ACT_IDX_HI_INCIDENT_END_TIME` (`END_TIME_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*Data for the table `act_hi_incident` */

/*Table structure for table `act_hi_job_log` */

DROP TABLE IF EXISTS `act_hi_job_log`;

CREATE TABLE `act_hi_job_log` (
                                  `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                  `TIMESTAMP_` datetime NOT NULL,
                                  `JOB_ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                  `JOB_DUEDATE_` datetime DEFAULT NULL,
                                  `JOB_RETRIES_` int DEFAULT NULL,
                                  `JOB_PRIORITY_` bigint NOT NULL DEFAULT '0',
                                  `JOB_EXCEPTION_MSG_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `JOB_EXCEPTION_STACK_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `JOB_STATE_` int DEFAULT NULL,
                                  `JOB_DEF_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `JOB_DEF_TYPE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `JOB_DEF_CONFIGURATION_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `ACT_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `FAILED_ACT_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `EXECUTION_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `ROOT_PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `PROCESS_INSTANCE_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `PROCESS_DEF_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `PROCESS_DEF_KEY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `DEPLOYMENT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `SEQUENCE_COUNTER_` bigint DEFAULT NULL,
                                  `TENANT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `HOSTNAME_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `REMOVAL_TIME_` datetime DEFAULT NULL,
                                  `BATCH_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                  PRIMARY KEY (`ID_`),
                                  KEY `ACT_IDX_HI_JOB_LOG_ROOT_PI` (`ROOT_PROC_INST_ID_`),
                                  KEY `ACT_IDX_HI_JOB_LOG_PROCINST` (`PROCESS_INSTANCE_ID_`),
                                  KEY `ACT_IDX_HI_JOB_LOG_PROCDEF` (`PROCESS_DEF_ID_`),
                                  KEY `ACT_IDX_HI_JOB_LOG_TENANT_ID` (`TENANT_ID_`),
                                  KEY `ACT_IDX_HI_JOB_LOG_JOB_DEF_ID` (`JOB_DEF_ID_`),
                                  KEY `ACT_IDX_HI_JOB_LOG_PROC_DEF_KEY` (`PROCESS_DEF_KEY_`),
                                  KEY `ACT_IDX_HI_JOB_LOG_EX_STACK` (`JOB_EXCEPTION_STACK_ID_`),
                                  KEY `ACT_IDX_HI_JOB_LOG_RM_TIME` (`REMOVAL_TIME_`),
                                  KEY `ACT_IDX_HI_JOB_LOG_JOB_CONF` (`JOB_DEF_CONFIGURATION_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*Data for the table `act_hi_job_log` */

/*Table structure for table `act_hi_op_log` */

DROP TABLE IF EXISTS `act_hi_op_log`;

CREATE TABLE `act_hi_op_log` (
                                 `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                 `DEPLOYMENT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `PROC_DEF_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `PROC_DEF_KEY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `ROOT_PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `EXECUTION_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `CASE_DEF_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `CASE_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `CASE_EXECUTION_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `TASK_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `JOB_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `JOB_DEF_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `BATCH_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `USER_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `TIMESTAMP_` timestamp NOT NULL,
                                 `OPERATION_TYPE_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `OPERATION_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `ENTITY_TYPE_` varchar(30) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `PROPERTY_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `ORG_VALUE_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `NEW_VALUE_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `TENANT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `REMOVAL_TIME_` datetime DEFAULT NULL,
                                 `CATEGORY_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `EXTERNAL_TASK_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `ANNOTATION_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
                                 PRIMARY KEY (`ID_`),
                                 KEY `ACT_IDX_HI_OP_LOG_ROOT_PI` (`ROOT_PROC_INST_ID_`),
                                 KEY `ACT_IDX_HI_OP_LOG_PROCINST` (`PROC_INST_ID_`),
                                 KEY `ACT_IDX_HI_OP_LOG_PROCDEF` (`PROC_DEF_ID_`),
                                 KEY `ACT_IDX_HI_OP_LOG_TASK` (`TASK_ID_`),
                                 KEY `ACT_IDX_HI_OP_LOG_RM_TIME` (`REMOVAL_TIME_`),
                                 KEY `ACT_IDX_HI_OP_LOG_TIMESTAMP` (`TIMESTAMP_`),
                                 KEY `ACT_IDX_HI_OP_LOG_USER_ID` (`USER_ID_`),
                                 KEY `ACT_IDX_HI_OP_LOG_OP_TYPE` (`OPERATION_TYPE_`),
                                 KEY `ACT_IDX_HI_OP_LOG_ENTITY_TYPE` (`ENTITY_TYPE_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*Data for the table `act_hi_op_log` */

/*Table structure for table `act_hi_procinst` */

DROP TABLE IF EXISTS `act_hi_procinst`;

CREATE TABLE `act_hi_procinst` (
                                   `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                   `PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                   `BUSINESS_KEY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `PROC_DEF_KEY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `PROC_DEF_ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                   `START_TIME_` datetime NOT NULL,
                                   `END_TIME_` datetime DEFAULT NULL,
                                   `REMOVAL_TIME_` datetime DEFAULT NULL,
                                   `DURATION_` bigint DEFAULT NULL,
                                   `START_USER_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `START_ACT_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `END_ACT_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `SUPER_PROCESS_INSTANCE_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `ROOT_PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `SUPER_CASE_INSTANCE_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `CASE_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `DELETE_REASON_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `TENANT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `STATE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `RESTARTED_PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                   PRIMARY KEY (`ID_`),
                                   UNIQUE KEY `PROC_INST_ID_` (`PROC_INST_ID_`),
                                   KEY `ACT_IDX_HI_PRO_INST_END` (`END_TIME_`),
                                   KEY `ACT_IDX_HI_PRO_I_BUSKEY` (`BUSINESS_KEY_`),
                                   KEY `ACT_IDX_HI_PRO_INST_TENANT_ID` (`TENANT_ID_`),
                                   KEY `ACT_IDX_HI_PRO_INST_PROC_DEF_KEY` (`PROC_DEF_KEY_`),
                                   KEY `ACT_IDX_HI_PRO_INST_PROC_TIME` (`START_TIME_`,`END_TIME_`),
                                   KEY `ACT_IDX_HI_PI_PDEFID_END_TIME` (`PROC_DEF_ID_`,`END_TIME_`),
                                   KEY `ACT_IDX_HI_PRO_INST_ROOT_PI` (`ROOT_PROC_INST_ID_`),
                                   KEY `ACT_IDX_HI_PRO_INST_RM_TIME` (`REMOVAL_TIME_`),
                                   KEY `ACT_IDX_HI_PRO_RST_PRO_INST_ID` (`RESTARTED_PROC_INST_ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*Data for the table `act_hi_procinst` */

insert  into `act_hi_procinst`(`ID_`,`PROC_INST_ID_`,`BUSINESS_KEY_`,`PROC_DEF_KEY_`,`PROC_DEF_ID_`,`START_TIME_`,`END_TIME_`,`REMOVAL_TIME_`,`DURATION_`,`START_USER_ID_`,`START_ACT_ID_`,`END_ACT_ID_`,`SUPER_PROCESS_INSTANCE_ID_`,`ROOT_PROC_INST_ID_`,`SUPER_CASE_INSTANCE_ID_`,`CASE_INST_ID_`,`DELETE_REASON_`,`TENANT_ID_`,`STATE_`,`RESTARTED_PROC_INST_ID_`) values
    ('6343a2a8-4399-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03','3','replenishment-approval','replenishment-approval:1:e11deab7-4398-11f1-a600-c894025bbc03','2026-04-29 15:02:30','2026-04-29 15:22:25','2026-05-29 15:22:25',1195088,NULL,'StartEvent','ApprovedEnd',NULL,'6343a2a8-4399-11f1-a600-c894025bbc03',NULL,NULL,NULL,NULL,'COMPLETED',NULL);

/*Table structure for table `act_hi_taskinst` */

DROP TABLE IF EXISTS `act_hi_taskinst`;

CREATE TABLE `act_hi_taskinst` (
                                   `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                   `TASK_DEF_KEY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `PROC_DEF_KEY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `PROC_DEF_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `ROOT_PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `EXECUTION_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `CASE_DEF_KEY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `CASE_DEF_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `CASE_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `CASE_EXECUTION_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `ACT_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `NAME_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `PARENT_TASK_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `DESCRIPTION_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `OWNER_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `ASSIGNEE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `START_TIME_` datetime NOT NULL,
                                   `END_TIME_` datetime DEFAULT NULL,
                                   `DURATION_` bigint DEFAULT NULL,
                                   `DELETE_REASON_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `PRIORITY_` int DEFAULT NULL,
                                   `DUE_DATE_` datetime DEFAULT NULL,
                                   `FOLLOW_UP_DATE_` datetime DEFAULT NULL,
                                   `TENANT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `REMOVAL_TIME_` datetime DEFAULT NULL,
                                   `TASK_STATE_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                   PRIMARY KEY (`ID_`),
                                   KEY `ACT_IDX_HI_TASKINST_ROOT_PI` (`ROOT_PROC_INST_ID_`),
                                   KEY `ACT_IDX_HI_TASK_INST_TENANT_ID` (`TENANT_ID_`),
                                   KEY `ACT_IDX_HI_TASK_INST_PROC_DEF_KEY` (`PROC_DEF_KEY_`),
                                   KEY `ACT_IDX_HI_TASKINST_PROCINST` (`PROC_INST_ID_`),
                                   KEY `ACT_IDX_HI_TASKINSTID_PROCINST` (`ID_`,`PROC_INST_ID_`),
                                   KEY `ACT_IDX_HI_TASK_INST_RM_TIME` (`REMOVAL_TIME_`),
                                   KEY `ACT_IDX_HI_TASK_INST_START` (`START_TIME_`),
                                   KEY `ACT_IDX_HI_TASK_INST_END` (`END_TIME_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*Data for the table `act_hi_taskinst` */

insert  into `act_hi_taskinst`(`ID_`,`TASK_DEF_KEY_`,`PROC_DEF_KEY_`,`PROC_DEF_ID_`,`ROOT_PROC_INST_ID_`,`PROC_INST_ID_`,`EXECUTION_ID_`,`CASE_DEF_KEY_`,`CASE_DEF_ID_`,`CASE_INST_ID_`,`CASE_EXECUTION_ID_`,`ACT_INST_ID_`,`NAME_`,`PARENT_TASK_ID_`,`DESCRIPTION_`,`OWNER_`,`ASSIGNEE_`,`START_TIME_`,`END_TIME_`,`DURATION_`,`DELETE_REASON_`,`PRIORITY_`,`DUE_DATE_`,`FOLLOW_UP_DATE_`,`TENANT_ID_`,`REMOVAL_TIME_`,`TASK_STATE_`) values
                                                                                                                                                                                                                                                                                                                                                                                                                                           ('19279666-439c-11f1-a8d7-c894025bbc03','DirectorApprove','replenishment-approval','replenishment-approval:1:e11deab7-4398-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03',NULL,NULL,NULL,NULL,'DirectorApprove:192636d5-439c-11f1-a8d7-c894025bbc03','经理审批',NULL,NULL,NULL,NULL,'2026-04-29 15:21:54','2026-04-29 15:22:25',31071,'completed',50,NULL,NULL,NULL,'2026-05-29 15:22:25','Completed'),
                                                                                                                                                                                                                                                                                                                                                                                                                                           ('634cc971-4399-11f1-a600-c894025bbc03','ManagerApprove','replenishment-approval','replenishment-approval:1:e11deab7-4398-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03',NULL,NULL,NULL,NULL,'ManagerApprove:634ca260-4399-11f1-a600-c894025bbc03','主管审批',NULL,NULL,NULL,NULL,'2026-04-29 15:02:30','2026-04-29 15:21:54',1164095,'completed',50,NULL,NULL,NULL,'2026-05-29 15:22:25','Completed');

/*Table structure for table `act_hi_varinst` */

DROP TABLE IF EXISTS `act_hi_varinst`;

CREATE TABLE `act_hi_varinst` (
                                  `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                  `PROC_DEF_KEY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `PROC_DEF_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `ROOT_PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `EXECUTION_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `ACT_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `CASE_DEF_KEY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `CASE_DEF_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `CASE_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `CASE_EXECUTION_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `TASK_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `NAME_` varchar(255) COLLATE utf8mb3_bin NOT NULL,
                                  `VAR_TYPE_` varchar(100) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `CREATE_TIME_` datetime DEFAULT NULL,
                                  `REV_` int DEFAULT NULL,
                                  `BYTEARRAY_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `DOUBLE_` double DEFAULT NULL,
                                  `LONG_` bigint DEFAULT NULL,
                                  `TEXT_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `TEXT2_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `TENANT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `STATE_` varchar(20) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `REMOVAL_TIME_` datetime DEFAULT NULL,
                                  PRIMARY KEY (`ID_`),
                                  KEY `ACT_IDX_HI_VARINST_ROOT_PI` (`ROOT_PROC_INST_ID_`),
                                  KEY `ACT_IDX_HI_PROCVAR_PROC_INST` (`PROC_INST_ID_`),
                                  KEY `ACT_IDX_HI_PROCVAR_NAME_TYPE` (`NAME_`,`VAR_TYPE_`),
                                  KEY `ACT_IDX_HI_CASEVAR_CASE_INST` (`CASE_INST_ID_`),
                                  KEY `ACT_IDX_HI_VAR_INST_TENANT_ID` (`TENANT_ID_`),
                                  KEY `ACT_IDX_HI_VAR_INST_PROC_DEF_KEY` (`PROC_DEF_KEY_`),
                                  KEY `ACT_IDX_HI_VARINST_BYTEAR` (`BYTEARRAY_ID_`),
                                  KEY `ACT_IDX_HI_VARINST_RM_TIME` (`REMOVAL_TIME_`),
                                  KEY `ACT_IDX_HI_VAR_PI_NAME_TYPE` (`PROC_INST_ID_`,`NAME_`,`VAR_TYPE_`),
                                  KEY `ACT_IDX_HI_VARINST_NAME` (`NAME_`),
                                  KEY `ACT_IDX_HI_VARINST_ACT_INST_ID` (`ACT_INST_ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*Data for the table `act_hi_varinst` */

insert  into `act_hi_varinst`(`ID_`,`PROC_DEF_KEY_`,`PROC_DEF_ID_`,`ROOT_PROC_INST_ID_`,`PROC_INST_ID_`,`EXECUTION_ID_`,`ACT_INST_ID_`,`CASE_DEF_KEY_`,`CASE_DEF_ID_`,`CASE_INST_ID_`,`CASE_EXECUTION_ID_`,`TASK_ID_`,`NAME_`,`VAR_TYPE_`,`CREATE_TIME_`,`REV_`,`BYTEARRAY_ID_`,`DOUBLE_`,`LONG_`,`TEXT_`,`TEXT2_`,`TENANT_ID_`,`STATE_`,`REMOVAL_TIME_`) values
                                                                                                                                                                                                                                                                                                                                                              ('191d8443-439c-11f1-a8d7-c894025bbc03','replenishment-approval','replenishment-approval:1:e11deab7-4398-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03',NULL,NULL,NULL,NULL,NULL,'comment','string','2026-04-29 15:21:54',0,NULL,NULL,NULL,'审批通过',NULL,NULL,'CREATED','2026-05-29 15:22:25'),
                                                                                                                                                                                                                                                                                                                                                              ('6345c589-4399-11f1-a600-c894025bbc03','replenishment-approval','replenishment-approval:1:e11deab7-4398-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03',NULL,NULL,NULL,NULL,NULL,'approved','boolean','2026-04-29 15:02:30',1,NULL,NULL,1,NULL,NULL,NULL,'CREATED','2026-05-29 15:22:25'),
                                                                                                                                                                                                                                                                                                                                                              ('6349e43b-4399-11f1-a600-c894025bbc03','replenishment-approval','replenishment-approval:1:e11deab7-4398-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03',NULL,NULL,NULL,NULL,NULL,'orderId','long','2026-04-29 15:02:30',0,NULL,NULL,3,'3',NULL,NULL,'CREATED','2026-05-29 15:22:25'),
                                                                                                                                                                                                                                                                                                                                                              ('6349e43d-4399-11f1-a600-c894025bbc03','replenishment-approval','replenishment-approval:1:e11deab7-4398-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03','6343a2a8-4399-11f1-a600-c894025bbc03',NULL,NULL,NULL,NULL,NULL,'applicant','string','2026-04-29 15:02:30',0,NULL,NULL,NULL,'system',NULL,NULL,'CREATED','2026-05-29 15:22:25');

/*Table structure for table `act_id_group` */

DROP TABLE IF EXISTS `act_id_group`;

CREATE TABLE `act_id_group` (
                                `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                `REV_` int DEFAULT NULL,
                                `NAME_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                `TYPE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                PRIMARY KEY (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*Data for the table `act_id_group` */

insert  into `act_id_group`(`ID_`,`REV_`,`NAME_`,`TYPE_`) values
    ('camunda-admin',1,'camunda BPM Administrators','SYSTEM');

/*Table structure for table `act_id_info` */

DROP TABLE IF EXISTS `act_id_info`;

CREATE TABLE `act_id_info` (
                               `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                               `REV_` int DEFAULT NULL,
                               `USER_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                               `TYPE_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                               `KEY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                               `VALUE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                               `PASSWORD_` longblob,
                               `PARENT_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                               PRIMARY KEY (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*Data for the table `act_id_info` */

/*Table structure for table `act_id_membership` */

DROP TABLE IF EXISTS `act_id_membership`;

CREATE TABLE `act_id_membership` (
                                     `USER_ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                     `GROUP_ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                     PRIMARY KEY (`USER_ID_`,`GROUP_ID_`),
                                     KEY `ACT_FK_MEMB_GROUP` (`GROUP_ID_`),
                                     CONSTRAINT `ACT_FK_MEMB_GROUP` FOREIGN KEY (`GROUP_ID_`) REFERENCES `act_id_group` (`ID_`),
                                     CONSTRAINT `ACT_FK_MEMB_USER` FOREIGN KEY (`USER_ID_`) REFERENCES `act_id_user` (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*Data for the table `act_id_membership` */

insert  into `act_id_membership`(`USER_ID_`,`GROUP_ID_`) values
    ('admin','camunda-admin');

/*Table structure for table `act_id_tenant` */

DROP TABLE IF EXISTS `act_id_tenant`;

CREATE TABLE `act_id_tenant` (
                                 `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                 `REV_` int DEFAULT NULL,
                                 `NAME_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                 PRIMARY KEY (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*Data for the table `act_id_tenant` */

/*Table structure for table `act_id_tenant_member` */

DROP TABLE IF EXISTS `act_id_tenant_member`;

CREATE TABLE `act_id_tenant_member` (
                                        `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                        `TENANT_ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                        `USER_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                        `GROUP_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                        PRIMARY KEY (`ID_`),
                                        UNIQUE KEY `ACT_UNIQ_TENANT_MEMB_USER` (`TENANT_ID_`,`USER_ID_`),
                                        UNIQUE KEY `ACT_UNIQ_TENANT_MEMB_GROUP` (`TENANT_ID_`,`GROUP_ID_`),
                                        KEY `ACT_FK_TENANT_MEMB_USER` (`USER_ID_`),
                                        KEY `ACT_FK_TENANT_MEMB_GROUP` (`GROUP_ID_`),
                                        CONSTRAINT `ACT_FK_TENANT_MEMB` FOREIGN KEY (`TENANT_ID_`) REFERENCES `act_id_tenant` (`ID_`),
                                        CONSTRAINT `ACT_FK_TENANT_MEMB_GROUP` FOREIGN KEY (`GROUP_ID_`) REFERENCES `act_id_group` (`ID_`),
                                        CONSTRAINT `ACT_FK_TENANT_MEMB_USER` FOREIGN KEY (`USER_ID_`) REFERENCES `act_id_user` (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*Data for the table `act_id_tenant_member` */

/*Table structure for table `act_id_user` */

DROP TABLE IF EXISTS `act_id_user`;

CREATE TABLE `act_id_user` (
                               `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                               `REV_` int DEFAULT NULL,
                               `FIRST_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                               `LAST_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                               `EMAIL_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                               `PWD_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                               `SALT_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                               `LOCK_EXP_TIME_` datetime DEFAULT NULL,
                               `ATTEMPTS_` int DEFAULT NULL,
                               `PICTURE_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                               PRIMARY KEY (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*Data for the table `act_id_user` */

insert  into `act_id_user`(`ID_`,`REV_`,`FIRST_`,`LAST_`,`EMAIL_`,`PWD_`,`SALT_`,`LOCK_EXP_TIME_`,`ATTEMPTS_`,`PICTURE_ID_`) values
    ('admin',1,'Admin','Admin','admin@localhost','{SHA-512}jzU7zsJD9SzVH7F3z7f7LI744QUyGtoq4HDwg7JEWt8VvueJfF6+5y7j5Qf2FgO8D3lj26pyWf1TDbJGfSHt0A==','nDf9z70EpJiL9g3sG9jLEQ==',NULL,NULL,NULL);

/*Table structure for table `act_re_camformdef` */

DROP TABLE IF EXISTS `act_re_camformdef`;

CREATE TABLE `act_re_camformdef` (
                                     `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                     `REV_` int DEFAULT NULL,
                                     `KEY_` varchar(255) COLLATE utf8mb3_bin NOT NULL,
                                     `VERSION_` int NOT NULL,
                                     `DEPLOYMENT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                     `RESOURCE_NAME_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
                                     `TENANT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                     PRIMARY KEY (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*Data for the table `act_re_camformdef` */

/*Table structure for table `act_re_case_def` */

DROP TABLE IF EXISTS `act_re_case_def`;

CREATE TABLE `act_re_case_def` (
                                   `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                   `REV_` int DEFAULT NULL,
                                   `CATEGORY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `NAME_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `KEY_` varchar(255) COLLATE utf8mb3_bin NOT NULL,
                                   `VERSION_` int NOT NULL,
                                   `DEPLOYMENT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `RESOURCE_NAME_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `DGRM_RESOURCE_NAME_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `TENANT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `HISTORY_TTL_` int DEFAULT NULL,
                                   PRIMARY KEY (`ID_`),
                                   KEY `ACT_IDX_CASE_DEF_TENANT_ID` (`TENANT_ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*Data for the table `act_re_case_def` */

/*Table structure for table `act_re_decision_def` */

DROP TABLE IF EXISTS `act_re_decision_def`;

CREATE TABLE `act_re_decision_def` (
                                       `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                       `REV_` int DEFAULT NULL,
                                       `CATEGORY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                       `NAME_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                       `KEY_` varchar(255) COLLATE utf8mb3_bin NOT NULL,
                                       `VERSION_` int NOT NULL,
                                       `DEPLOYMENT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                       `RESOURCE_NAME_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
                                       `DGRM_RESOURCE_NAME_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
                                       `DEC_REQ_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                       `DEC_REQ_KEY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                       `TENANT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                       `HISTORY_TTL_` int DEFAULT NULL,
                                       `VERSION_TAG_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                       PRIMARY KEY (`ID_`),
                                       KEY `ACT_IDX_DEC_DEF_TENANT_ID` (`TENANT_ID_`),
                                       KEY `ACT_IDX_DEC_DEF_REQ_ID` (`DEC_REQ_ID_`),
                                       CONSTRAINT `ACT_FK_DEC_REQ` FOREIGN KEY (`DEC_REQ_ID_`) REFERENCES `act_re_decision_req_def` (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*Data for the table `act_re_decision_def` */

/*Table structure for table `act_re_decision_req_def` */

DROP TABLE IF EXISTS `act_re_decision_req_def`;

CREATE TABLE `act_re_decision_req_def` (
                                           `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                           `REV_` int DEFAULT NULL,
                                           `CATEGORY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                           `NAME_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                           `KEY_` varchar(255) COLLATE utf8mb3_bin NOT NULL,
                                           `VERSION_` int NOT NULL,
                                           `DEPLOYMENT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                           `RESOURCE_NAME_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
                                           `DGRM_RESOURCE_NAME_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
                                           `TENANT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                           PRIMARY KEY (`ID_`),
                                           KEY `ACT_IDX_DEC_REQ_DEF_TENANT_ID` (`TENANT_ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*Data for the table `act_re_decision_req_def` */

/*Table structure for table `act_re_deployment` */

DROP TABLE IF EXISTS `act_re_deployment`;

CREATE TABLE `act_re_deployment` (
                                     `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                     `NAME_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                     `DEPLOY_TIME_` datetime DEFAULT NULL,
                                     `SOURCE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                     `TENANT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                     PRIMARY KEY (`ID_`),
                                     KEY `ACT_IDX_DEPLOYMENT_NAME` (`NAME_`),
                                     KEY `ACT_IDX_DEPLOYMENT_TENANT_ID` (`TENANT_ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*Data for the table `act_re_deployment` */

insert  into `act_re_deployment`(`ID_`,`NAME_`,`DEPLOY_TIME_`,`SOURCE_`,`TENANT_ID_`) values
    ('e0f999d5-4398-11f1-a600-c894025bbc03','SpringAutoDeployment','2026-04-29 14:58:51',NULL,NULL);

/*Table structure for table `act_re_procdef` */

DROP TABLE IF EXISTS `act_re_procdef`;

CREATE TABLE `act_re_procdef` (
                                  `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                  `REV_` int DEFAULT NULL,
                                  `CATEGORY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `NAME_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `KEY_` varchar(255) COLLATE utf8mb3_bin NOT NULL,
                                  `VERSION_` int NOT NULL,
                                  `DEPLOYMENT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `RESOURCE_NAME_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `DGRM_RESOURCE_NAME_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `HAS_START_FORM_KEY_` tinyint DEFAULT NULL,
                                  `SUSPENSION_STATE_` int DEFAULT NULL,
                                  `TENANT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `VERSION_TAG_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                  `HISTORY_TTL_` int DEFAULT NULL,
                                  `STARTABLE_` tinyint(1) NOT NULL DEFAULT '1',
                                  PRIMARY KEY (`ID_`),
                                  KEY `ACT_IDX_PROCDEF_DEPLOYMENT_ID` (`DEPLOYMENT_ID_`),
                                  KEY `ACT_IDX_PROCDEF_TENANT_ID` (`TENANT_ID_`),
                                  KEY `ACT_IDX_PROCDEF_VER_TAG` (`VERSION_TAG_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*Data for the table `act_re_procdef` */

insert  into `act_re_procdef`(`ID_`,`REV_`,`CATEGORY_`,`NAME_`,`KEY_`,`VERSION_`,`DEPLOYMENT_ID_`,`RESOURCE_NAME_`,`DGRM_RESOURCE_NAME_`,`HAS_START_FORM_KEY_`,`SUSPENSION_STATE_`,`TENANT_ID_`,`VERSION_TAG_`,`HISTORY_TTL_`,`STARTABLE_`) values
    ('replenishment-approval:1:e11deab7-4398-11f1-a600-c894025bbc03',1,'http://bpmn.io/schema/bpmn','补货审批流程','replenishment-approval',1,'e0f999d5-4398-11f1-a600-c894025bbc03','D:\\project\\wms-tenant-starter\\target\\classes\\processes\\replenishment-approval.bpmn',NULL,0,1,NULL,NULL,30,1);

/*Table structure for table `act_ru_authorization` */

DROP TABLE IF EXISTS `act_ru_authorization`;

CREATE TABLE `act_ru_authorization` (
                                        `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                        `REV_` int NOT NULL,
                                        `TYPE_` int NOT NULL,
                                        `GROUP_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                        `USER_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                        `RESOURCE_TYPE_` int NOT NULL,
                                        `RESOURCE_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                        `PERMS_` int DEFAULT NULL,
                                        `REMOVAL_TIME_` datetime DEFAULT NULL,
                                        `ROOT_PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                        PRIMARY KEY (`ID_`),
                                        UNIQUE KEY `ACT_UNIQ_AUTH_USER` (`USER_ID_`,`TYPE_`,`RESOURCE_TYPE_`,`RESOURCE_ID_`),
                                        UNIQUE KEY `ACT_UNIQ_AUTH_GROUP` (`GROUP_ID_`,`TYPE_`,`RESOURCE_TYPE_`,`RESOURCE_ID_`),
                                        KEY `ACT_IDX_AUTH_GROUP_ID` (`GROUP_ID_`),
                                        KEY `ACT_IDX_AUTH_RESOURCE_ID` (`RESOURCE_ID_`),
                                        KEY `ACT_IDX_AUTH_ROOT_PI` (`ROOT_PROC_INST_ID_`),
                                        KEY `ACT_IDX_AUTH_RM_TIME` (`REMOVAL_TIME_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*Data for the table `act_ru_authorization` */

insert  into `act_ru_authorization`(`ID_`,`REV_`,`TYPE_`,`GROUP_ID_`,`USER_ID_`,`RESOURCE_TYPE_`,`RESOURCE_ID_`,`PERMS_`,`REMOVAL_TIME_`,`ROOT_PROC_INST_ID_`) values
                                                                                                                                                                   ('e0cff1ae-4398-11f1-a600-c894025bbc03',1,1,'camunda-admin',NULL,0,'*',2147483647,NULL,NULL),
                                                                                                                                                                   ('e0d325ff-4398-11f1-a600-c894025bbc03',1,1,'camunda-admin',NULL,1,'*',2147483647,NULL,NULL),
                                                                                                                                                                   ('e0d4fac0-4398-11f1-a600-c894025bbc03',1,1,'camunda-admin',NULL,2,'*',2147483647,NULL,NULL),
                                                                                                                                                                   ('e0d6cf81-4398-11f1-a600-c894025bbc03',1,1,'camunda-admin',NULL,3,'*',2147483647,NULL,NULL),
                                                                                                                                                                   ('e0d87d32-4398-11f1-a600-c894025bbc03',1,1,'camunda-admin',NULL,4,'*',2147483647,NULL,NULL),
                                                                                                                                                                   ('e0da2ae3-4398-11f1-a600-c894025bbc03',1,1,'camunda-admin',NULL,5,'*',2147483647,NULL,NULL),
                                                                                                                                                                   ('e0dbd894-4398-11f1-a600-c894025bbc03',1,1,'camunda-admin',NULL,6,'*',2147483647,NULL,NULL),
                                                                                                                                                                   ('e0dd3825-4398-11f1-a600-c894025bbc03',1,1,'camunda-admin',NULL,7,'*',2147483647,NULL,NULL),
                                                                                                                                                                   ('e0de97b6-4398-11f1-a600-c894025bbc03',1,1,'camunda-admin',NULL,8,'*',2147483647,NULL,NULL),
                                                                                                                                                                   ('e0dfd037-4398-11f1-a600-c894025bbc03',1,1,'camunda-admin',NULL,9,'*',2147483647,NULL,NULL),
                                                                                                                                                                   ('e0e12fc8-4398-11f1-a600-c894025bbc03',1,1,'camunda-admin',NULL,10,'*',2147483647,NULL,NULL),
                                                                                                                                                                   ('e0e26849-4398-11f1-a600-c894025bbc03',1,1,'camunda-admin',NULL,11,'*',2147483647,NULL,NULL),
                                                                                                                                                                   ('e0e3eeea-4398-11f1-a600-c894025bbc03',1,1,'camunda-admin',NULL,12,'*',2147483647,NULL,NULL),
                                                                                                                                                                   ('e0e5758b-4398-11f1-a600-c894025bbc03',1,1,'camunda-admin',NULL,13,'*',2147483647,NULL,NULL),
                                                                                                                                                                   ('e0e6d51c-4398-11f1-a600-c894025bbc03',1,1,'camunda-admin',NULL,14,'*',2147483647,NULL,NULL),
                                                                                                                                                                   ('e0e8d0ed-4398-11f1-a600-c894025bbc03',1,1,'camunda-admin',NULL,15,'*',2147483647,NULL,NULL),
                                                                                                                                                                   ('e0eb1ade-4398-11f1-a600-c894025bbc03',1,1,'camunda-admin',NULL,16,'*',2147483647,NULL,NULL),
                                                                                                                                                                   ('e0eca17f-4398-11f1-a600-c894025bbc03',1,1,'camunda-admin',NULL,17,'*',2147483647,NULL,NULL),
                                                                                                                                                                   ('e0ee2820-4398-11f1-a600-c894025bbc03',1,1,'camunda-admin',NULL,18,'*',2147483647,NULL,NULL),
                                                                                                                                                                   ('e0efd5d1-4398-11f1-a600-c894025bbc03',1,1,'camunda-admin',NULL,19,'*',2147483647,NULL,NULL),
                                                                                                                                                                   ('e0f15c72-4398-11f1-a600-c894025bbc03',1,1,'camunda-admin',NULL,20,'*',2147483647,NULL,NULL),
                                                                                                                                                                   ('e0f30a23-4398-11f1-a600-c894025bbc03',1,1,'camunda-admin',NULL,21,'*',2147483647,NULL,NULL);

/*Table structure for table `act_ru_batch` */

DROP TABLE IF EXISTS `act_ru_batch`;

CREATE TABLE `act_ru_batch` (
                                `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                `REV_` int NOT NULL,
                                `TYPE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                `TOTAL_JOBS_` int DEFAULT NULL,
                                `JOBS_CREATED_` int DEFAULT NULL,
                                `JOBS_PER_SEED_` int DEFAULT NULL,
                                `INVOCATIONS_PER_JOB_` int DEFAULT NULL,
                                `SEED_JOB_DEF_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                `BATCH_JOB_DEF_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                `MONITOR_JOB_DEF_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                `SUSPENSION_STATE_` int DEFAULT NULL,
                                `CONFIGURATION_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                `TENANT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                `CREATE_USER_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                `START_TIME_` datetime DEFAULT NULL,
                                `EXEC_START_TIME_` datetime DEFAULT NULL,
                                PRIMARY KEY (`ID_`),
                                KEY `ACT_IDX_BATCH_SEED_JOB_DEF` (`SEED_JOB_DEF_ID_`),
                                KEY `ACT_IDX_BATCH_MONITOR_JOB_DEF` (`MONITOR_JOB_DEF_ID_`),
                                KEY `ACT_IDX_BATCH_JOB_DEF` (`BATCH_JOB_DEF_ID_`),
                                CONSTRAINT `ACT_FK_BATCH_JOB_DEF` FOREIGN KEY (`BATCH_JOB_DEF_ID_`) REFERENCES `act_ru_jobdef` (`ID_`),
                                CONSTRAINT `ACT_FK_BATCH_MONITOR_JOB_DEF` FOREIGN KEY (`MONITOR_JOB_DEF_ID_`) REFERENCES `act_ru_jobdef` (`ID_`),
                                CONSTRAINT `ACT_FK_BATCH_SEED_JOB_DEF` FOREIGN KEY (`SEED_JOB_DEF_ID_`) REFERENCES `act_ru_jobdef` (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*Data for the table `act_ru_batch` */

/*Table structure for table `act_ru_case_execution` */

DROP TABLE IF EXISTS `act_ru_case_execution`;

CREATE TABLE `act_ru_case_execution` (
                                         `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                         `REV_` int DEFAULT NULL,
                                         `CASE_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                         `SUPER_CASE_EXEC_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                         `SUPER_EXEC_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                         `BUSINESS_KEY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                         `PARENT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                         `CASE_DEF_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                         `ACT_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                         `PREV_STATE_` int DEFAULT NULL,
                                         `CURRENT_STATE_` int DEFAULT NULL,
                                         `REQUIRED_` tinyint(1) DEFAULT NULL,
                                         `TENANT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                         PRIMARY KEY (`ID_`),
                                         KEY `ACT_IDX_CASE_EXEC_BUSKEY` (`BUSINESS_KEY_`),
                                         KEY `ACT_IDX_CASE_EXE_CASE_INST` (`CASE_INST_ID_`),
                                         KEY `ACT_FK_CASE_EXE_PARENT` (`PARENT_ID_`),
                                         KEY `ACT_FK_CASE_EXE_CASE_DEF` (`CASE_DEF_ID_`),
                                         KEY `ACT_IDX_CASE_EXEC_TENANT_ID` (`TENANT_ID_`),
                                         CONSTRAINT `ACT_FK_CASE_EXE_CASE_DEF` FOREIGN KEY (`CASE_DEF_ID_`) REFERENCES `act_re_case_def` (`ID_`),
                                         CONSTRAINT `ACT_FK_CASE_EXE_CASE_INST` FOREIGN KEY (`CASE_INST_ID_`) REFERENCES `act_ru_case_execution` (`ID_`) ON DELETE CASCADE ON UPDATE CASCADE,
                                         CONSTRAINT `ACT_FK_CASE_EXE_PARENT` FOREIGN KEY (`PARENT_ID_`) REFERENCES `act_ru_case_execution` (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*Data for the table `act_ru_case_execution` */

/*Table structure for table `act_ru_case_sentry_part` */

DROP TABLE IF EXISTS `act_ru_case_sentry_part`;

CREATE TABLE `act_ru_case_sentry_part` (
                                           `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                           `REV_` int DEFAULT NULL,
                                           `CASE_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                           `CASE_EXEC_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                           `SENTRY_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                           `TYPE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                           `SOURCE_CASE_EXEC_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                           `STANDARD_EVENT_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                           `SOURCE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                           `VARIABLE_EVENT_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                           `VARIABLE_NAME_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                           `SATISFIED_` tinyint(1) DEFAULT NULL,
                                           `TENANT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                           PRIMARY KEY (`ID_`),
                                           KEY `ACT_FK_CASE_SENTRY_CASE_INST` (`CASE_INST_ID_`),
                                           KEY `ACT_FK_CASE_SENTRY_CASE_EXEC` (`CASE_EXEC_ID_`),
                                           CONSTRAINT `ACT_FK_CASE_SENTRY_CASE_EXEC` FOREIGN KEY (`CASE_EXEC_ID_`) REFERENCES `act_ru_case_execution` (`ID_`),
                                           CONSTRAINT `ACT_FK_CASE_SENTRY_CASE_INST` FOREIGN KEY (`CASE_INST_ID_`) REFERENCES `act_ru_case_execution` (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*Data for the table `act_ru_case_sentry_part` */

/*Table structure for table `act_ru_event_subscr` */

DROP TABLE IF EXISTS `act_ru_event_subscr`;

CREATE TABLE `act_ru_event_subscr` (
                                       `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                       `REV_` int DEFAULT NULL,
                                       `EVENT_TYPE_` varchar(255) COLLATE utf8mb3_bin NOT NULL,
                                       `EVENT_NAME_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                       `EXECUTION_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                       `PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                       `ACTIVITY_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                       `CONFIGURATION_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                       `CREATED_` datetime NOT NULL,
                                       `TENANT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                       PRIMARY KEY (`ID_`),
                                       KEY `ACT_IDX_EVENT_SUBSCR_CONFIG_` (`CONFIGURATION_`),
                                       KEY `ACT_IDX_EVENT_SUBSCR_TENANT_ID` (`TENANT_ID_`),
                                       KEY `ACT_FK_EVENT_EXEC` (`EXECUTION_ID_`),
                                       KEY `ACT_IDX_EVENT_SUBSCR_EVT_NAME` (`EVENT_NAME_`),
                                       CONSTRAINT `ACT_FK_EVENT_EXEC` FOREIGN KEY (`EXECUTION_ID_`) REFERENCES `act_ru_execution` (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*Data for the table `act_ru_event_subscr` */

/*Table structure for table `act_ru_execution` */

DROP TABLE IF EXISTS `act_ru_execution`;

CREATE TABLE `act_ru_execution` (
                                    `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                    `REV_` int DEFAULT NULL,
                                    `ROOT_PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                    `PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                    `BUSINESS_KEY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                    `PARENT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                    `PROC_DEF_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                    `SUPER_EXEC_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                    `SUPER_CASE_EXEC_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                    `CASE_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                    `ACT_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                    `ACT_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                    `IS_ACTIVE_` tinyint DEFAULT NULL,
                                    `IS_CONCURRENT_` tinyint DEFAULT NULL,
                                    `IS_SCOPE_` tinyint DEFAULT NULL,
                                    `IS_EVENT_SCOPE_` tinyint DEFAULT NULL,
                                    `SUSPENSION_STATE_` int DEFAULT NULL,
                                    `CACHED_ENT_STATE_` int DEFAULT NULL,
                                    `SEQUENCE_COUNTER_` bigint DEFAULT NULL,
                                    `TENANT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                    `PROC_DEF_KEY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                    PRIMARY KEY (`ID_`),
                                    KEY `ACT_IDX_EXEC_ROOT_PI` (`ROOT_PROC_INST_ID_`),
                                    KEY `ACT_IDX_EXEC_BUSKEY` (`BUSINESS_KEY_`),
                                    KEY `ACT_IDX_EXEC_TENANT_ID` (`TENANT_ID_`),
                                    KEY `ACT_FK_EXE_PROCINST` (`PROC_INST_ID_`),
                                    KEY `ACT_FK_EXE_PARENT` (`PARENT_ID_`),
                                    KEY `ACT_FK_EXE_SUPER` (`SUPER_EXEC_`),
                                    KEY `ACT_FK_EXE_PROCDEF` (`PROC_DEF_ID_`),
                                    CONSTRAINT `ACT_FK_EXE_PARENT` FOREIGN KEY (`PARENT_ID_`) REFERENCES `act_ru_execution` (`ID_`),
                                    CONSTRAINT `ACT_FK_EXE_PROCDEF` FOREIGN KEY (`PROC_DEF_ID_`) REFERENCES `act_re_procdef` (`ID_`),
                                    CONSTRAINT `ACT_FK_EXE_PROCINST` FOREIGN KEY (`PROC_INST_ID_`) REFERENCES `act_ru_execution` (`ID_`) ON DELETE CASCADE ON UPDATE CASCADE,
                                    CONSTRAINT `ACT_FK_EXE_SUPER` FOREIGN KEY (`SUPER_EXEC_`) REFERENCES `act_ru_execution` (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*Data for the table `act_ru_execution` */

/*Table structure for table `act_ru_ext_task` */

DROP TABLE IF EXISTS `act_ru_ext_task`;

CREATE TABLE `act_ru_ext_task` (
                                   `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                   `REV_` int NOT NULL,
                                   `WORKER_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `TOPIC_NAME_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `RETRIES_` int DEFAULT NULL,
                                   `ERROR_MSG_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `ERROR_DETAILS_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `LOCK_EXP_TIME_` datetime DEFAULT NULL,
                                   `CREATE_TIME_` datetime DEFAULT NULL,
                                   `SUSPENSION_STATE_` int DEFAULT NULL,
                                   `EXECUTION_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `PROC_DEF_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `PROC_DEF_KEY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `ACT_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `ACT_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `TENANT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `PRIORITY_` bigint NOT NULL DEFAULT '0',
                                   `LAST_FAILURE_LOG_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                   PRIMARY KEY (`ID_`),
                                   KEY `ACT_IDX_EXT_TASK_TOPIC` (`TOPIC_NAME_`),
                                   KEY `ACT_IDX_EXT_TASK_TENANT_ID` (`TENANT_ID_`),
                                   KEY `ACT_IDX_EXT_TASK_PRIORITY` (`PRIORITY_`),
                                   KEY `ACT_IDX_EXT_TASK_ERR_DETAILS` (`ERROR_DETAILS_ID_`),
                                   KEY `ACT_IDX_EXT_TASK_EXEC` (`EXECUTION_ID_`),
                                   CONSTRAINT `ACT_FK_EXT_TASK_ERROR_DETAILS` FOREIGN KEY (`ERROR_DETAILS_ID_`) REFERENCES `act_ge_bytearray` (`ID_`),
                                   CONSTRAINT `ACT_FK_EXT_TASK_EXE` FOREIGN KEY (`EXECUTION_ID_`) REFERENCES `act_ru_execution` (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*Data for the table `act_ru_ext_task` */

/*Table structure for table `act_ru_filter` */

DROP TABLE IF EXISTS `act_ru_filter`;

CREATE TABLE `act_ru_filter` (
                                 `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                 `REV_` int NOT NULL,
                                 `RESOURCE_TYPE_` varchar(255) COLLATE utf8mb3_bin NOT NULL,
                                 `NAME_` varchar(255) COLLATE utf8mb3_bin NOT NULL,
                                 `OWNER_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `QUERY_` longtext COLLATE utf8mb3_bin NOT NULL,
                                 `PROPERTIES_` longtext COLLATE utf8mb3_bin,
                                 PRIMARY KEY (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*Data for the table `act_ru_filter` */

/*Table structure for table `act_ru_identitylink` */

DROP TABLE IF EXISTS `act_ru_identitylink`;

CREATE TABLE `act_ru_identitylink` (
                                       `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                       `REV_` int DEFAULT NULL,
                                       `GROUP_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                       `TYPE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                       `USER_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                       `TASK_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                       `PROC_DEF_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                       `TENANT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                       PRIMARY KEY (`ID_`),
                                       KEY `ACT_IDX_IDENT_LNK_USER` (`USER_ID_`),
                                       KEY `ACT_IDX_IDENT_LNK_GROUP` (`GROUP_ID_`),
                                       KEY `ACT_IDX_ATHRZ_PROCEDEF` (`PROC_DEF_ID_`),
                                       KEY `ACT_FK_TSKASS_TASK` (`TASK_ID_`),
                                       CONSTRAINT `ACT_FK_ATHRZ_PROCEDEF` FOREIGN KEY (`PROC_DEF_ID_`) REFERENCES `act_re_procdef` (`ID_`),
                                       CONSTRAINT `ACT_FK_TSKASS_TASK` FOREIGN KEY (`TASK_ID_`) REFERENCES `act_ru_task` (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*Data for the table `act_ru_identitylink` */

/*Table structure for table `act_ru_incident` */

DROP TABLE IF EXISTS `act_ru_incident`;

CREATE TABLE `act_ru_incident` (
                                   `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                   `REV_` int NOT NULL,
                                   `INCIDENT_TIMESTAMP_` datetime NOT NULL,
                                   `INCIDENT_MSG_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `INCIDENT_TYPE_` varchar(255) COLLATE utf8mb3_bin NOT NULL,
                                   `EXECUTION_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `ACTIVITY_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `FAILED_ACTIVITY_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `PROC_DEF_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `CAUSE_INCIDENT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `ROOT_CAUSE_INCIDENT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `CONFIGURATION_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `TENANT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `JOB_DEF_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `ANNOTATION_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
                                   PRIMARY KEY (`ID_`),
                                   KEY `ACT_IDX_INC_CONFIGURATION` (`CONFIGURATION_`),
                                   KEY `ACT_IDX_INC_TENANT_ID` (`TENANT_ID_`),
                                   KEY `ACT_IDX_INC_JOB_DEF` (`JOB_DEF_ID_`),
                                   KEY `ACT_IDX_INC_CAUSEINCID` (`CAUSE_INCIDENT_ID_`),
                                   KEY `ACT_IDX_INC_EXID` (`EXECUTION_ID_`),
                                   KEY `ACT_IDX_INC_PROCDEFID` (`PROC_DEF_ID_`),
                                   KEY `ACT_IDX_INC_PROCINSTID` (`PROC_INST_ID_`),
                                   KEY `ACT_IDX_INC_ROOTCAUSEINCID` (`ROOT_CAUSE_INCIDENT_ID_`),
                                   CONSTRAINT `ACT_FK_INC_CAUSE` FOREIGN KEY (`CAUSE_INCIDENT_ID_`) REFERENCES `act_ru_incident` (`ID_`) ON DELETE CASCADE ON UPDATE CASCADE,
                                   CONSTRAINT `ACT_FK_INC_EXE` FOREIGN KEY (`EXECUTION_ID_`) REFERENCES `act_ru_execution` (`ID_`),
                                   CONSTRAINT `ACT_FK_INC_JOB_DEF` FOREIGN KEY (`JOB_DEF_ID_`) REFERENCES `act_ru_jobdef` (`ID_`),
                                   CONSTRAINT `ACT_FK_INC_PROCDEF` FOREIGN KEY (`PROC_DEF_ID_`) REFERENCES `act_re_procdef` (`ID_`),
                                   CONSTRAINT `ACT_FK_INC_PROCINST` FOREIGN KEY (`PROC_INST_ID_`) REFERENCES `act_ru_execution` (`ID_`),
                                   CONSTRAINT `ACT_FK_INC_RCAUSE` FOREIGN KEY (`ROOT_CAUSE_INCIDENT_ID_`) REFERENCES `act_ru_incident` (`ID_`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*Data for the table `act_ru_incident` */

/*Table structure for table `act_ru_job` */

DROP TABLE IF EXISTS `act_ru_job`;

CREATE TABLE `act_ru_job` (
                              `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                              `REV_` int DEFAULT NULL,
                              `TYPE_` varchar(255) COLLATE utf8mb3_bin NOT NULL,
                              `LOCK_EXP_TIME_` datetime DEFAULT NULL,
                              `LOCK_OWNER_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                              `EXCLUSIVE_` tinyint(1) DEFAULT NULL,
                              `EXECUTION_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                              `ROOT_PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                              `PROCESS_INSTANCE_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                              `PROCESS_DEF_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                              `PROCESS_DEF_KEY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                              `RETRIES_` int DEFAULT NULL,
                              `EXCEPTION_STACK_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                              `EXCEPTION_MSG_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
                              `FAILED_ACT_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                              `DUEDATE_` datetime DEFAULT NULL,
                              `REPEAT_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                              `REPEAT_OFFSET_` bigint DEFAULT '0',
                              `HANDLER_TYPE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                              `HANDLER_CFG_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
                              `DEPLOYMENT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                              `SUSPENSION_STATE_` int NOT NULL DEFAULT '1',
                              `JOB_DEF_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                              `PRIORITY_` bigint NOT NULL DEFAULT '0',
                              `SEQUENCE_COUNTER_` bigint DEFAULT NULL,
                              `TENANT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                              `CREATE_TIME_` datetime DEFAULT NULL,
                              `LAST_FAILURE_LOG_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                              `BATCH_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                              PRIMARY KEY (`ID_`),
                              KEY `ACT_IDX_JOB_EXECUTION_ID` (`EXECUTION_ID_`),
                              KEY `ACT_IDX_JOB_HANDLER` (`HANDLER_TYPE_`(100),`HANDLER_CFG_`(155)),
                              KEY `ACT_IDX_JOB_PROCINST` (`PROCESS_INSTANCE_ID_`),
                              KEY `ACT_IDX_JOB_ROOT_PROCINST` (`ROOT_PROC_INST_ID_`),
                              KEY `ACT_IDX_JOB_TENANT_ID` (`TENANT_ID_`),
                              KEY `ACT_IDX_JOB_JOB_DEF_ID` (`JOB_DEF_ID_`),
                              KEY `ACT_FK_JOB_EXCEPTION` (`EXCEPTION_STACK_ID_`),
                              KEY `ACT_IDX_JOB_HANDLER_TYPE` (`HANDLER_TYPE_`),
                              CONSTRAINT `ACT_FK_JOB_EXCEPTION` FOREIGN KEY (`EXCEPTION_STACK_ID_`) REFERENCES `act_ge_bytearray` (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*Data for the table `act_ru_job` */

/*Table structure for table `act_ru_jobdef` */

DROP TABLE IF EXISTS `act_ru_jobdef`;

CREATE TABLE `act_ru_jobdef` (
                                 `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                 `REV_` int DEFAULT NULL,
                                 `PROC_DEF_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `PROC_DEF_KEY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `ACT_ID_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `JOB_TYPE_` varchar(255) COLLATE utf8mb3_bin NOT NULL,
                                 `JOB_CONFIGURATION_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `SUSPENSION_STATE_` int DEFAULT NULL,
                                 `JOB_PRIORITY_` bigint DEFAULT NULL,
                                 `TENANT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                 `DEPLOYMENT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                 PRIMARY KEY (`ID_`),
                                 KEY `ACT_IDX_JOBDEF_TENANT_ID` (`TENANT_ID_`),
                                 KEY `ACT_IDX_JOBDEF_PROC_DEF_ID` (`PROC_DEF_ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*Data for the table `act_ru_jobdef` */

/*Table structure for table `act_ru_meter_log` */

DROP TABLE IF EXISTS `act_ru_meter_log`;

CREATE TABLE `act_ru_meter_log` (
                                    `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                    `NAME_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                    `REPORTER_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                                    `VALUE_` bigint DEFAULT NULL,
                                    `TIMESTAMP_` datetime DEFAULT NULL,
                                    `MILLISECONDS_` bigint DEFAULT '0',
                                    PRIMARY KEY (`ID_`),
                                    KEY `ACT_IDX_METER_LOG_MS` (`MILLISECONDS_`),
                                    KEY `ACT_IDX_METER_LOG_NAME_MS` (`NAME_`,`MILLISECONDS_`),
                                    KEY `ACT_IDX_METER_LOG_REPORT` (`NAME_`,`REPORTER_`,`MILLISECONDS_`),
                                    KEY `ACT_IDX_METER_LOG_TIME` (`TIMESTAMP_`),
                                    KEY `ACT_IDX_METER_LOG` (`NAME_`,`TIMESTAMP_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*Data for the table `act_ru_meter_log` */

insert  into `act_ru_meter_log`(`ID_`,`NAME_`,`REPORTER_`,`VALUE_`,`TIMESTAMP_`,`MILLISECONDS_`) values
                                                                                                     ('1d1cb37d-439e-11f1-a8d7-c894025bbc03','root-process-instance-start','192.168.30.5$default',0,'2026-04-29 15:36:20',1777448179749),
                                                                                                     ('1d1cb37e-439e-11f1-a8d7-c894025bbc03','activity-instance-start','192.168.30.5$default',3,'2026-04-29 15:36:20',1777448179749),
                                                                                                     ('1d1cb37f-439e-11f1-a8d7-c894025bbc03','job-acquired-failure','192.168.30.5$default',0,'2026-04-29 15:36:20',1777448179749),
                                                                                                     ('1d1cb380-439e-11f1-a8d7-c894025bbc03','job-locked-exclusive','192.168.30.5$default',0,'2026-04-29 15:36:20',1777448179749),
                                                                                                     ('1d1cb381-439e-11f1-a8d7-c894025bbc03','job-execution-rejected','192.168.30.5$default',0,'2026-04-29 15:36:20',1777448179749),
                                                                                                     ('1d1cb382-439e-11f1-a8d7-c894025bbc03','executed-decision-elements','192.168.30.5$default',0,'2026-04-29 15:36:20',1777448179749),
                                                                                                     ('1d1cb383-439e-11f1-a8d7-c894025bbc03','activity-instance-end','192.168.30.5$default',4,'2026-04-29 15:36:20',1777448179749),
                                                                                                     ('1d1cb384-439e-11f1-a8d7-c894025bbc03','job-successful','192.168.30.5$default',0,'2026-04-29 15:36:20',1777448179749),
                                                                                                     ('1d1cb385-439e-11f1-a8d7-c894025bbc03','job-acquired-success','192.168.30.5$default',0,'2026-04-29 15:36:20',1777448179749),
                                                                                                     ('1d1cb386-439e-11f1-a8d7-c894025bbc03','job-acquisition-attempt','192.168.30.5$default',18,'2026-04-29 15:36:20',1777448179749),
                                                                                                     ('1d1cb387-439e-11f1-a8d7-c894025bbc03','executed-decision-instances','192.168.30.5$default',0,'2026-04-29 15:36:20',1777448179749),
                                                                                                     ('1d1cb388-439e-11f1-a8d7-c894025bbc03','job-failed','192.168.30.5$default',0,'2026-04-29 15:36:20',1777448179749),
                                                                                                     ('4e2a0bd2-43a1-11f1-a472-c894025bbc03','root-process-instance-start','192.168.30.5$default',0,'2026-04-29 15:59:11',1777449550535),
                                                                                                     ('4e2a0bd3-43a1-11f1-a472-c894025bbc03','activity-instance-start','192.168.30.5$default',0,'2026-04-29 15:59:11',1777449550535),
                                                                                                     ('4e2a0bd4-43a1-11f1-a472-c894025bbc03','job-acquired-failure','192.168.30.5$default',0,'2026-04-29 15:59:11',1777449550535),
                                                                                                     ('4e2a0bd5-43a1-11f1-a472-c894025bbc03','job-locked-exclusive','192.168.30.5$default',0,'2026-04-29 15:59:11',1777449550535),
                                                                                                     ('4e2a0bd6-43a1-11f1-a472-c894025bbc03','job-execution-rejected','192.168.30.5$default',0,'2026-04-29 15:59:11',1777449550535),
                                                                                                     ('4e2a0bd7-43a1-11f1-a472-c894025bbc03','executed-decision-elements','192.168.30.5$default',0,'2026-04-29 15:59:11',1777449550535),
                                                                                                     ('4e2a0bd8-43a1-11f1-a472-c894025bbc03','activity-instance-end','192.168.30.5$default',0,'2026-04-29 15:59:11',1777449550535),
                                                                                                     ('4e2a0bd9-43a1-11f1-a472-c894025bbc03','job-successful','192.168.30.5$default',0,'2026-04-29 15:59:11',1777449550535),
                                                                                                     ('4e2a0bda-43a1-11f1-a472-c894025bbc03','job-acquired-success','192.168.30.5$default',0,'2026-04-29 15:59:11',1777449550535),
                                                                                                     ('4e2a0bdb-43a1-11f1-a472-c894025bbc03','job-acquisition-attempt','192.168.30.5$default',18,'2026-04-29 15:59:11',1777449550535),
                                                                                                     ('4e2a0bdc-43a1-11f1-a472-c894025bbc03','executed-decision-instances','192.168.30.5$default',0,'2026-04-29 15:59:11',1777449550535),
                                                                                                     ('4e2a0bdd-43a1-11f1-a472-c894025bbc03','job-failed','192.168.30.5$default',0,'2026-04-29 15:59:11',1777449550535),
                                                                                                     ('669c374e-43a3-11f1-a472-c894025bbc03','root-process-instance-start','192.168.30.5$default',0,'2026-04-29 16:14:11',1777450450544),
                                                                                                     ('669c374f-43a3-11f1-a472-c894025bbc03','activity-instance-start','192.168.30.5$default',0,'2026-04-29 16:14:11',1777450450544),
                                                                                                     ('669c3750-43a3-11f1-a472-c894025bbc03','job-acquired-failure','192.168.30.5$default',0,'2026-04-29 16:14:11',1777450450544),
                                                                                                     ('669c3751-43a3-11f1-a472-c894025bbc03','job-locked-exclusive','192.168.30.5$default',0,'2026-04-29 16:14:11',1777450450544),
                                                                                                     ('669c3752-43a3-11f1-a472-c894025bbc03','job-execution-rejected','192.168.30.5$default',0,'2026-04-29 16:14:11',1777450450544),
                                                                                                     ('669c3753-43a3-11f1-a472-c894025bbc03','executed-decision-elements','192.168.30.5$default',0,'2026-04-29 16:14:11',1777450450544),
                                                                                                     ('669c3754-43a3-11f1-a472-c894025bbc03','activity-instance-end','192.168.30.5$default',0,'2026-04-29 16:14:11',1777450450544),
                                                                                                     ('669c3755-43a3-11f1-a472-c894025bbc03','job-successful','192.168.30.5$default',0,'2026-04-29 16:14:11',1777450450544),
                                                                                                     ('669c3756-43a3-11f1-a472-c894025bbc03','job-acquired-success','192.168.30.5$default',0,'2026-04-29 16:14:11',1777450450544),
                                                                                                     ('669c3757-43a3-11f1-a472-c894025bbc03','job-acquisition-attempt','192.168.30.5$default',15,'2026-04-29 16:14:11',1777450450544),
                                                                                                     ('669c3758-43a3-11f1-a472-c894025bbc03','executed-decision-instances','192.168.30.5$default',0,'2026-04-29 16:14:11',1777450450544),
                                                                                                     ('669c3759-43a3-11f1-a472-c894025bbc03','job-failed','192.168.30.5$default',0,'2026-04-29 16:14:11',1777450450544),
                                                                                                     ('7f0c8e0a-43a5-11f1-a472-c894025bbc03','root-process-instance-start','192.168.30.5$default',0,'2026-04-29 16:29:11',1777451350539),
                                                                                                     ('7f0c8e0b-43a5-11f1-a472-c894025bbc03','activity-instance-start','192.168.30.5$default',0,'2026-04-29 16:29:11',1777451350539),
                                                                                                     ('7f0c8e0c-43a5-11f1-a472-c894025bbc03','job-acquired-failure','192.168.30.5$default',0,'2026-04-29 16:29:11',1777451350539),
                                                                                                     ('7f0c8e0d-43a5-11f1-a472-c894025bbc03','job-locked-exclusive','192.168.30.5$default',0,'2026-04-29 16:29:11',1777451350539),
                                                                                                     ('7f0c8e0e-43a5-11f1-a472-c894025bbc03','job-execution-rejected','192.168.30.5$default',0,'2026-04-29 16:29:11',1777451350539),
                                                                                                     ('7f0c8e0f-43a5-11f1-a472-c894025bbc03','executed-decision-elements','192.168.30.5$default',0,'2026-04-29 16:29:11',1777451350539),
                                                                                                     ('7f0c8e10-43a5-11f1-a472-c894025bbc03','activity-instance-end','192.168.30.5$default',0,'2026-04-29 16:29:11',1777451350539),
                                                                                                     ('7f0c8e11-43a5-11f1-a472-c894025bbc03','job-successful','192.168.30.5$default',0,'2026-04-29 16:29:11',1777451350539),
                                                                                                     ('7f0c8e12-43a5-11f1-a472-c894025bbc03','job-acquired-success','192.168.30.5$default',0,'2026-04-29 16:29:11',1777451350539),
                                                                                                     ('7f0c8e13-43a5-11f1-a472-c894025bbc03','job-acquisition-attempt','192.168.30.5$default',15,'2026-04-29 16:29:11',1777451350539),
                                                                                                     ('7f0c8e14-43a5-11f1-a472-c894025bbc03','executed-decision-instances','192.168.30.5$default',0,'2026-04-29 16:29:11',1777451350539),
                                                                                                     ('7f0c8e15-43a5-11f1-a472-c894025bbc03','job-failed','192.168.30.5$default',0,'2026-04-29 16:29:11',1777451350539),
                                                                                                     ('977d59f6-43a7-11f1-a472-c894025bbc03','root-process-instance-start','192.168.30.5$default',0,'2026-04-29 16:44:11',1777452250537),
                                                                                                     ('977d59f7-43a7-11f1-a472-c894025bbc03','activity-instance-start','192.168.30.5$default',0,'2026-04-29 16:44:11',1777452250537),
                                                                                                     ('977d59f8-43a7-11f1-a472-c894025bbc03','job-acquired-failure','192.168.30.5$default',0,'2026-04-29 16:44:11',1777452250537),
                                                                                                     ('977d59f9-43a7-11f1-a472-c894025bbc03','job-locked-exclusive','192.168.30.5$default',0,'2026-04-29 16:44:11',1777452250537),
                                                                                                     ('977d59fa-43a7-11f1-a472-c894025bbc03','job-execution-rejected','192.168.30.5$default',0,'2026-04-29 16:44:11',1777452250537),
                                                                                                     ('977d59fb-43a7-11f1-a472-c894025bbc03','executed-decision-elements','192.168.30.5$default',0,'2026-04-29 16:44:11',1777452250537),
                                                                                                     ('977d59fc-43a7-11f1-a472-c894025bbc03','activity-instance-end','192.168.30.5$default',0,'2026-04-29 16:44:11',1777452250537),
                                                                                                     ('977d59fd-43a7-11f1-a472-c894025bbc03','job-successful','192.168.30.5$default',0,'2026-04-29 16:44:11',1777452250537),
                                                                                                     ('977d59fe-43a7-11f1-a472-c894025bbc03','job-acquired-success','192.168.30.5$default',0,'2026-04-29 16:44:11',1777452250537),
                                                                                                     ('977d59ff-43a7-11f1-a472-c894025bbc03','job-acquisition-attempt','192.168.30.5$default',15,'2026-04-29 16:44:11',1777452250537),
                                                                                                     ('977d5a00-43a7-11f1-a472-c894025bbc03','executed-decision-instances','192.168.30.5$default',0,'2026-04-29 16:44:11',1777452250537),
                                                                                                     ('977d5a01-43a7-11f1-a472-c894025bbc03','job-failed','192.168.30.5$default',0,'2026-04-29 16:44:11',1777452250537),
                                                                                                     ('afedb0b2-43a9-11f1-a472-c894025bbc03','root-process-instance-start','192.168.30.5$default',0,'2026-04-29 16:59:11',1777453150532),
                                                                                                     ('afedb0b3-43a9-11f1-a472-c894025bbc03','activity-instance-start','192.168.30.5$default',0,'2026-04-29 16:59:11',1777453150532),
                                                                                                     ('afedb0b4-43a9-11f1-a472-c894025bbc03','job-acquired-failure','192.168.30.5$default',0,'2026-04-29 16:59:11',1777453150532),
                                                                                                     ('afedb0b5-43a9-11f1-a472-c894025bbc03','job-locked-exclusive','192.168.30.5$default',0,'2026-04-29 16:59:11',1777453150532),
                                                                                                     ('afedb0b6-43a9-11f1-a472-c894025bbc03','job-execution-rejected','192.168.30.5$default',0,'2026-04-29 16:59:11',1777453150532),
                                                                                                     ('afedb0b7-43a9-11f1-a472-c894025bbc03','executed-decision-elements','192.168.30.5$default',0,'2026-04-29 16:59:11',1777453150532),
                                                                                                     ('afedb0b8-43a9-11f1-a472-c894025bbc03','activity-instance-end','192.168.30.5$default',0,'2026-04-29 16:59:11',1777453150532),
                                                                                                     ('afedb0b9-43a9-11f1-a472-c894025bbc03','job-successful','192.168.30.5$default',0,'2026-04-29 16:59:11',1777453150532),
                                                                                                     ('afedb0ba-43a9-11f1-a472-c894025bbc03','job-acquired-success','192.168.30.5$default',0,'2026-04-29 16:59:11',1777453150532),
                                                                                                     ('afedb0bb-43a9-11f1-a472-c894025bbc03','job-acquisition-attempt','192.168.30.5$default',15,'2026-04-29 16:59:11',1777453150532),
                                                                                                     ('afedb0bc-43a9-11f1-a472-c894025bbc03','executed-decision-instances','192.168.30.5$default',0,'2026-04-29 16:59:11',1777453150532),
                                                                                                     ('afedb0bd-43a9-11f1-a472-c894025bbc03','job-failed','192.168.30.5$default',0,'2026-04-29 16:59:11',1777453150532),
                                                                                                     ('c0d91977-48f0-11f1-a52d-c894025bbc03','root-process-instance-start','192.168.30.5$default',0,'2026-05-06 10:10:29',1778033429000),
                                                                                                     ('c0d91978-48f0-11f1-a52d-c894025bbc03','activity-instance-start','192.168.30.5$default',0,'2026-05-06 10:10:29',1778033429000),
                                                                                                     ('c0d91979-48f0-11f1-a52d-c894025bbc03','job-acquired-failure','192.168.30.5$default',0,'2026-05-06 10:10:29',1778033429000),
                                                                                                     ('c0d9197a-48f0-11f1-a52d-c894025bbc03','job-locked-exclusive','192.168.30.5$default',0,'2026-05-06 10:10:29',1778033429000),
                                                                                                     ('c0d9197b-48f0-11f1-a52d-c894025bbc03','job-execution-rejected','192.168.30.5$default',0,'2026-05-06 10:10:29',1778033429000),
                                                                                                     ('c0d9197c-48f0-11f1-a52d-c894025bbc03','executed-decision-elements','192.168.30.5$default',0,'2026-05-06 10:10:29',1778033429000),
                                                                                                     ('c0d9197d-48f0-11f1-a52d-c894025bbc03','activity-instance-end','192.168.30.5$default',0,'2026-05-06 10:10:29',1778033429000),
                                                                                                     ('c0d9197e-48f0-11f1-a52d-c894025bbc03','job-successful','192.168.30.5$default',0,'2026-05-06 10:10:29',1778033429000),
                                                                                                     ('c0d9197f-48f0-11f1-a52d-c894025bbc03','job-acquired-success','192.168.30.5$default',0,'2026-05-06 10:10:29',1778033429000),
                                                                                                     ('c0d91980-48f0-11f1-a52d-c894025bbc03','job-acquisition-attempt','192.168.30.5$default',18,'2026-05-06 10:10:29',1778033429000),
                                                                                                     ('c0d91981-48f0-11f1-a52d-c894025bbc03','executed-decision-instances','192.168.30.5$default',0,'2026-05-06 10:10:29',1778033429000),
                                                                                                     ('c0d91982-48f0-11f1-a52d-c894025bbc03','job-failed','192.168.30.5$default',0,'2026-05-06 10:10:29',1778033429000);

/*Table structure for table `act_ru_task` */

DROP TABLE IF EXISTS `act_ru_task`;

CREATE TABLE `act_ru_task` (
                               `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                               `REV_` int DEFAULT NULL,
                               `EXECUTION_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                               `PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                               `PROC_DEF_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                               `CASE_EXECUTION_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                               `CASE_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                               `CASE_DEF_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                               `NAME_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                               `PARENT_TASK_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                               `DESCRIPTION_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
                               `TASK_DEF_KEY_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                               `OWNER_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                               `ASSIGNEE_` varchar(255) COLLATE utf8mb3_bin DEFAULT NULL,
                               `DELEGATION_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                               `PRIORITY_` int DEFAULT NULL,
                               `CREATE_TIME_` datetime DEFAULT NULL,
                               `LAST_UPDATED_` datetime DEFAULT NULL,
                               `DUE_DATE_` datetime DEFAULT NULL,
                               `FOLLOW_UP_DATE_` datetime DEFAULT NULL,
                               `SUSPENSION_STATE_` int DEFAULT NULL,
                               `TENANT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                               `TASK_STATE_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                               PRIMARY KEY (`ID_`),
                               KEY `ACT_IDX_TASK_CREATE` (`CREATE_TIME_`),
                               KEY `ACT_IDX_TASK_LAST_UPDATED` (`LAST_UPDATED_`),
                               KEY `ACT_IDX_TASK_ASSIGNEE` (`ASSIGNEE_`),
                               KEY `ACT_IDX_TASK_OWNER` (`OWNER_`),
                               KEY `ACT_IDX_TASK_TENANT_ID` (`TENANT_ID_`),
                               KEY `ACT_FK_TASK_EXE` (`EXECUTION_ID_`),
                               KEY `ACT_FK_TASK_PROCINST` (`PROC_INST_ID_`),
                               KEY `ACT_FK_TASK_PROCDEF` (`PROC_DEF_ID_`),
                               KEY `ACT_FK_TASK_CASE_EXE` (`CASE_EXECUTION_ID_`),
                               KEY `ACT_FK_TASK_CASE_DEF` (`CASE_DEF_ID_`),
                               CONSTRAINT `ACT_FK_TASK_CASE_DEF` FOREIGN KEY (`CASE_DEF_ID_`) REFERENCES `act_re_case_def` (`ID_`),
                               CONSTRAINT `ACT_FK_TASK_CASE_EXE` FOREIGN KEY (`CASE_EXECUTION_ID_`) REFERENCES `act_ru_case_execution` (`ID_`),
                               CONSTRAINT `ACT_FK_TASK_EXE` FOREIGN KEY (`EXECUTION_ID_`) REFERENCES `act_ru_execution` (`ID_`),
                               CONSTRAINT `ACT_FK_TASK_PROCDEF` FOREIGN KEY (`PROC_DEF_ID_`) REFERENCES `act_re_procdef` (`ID_`),
                               CONSTRAINT `ACT_FK_TASK_PROCINST` FOREIGN KEY (`PROC_INST_ID_`) REFERENCES `act_ru_execution` (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*Data for the table `act_ru_task` */

/*Table structure for table `act_ru_task_meter_log` */

DROP TABLE IF EXISTS `act_ru_task_meter_log`;

CREATE TABLE `act_ru_task_meter_log` (
                                         `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                         `ASSIGNEE_HASH_` bigint DEFAULT NULL,
                                         `TIMESTAMP_` datetime DEFAULT NULL,
                                         PRIMARY KEY (`ID_`),
                                         KEY `ACT_IDX_TASK_METER_LOG_TIME` (`TIMESTAMP_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*Data for the table `act_ru_task_meter_log` */

/*Table structure for table `act_ru_variable` */

DROP TABLE IF EXISTS `act_ru_variable`;

CREATE TABLE `act_ru_variable` (
                                   `ID_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                   `REV_` int DEFAULT NULL,
                                   `TYPE_` varchar(255) COLLATE utf8mb3_bin NOT NULL,
                                   `NAME_` varchar(255) COLLATE utf8mb3_bin NOT NULL,
                                   `EXECUTION_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `PROC_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `PROC_DEF_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `CASE_EXECUTION_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `CASE_INST_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `TASK_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `BATCH_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `BYTEARRAY_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `DOUBLE_` double DEFAULT NULL,
                                   `LONG_` bigint DEFAULT NULL,
                                   `TEXT_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `TEXT2_` varchar(4000) COLLATE utf8mb3_bin DEFAULT NULL,
                                   `VAR_SCOPE_` varchar(64) COLLATE utf8mb3_bin NOT NULL,
                                   `SEQUENCE_COUNTER_` bigint DEFAULT NULL,
                                   `IS_CONCURRENT_LOCAL_` tinyint DEFAULT NULL,
                                   `TENANT_ID_` varchar(64) COLLATE utf8mb3_bin DEFAULT NULL,
                                   PRIMARY KEY (`ID_`),
                                   UNIQUE KEY `ACT_UNIQ_VARIABLE` (`VAR_SCOPE_`,`NAME_`),
                                   KEY `ACT_IDX_VARIABLE_TASK_ID` (`TASK_ID_`),
                                   KEY `ACT_IDX_VARIABLE_TENANT_ID` (`TENANT_ID_`),
                                   KEY `ACT_IDX_VARIABLE_TASK_NAME_TYPE` (`TASK_ID_`,`NAME_`,`TYPE_`),
                                   KEY `ACT_FK_VAR_EXE` (`EXECUTION_ID_`),
                                   KEY `ACT_FK_VAR_PROCINST` (`PROC_INST_ID_`),
                                   KEY `ACT_FK_VAR_BYTEARRAY` (`BYTEARRAY_ID_`),
                                   KEY `ACT_IDX_BATCH_ID` (`BATCH_ID_`),
                                   KEY `ACT_FK_VAR_CASE_EXE` (`CASE_EXECUTION_ID_`),
                                   KEY `ACT_FK_VAR_CASE_INST` (`CASE_INST_ID_`),
                                   CONSTRAINT `ACT_FK_VAR_BATCH` FOREIGN KEY (`BATCH_ID_`) REFERENCES `act_ru_batch` (`ID_`),
                                   CONSTRAINT `ACT_FK_VAR_BYTEARRAY` FOREIGN KEY (`BYTEARRAY_ID_`) REFERENCES `act_ge_bytearray` (`ID_`),
                                   CONSTRAINT `ACT_FK_VAR_CASE_EXE` FOREIGN KEY (`CASE_EXECUTION_ID_`) REFERENCES `act_ru_case_execution` (`ID_`),
                                   CONSTRAINT `ACT_FK_VAR_CASE_INST` FOREIGN KEY (`CASE_INST_ID_`) REFERENCES `act_ru_case_execution` (`ID_`),
                                   CONSTRAINT `ACT_FK_VAR_EXE` FOREIGN KEY (`EXECUTION_ID_`) REFERENCES `act_ru_execution` (`ID_`),
                                   CONSTRAINT `ACT_FK_VAR_PROCINST` FOREIGN KEY (`PROC_INST_ID_`) REFERENCES `act_ru_execution` (`ID_`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_bin;

/*Data for the table `act_ru_variable` */

/*Table structure for table `asn` */

DROP TABLE IF EXISTS `asn`;

CREATE TABLE `asn` (
                       `id` bigint NOT NULL AUTO_INCREMENT,
                       `tenant_id` bigint NOT NULL COMMENT '租户ID',
                       `asn_no` varchar(32) NOT NULL COMMENT 'ASN单号',
                       `supplier_name` varchar(100) DEFAULT NULL COMMENT '供应商名称',
                       `expected_date` datetime DEFAULT NULL COMMENT '预计到货时间',
                       `status` tinyint DEFAULT '0' COMMENT '0-待收货 1-收货中 2-已完成 3-已取消',
                       `total_quantity` int DEFAULT '0' COMMENT '总数量',
                       `received_quantity` int DEFAULT '0' COMMENT '已收数量',
                       `remark` varchar(500) DEFAULT NULL COMMENT '备注',
                       `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
                       `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                       PRIMARY KEY (`id`),
                       UNIQUE KEY `uk_asn_no` (`asn_no`),
                       KEY `idx_tenant_status` (`tenant_id`,`status`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `asn` */

insert  into `asn`(`id`,`tenant_id`,`asn_no`,`supplier_name`,`expected_date`,`status`,`total_quantity`,`received_quantity`,`remark`,`create_time`,`update_time`) values
    (1,1,'ASN20260414001','供应商1','2026-04-15 08:59:00',2,2,2,'',NULL,NULL);

/*Table structure for table `asn_detail` */

DROP TABLE IF EXISTS `asn_detail`;

CREATE TABLE `asn_detail` (
                              `id` bigint NOT NULL AUTO_INCREMENT,
                              `tenant_id` bigint NOT NULL,
                              `asn_id` bigint NOT NULL COMMENT 'ASN主表ID',
                              `sku_code` varchar(50) NOT NULL COMMENT '商品编码',
                              `sku_name` varchar(200) DEFAULT NULL COMMENT '商品名称',
                              `expected_quantity` int NOT NULL COMMENT '预期数量',
                              `received_quantity` int DEFAULT '0' COMMENT '已收数量',
                              `qualified_quantity` int DEFAULT '0' COMMENT '合格数量',
                              `unit` varchar(10) DEFAULT NULL COMMENT '单位',
                              `remark` varchar(500) DEFAULT NULL,
                              PRIMARY KEY (`id`),
                              KEY `idx_asn_id` (`asn_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `asn_detail` */

insert  into `asn_detail`(`id`,`tenant_id`,`asn_id`,`sku_code`,`sku_name`,`expected_quantity`,`received_quantity`,`qualified_quantity`,`unit`,`remark`) values
    (1,1,1,'sku001','酒精',2,0,0,'ml',NULL);

/*Table structure for table `inventory` */

DROP TABLE IF EXISTS `inventory`;

CREATE TABLE `inventory` (
                             `id` bigint NOT NULL AUTO_INCREMENT,
                             `tenant_id` bigint NOT NULL,
                             `sku_code` varchar(50) NOT NULL,
                             `sku_name` varchar(200) DEFAULT NULL,
                             `location_id` bigint NOT NULL COMMENT '货位ID',
                             `batch_no` varchar(50) DEFAULT NULL COMMENT '批次号',
                             `quantity` int NOT NULL DEFAULT '0' COMMENT '库存数量',
                             `locked_quantity` int DEFAULT '0' COMMENT '锁定数量（出库占用）',
                             `production_date` datetime DEFAULT NULL COMMENT '生产日期',
                             `expiry_date` datetime DEFAULT NULL COMMENT '有效期',
                             `last_update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                             PRIMARY KEY (`id`),
                             KEY `idx_sku_location` (`sku_code`,`location_id`),
                             KEY `idx_batch` (`batch_no`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `inventory` */

insert  into `inventory`(`id`,`tenant_id`,`sku_code`,`sku_name`,`location_id`,`batch_no`,`quantity`,`locked_quantity`,`production_date`,`expiry_date`,`last_update_time`) values
                                                                                                                                                                              (1,1,'sku001','酒精',1,'BATCH1776128418561',0,0,'2026-04-14 00:00:00','2027-01-01 00:00:00','2026-04-14 09:02:07'),
                                                                                                                                                                              (2,1,'sku001','酒精',2,'BATCH1776128418561',1,0,'2026-04-14 00:00:00','2027-01-01 00:00:00','2026-04-14 15:07:33');

/*Table structure for table `inventory_freeze_log` */

DROP TABLE IF EXISTS `inventory_freeze_log`;

CREATE TABLE `inventory_freeze_log` (
                                        `id` bigint NOT NULL AUTO_INCREMENT,
                                        `tenant_id` bigint NOT NULL,
                                        `inventory_id` bigint NOT NULL,
                                        `sku_code` varchar(50) NOT NULL,
                                        `quantity` int NOT NULL COMMENT '冻结数量',
                                        `order_no` varchar(32) DEFAULT NULL COMMENT '关联订单号',
                                        `reason` varchar(200) DEFAULT NULL COMMENT '冻结原因',
                                        `status` tinyint DEFAULT '0' COMMENT '0-冻结中 1-已解冻 2-已扣减',
                                        `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
                                        `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                        PRIMARY KEY (`id`),
                                        KEY `idx_inventory_id` (`inventory_id`),
                                        KEY `idx_order_no` (`order_no`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `inventory_freeze_log` */

insert  into `inventory_freeze_log`(`id`,`tenant_id`,`inventory_id`,`sku_code`,`quantity`,`order_no`,`reason`,`status`,`create_time`,`update_time`) values
    (1,1,1,'sku001',1,'ASN20260414001','出库锁定',1,NULL,NULL);

/*Table structure for table `iot_alert` */

DROP TABLE IF EXISTS `iot_alert`;

CREATE TABLE `iot_alert` (
                             `id` bigint NOT NULL AUTO_INCREMENT,
                             `tenant_id` bigint NOT NULL,
                             `device_id` varchar(50) NOT NULL COMMENT '设备ID',
                             `device_type` varchar(20) DEFAULT NULL COMMENT '设备类型(temp/humidity)',
                             `alert_type` varchar(50) DEFAULT NULL COMMENT '告警类型(high_temp/low_temp/high_humidity)',
                             `alert_value` decimal(10,2) DEFAULT NULL COMMENT '触发告警的值',
                             `threshold_value` decimal(10,2) DEFAULT NULL COMMENT '阈值',
                             `alert_message` varchar(500) DEFAULT NULL COMMENT '告警消息',
                             `status` tinyint DEFAULT '0' COMMENT '0-未处理 1-已处理',
                             `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
                             `handle_time` datetime DEFAULT NULL,
                             `handler` varchar(50) DEFAULT NULL,
                             PRIMARY KEY (`id`),
                             KEY `idx_device_time` (`device_id`,`create_time`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `iot_alert` */

insert  into `iot_alert`(`id`,`tenant_id`,`device_id`,`device_type`,`alert_type`,`alert_value`,`threshold_value`,`alert_message`,`status`,`create_time`,`handle_time`,`handler`) values
                                                                                                                                                                                     (1,1,'sensor_01','temp','HIGH_TEMP',31.60,30.00,'温度过高告警：当前温度 31.6℃ > 阈值 30.0℃',0,'2026-04-15 13:39:05',NULL,NULL),
                                                                                                                                                                                     (2,1,'sensor_01','temp','HIGH_TEMP',33.80,30.00,'温度过高告警：当前温度 33.8℃ > 阈值 30.0℃',0,'2026-04-15 13:44:41',NULL,NULL),
                                                                                                                                                                                     (3,1,'sensor_01','temp','HIGH_TEMP',34.30,30.00,'温度过高告警：当前温度 34.3℃ > 阈值 30.0℃',0,'2026-04-15 13:54:46',NULL,NULL);

/*Table structure for table `location` */

DROP TABLE IF EXISTS `location`;

CREATE TABLE `location` (
                            `id` bigint NOT NULL AUTO_INCREMENT,
                            `tenant_id` bigint NOT NULL,
                            `location_code` varchar(32) NOT NULL COMMENT '货位编码',
                            `zone` varchar(20) DEFAULT NULL COMMENT '库区（A/B/C/D）',
                            `row_no` varchar(10) DEFAULT NULL COMMENT '排',
                            `col_no` varchar(10) DEFAULT NULL COMMENT '列',
                            `level_no` varchar(10) DEFAULT NULL COMMENT '层',
                            `status` tinyint DEFAULT '1' COMMENT '1-可用 0-禁用 2-满货',
                            `max_weight` decimal(10,2) DEFAULT NULL COMMENT '最大承重(kg)',
                            `max_volume` decimal(10,2) DEFAULT NULL COMMENT '最大容积(m³)',
                            `current_sku_code` varchar(50) DEFAULT NULL COMMENT '当前存放的商品',
                            `current_quantity` int DEFAULT '0' COMMENT '当前数量',
                            `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
                            PRIMARY KEY (`id`),
                            UNIQUE KEY `uk_location_code` (`location_code`),
                            KEY `idx_zone` (`zone`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `location` */

insert  into `location`(`id`,`tenant_id`,`location_code`,`zone`,`row_no`,`col_no`,`level_no`,`status`,`max_weight`,`max_volume`,`current_sku_code`,`current_quantity`,`create_time`) values
                                                                                                                                                                                         (1,1,'A-01-01','A','01','01','01',1,NULL,NULL,'sku001',2,'2026-04-13 16:18:07'),
                                                                                                                                                                                         (2,1,'A-01-02','A','01','02','01',1,NULL,NULL,NULL,0,'2026-04-13 16:18:07'),
                                                                                                                                                                                         (3,1,'B-01-01','B','01','01','01',1,NULL,NULL,NULL,0,'2026-04-13 16:18:07'),
                                                                                                                                                                                         (4,1,'C-01-01','C','01','01','01',1,NULL,NULL,NULL,0,'2026-04-13 16:18:07');

/*Table structure for table `outbound_detail` */

DROP TABLE IF EXISTS `outbound_detail`;

CREATE TABLE `outbound_detail` (
                                   `id` bigint NOT NULL AUTO_INCREMENT,
                                   `tenant_id` bigint NOT NULL,
                                   `order_id` bigint NOT NULL,
                                   `sku_code` varchar(50) NOT NULL,
                                   `sku_name` varchar(200) DEFAULT NULL,
                                   `quantity` int NOT NULL,
                                   `picked_quantity` int DEFAULT '0',
                                   `inventory_id` bigint DEFAULT NULL COMMENT '锁定库存ID',
                                   `batch_no` varchar(50) DEFAULT NULL,
                                   `location_code` varchar(32) DEFAULT NULL COMMENT '拣货货位',
                                   PRIMARY KEY (`id`),
                                   KEY `idx_order_id` (`order_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `outbound_detail` */

insert  into `outbound_detail`(`id`,`tenant_id`,`order_id`,`sku_code`,`sku_name`,`quantity`,`picked_quantity`,`inventory_id`,`batch_no`,`location_code`) values
    (1,1,1,'sku001','酒精',1,0,NULL,NULL,NULL);

/*Table structure for table `outbound_exception` */

DROP TABLE IF EXISTS `outbound_exception`;

CREATE TABLE `outbound_exception` (
                                      `id` bigint NOT NULL AUTO_INCREMENT,
                                      `tenant_id` bigint NOT NULL,
                                      `order_id` bigint NOT NULL,
                                      `order_no` varchar(32) NOT NULL,
                                      `exception_type` varchar(50) DEFAULT NULL COMMENT 'INSUFFICIENT_STOCK/ADDRESS_ERROR/OTHER',
                                      `exception_detail` varchar(500) DEFAULT NULL COMMENT '异常详情',
                                      `status` tinyint DEFAULT '0' COMMENT '0-待处理 1-处理中 2-已处理 3-已忽略',
                                      `suggestion` varchar(500) DEFAULT NULL COMMENT 'AI处理建议',
                                      `handler` varchar(50) DEFAULT NULL,
                                      `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
                                      `handle_time` datetime DEFAULT NULL,
                                      PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `outbound_exception` */

/*Table structure for table `outbound_order` */

DROP TABLE IF EXISTS `outbound_order`;

CREATE TABLE `outbound_order` (
                                  `id` bigint NOT NULL AUTO_INCREMENT,
                                  `tenant_id` bigint NOT NULL,
                                  `order_no` varchar(32) NOT NULL COMMENT '出库单号',
                                  `order_type` tinyint DEFAULT '0' COMMENT '0-销售出库 1-采购退货 2-调拨出库',
                                  `customer_name` varchar(100) DEFAULT NULL COMMENT '客户名称',
                                  `priority` tinyint DEFAULT '0' COMMENT '优先级 0-普通 1-加急 2-特急',
                                  `status` tinyint DEFAULT '0' COMMENT '0-待分配 1-拣货中 2-已拣货 3-已打包 4-已出库 5-已取消',
                                  `total_quantity` int DEFAULT '0',
                                  `picked_quantity` int DEFAULT '0',
                                  `wave_id` bigint DEFAULT NULL COMMENT '波次ID',
                                  `remark` varchar(500) DEFAULT NULL,
                                  `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
                                  `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                  PRIMARY KEY (`id`),
                                  UNIQUE KEY `uk_order_no` (`order_no`),
                                  KEY `idx_tenant_status` (`tenant_id`,`status`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `outbound_order` */

insert  into `outbound_order`(`id`,`tenant_id`,`order_no`,`order_type`,`customer_name`,`priority`,`status`,`total_quantity`,`picked_quantity`,`wave_id`,`remark`,`create_time`,`update_time`) values
    (1,1,'OUT20260414001',0,'彭永泰',0,4,1,0,2,'',NULL,'2026-04-14 10:39:59');

/*Table structure for table `picking_task` */

DROP TABLE IF EXISTS `picking_task`;

CREATE TABLE `picking_task` (
                                `id` bigint NOT NULL AUTO_INCREMENT,
                                `tenant_id` bigint NOT NULL,
                                `wave_id` bigint NOT NULL,
                                `picker_id` bigint DEFAULT NULL COMMENT '拣货员ID',
                                `picker_name` varchar(50) DEFAULT NULL,
                                `route_path` text COMMENT '规划路径',
                                `status` tinyint DEFAULT '0' COMMENT '0-待拣货 1-拣货中 2-已完成',
                                `start_time` datetime DEFAULT NULL,
                                `end_time` datetime DEFAULT NULL,
                                `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
                                `update_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
                                PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `picking_task` */

insert  into `picking_task`(`id`,`tenant_id`,`wave_id`,`picker_id`,`picker_name`,`route_path`,`status`,`start_time`,`end_time`,`create_time`,`update_time`) values
                                                                                                                                                                (1,1,1,1001,'张三','',1,'2026-04-14 10:37:01','2026-04-14 10:34:10',NULL,NULL),
                                                                                                                                                                (2,1,2,1001,'张三','A-01-01',2,'2026-04-14 10:44:59','2026-04-14 10:45:13',NULL,NULL);

/*Table structure for table `receiving` */

DROP TABLE IF EXISTS `receiving`;

CREATE TABLE `receiving` (
                             `id` bigint NOT NULL AUTO_INCREMENT,
                             `tenant_id` bigint NOT NULL,
                             `receiving_no` varchar(32) NOT NULL COMMENT '收货单号',
                             `asn_id` bigint DEFAULT NULL COMMENT '关联ASN',
                             `supplier_name` varchar(100) DEFAULT NULL,
                             `receiving_time` datetime DEFAULT NULL COMMENT '收货时间',
                             `status` tinyint DEFAULT '0' COMMENT '0-待质检 1-质检中 2-已完成',
                             `operator` varchar(50) DEFAULT NULL COMMENT '操作人',
                             `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
                             PRIMARY KEY (`id`),
                             UNIQUE KEY `uk_receiving_no` (`receiving_no`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `receiving` */

insert  into `receiving`(`id`,`tenant_id`,`receiving_no`,`asn_id`,`supplier_name`,`receiving_time`,`status`,`operator`,`create_time`) values
    (1,1,'REC1776128418603',1,NULL,'2026-04-14 09:00:19',2,NULL,'2026-04-14 09:00:18');

/*Table structure for table `receiving_detail` */

DROP TABLE IF EXISTS `receiving_detail`;

CREATE TABLE `receiving_detail` (
                                    `id` bigint NOT NULL AUTO_INCREMENT,
                                    `tenant_id` bigint NOT NULL,
                                    `receiving_id` bigint NOT NULL,
                                    `sku_code` varchar(50) NOT NULL,
                                    `sku_name` varchar(200) DEFAULT NULL,
                                    `quantity` int NOT NULL COMMENT '收货数量',
                                    `qualified_quantity` int DEFAULT '0' COMMENT '合格数量',
                                    `defective_quantity` int DEFAULT '0' COMMENT '不良数量',
                                    `batch_no` varchar(50) DEFAULT NULL COMMENT '批次号',
                                    `production_date` datetime DEFAULT NULL COMMENT '生产日期',
                                    `expiry_date` datetime DEFAULT NULL COMMENT '有效期',
                                    PRIMARY KEY (`id`),
                                    KEY `idx_receiving_id` (`receiving_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `receiving_detail` */

insert  into `receiving_detail`(`id`,`tenant_id`,`receiving_id`,`sku_code`,`sku_name`,`quantity`,`qualified_quantity`,`defective_quantity`,`batch_no`,`production_date`,`expiry_date`) values
    (1,1,1,'sku001','酒精',2,2,0,'BATCH1776128418561','2026-04-14 00:00:00','2027-01-01 00:00:00');

/*Table structure for table `replenishment_order` */

DROP TABLE IF EXISTS `replenishment_order`;

CREATE TABLE `replenishment_order` (
                                       `id` bigint NOT NULL AUTO_INCREMENT,
                                       `tenant_id` bigint NOT NULL,
                                       `order_no` varchar(32) NOT NULL COMMENT '建议单号',
                                       `sku_code` varchar(50) NOT NULL,
                                       `sku_name` varchar(200) DEFAULT NULL,
                                       `current_stock` int NOT NULL COMMENT '当前库存',
                                       `suggest_quantity` int NOT NULL COMMENT '建议补货数量',
                                       `reason` varchar(200) DEFAULT NULL COMMENT '补货原因',
                                       `status` tinyint DEFAULT '0' COMMENT '0-待审核 1-已审核 2-已驳回 3-已生成采购单',
                                       `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
                                       `audit_time` datetime DEFAULT NULL,
                                       `auditor` varchar(50) DEFAULT NULL,
                                       `audit_comment` varchar(500) DEFAULT NULL COMMENT '审核意见',
                                       `process_instance_id` varchar(64) DEFAULT NULL COMMENT '工作流实例ID',
                                       PRIMARY KEY (`id`),
                                       KEY `idx_status` (`status`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `replenishment_order` */

insert  into `replenishment_order`(`id`,`tenant_id`,`order_no`,`sku_code`,`sku_name`,`current_stock`,`suggest_quantity`,`reason`,`status`,`create_time`,`audit_time`,`auditor`,`audit_comment`,`process_instance_id`) values
                                                                                                                                                                                                                          (1,1,'REP17773584706180','sku001','酒精',0,20,'智能补货Agent扫描发现库存低于安全阈值（10件）',1,'2026-04-28 14:41:10','2026-04-28 14:52:39','user_1',NULL,NULL),
                                                                                                                                                                                                                          (2,1,'REP1777359023142','sku001','酒精',0,20,'低于安全库存阈值（10件）',1,'2026-04-28 14:50:23','2026-04-29 15:01:55','user_1',NULL,NULL),
                                                                                                                                                                                                                          (3,1,'REP17774461458150','sku001','酒精',0,20,'智能补货Agent扫描发现库存低于安全阈值（10件）',0,'2026-04-29 15:02:25',NULL,NULL,NULL,'6343a2a8-4399-11f1-a600-c894025bbc03');

/*Table structure for table `tenant` */

DROP TABLE IF EXISTS `tenant`;

CREATE TABLE `tenant` (
                          `id` bigint NOT NULL AUTO_INCREMENT,
                          `tenant_code` varchar(32) NOT NULL COMMENT '租户编码',
                          `tenant_name` varchar(100) NOT NULL,
                          `status` tinyint DEFAULT '1' COMMENT '1启用 0禁用',
                          `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
                          PRIMARY KEY (`id`),
                          UNIQUE KEY `uk_tenant_code` (`tenant_code`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `tenant` */

insert  into `tenant`(`id`,`tenant_code`,`tenant_name`,`status`,`create_time`) values
                                                                                   (1,'tenantA','深圳仓',1,'2026-04-13 11:22:36'),
                                                                                   (2,'tenantB','广州仓',1,'2026-04-13 11:22:36');

/*Table structure for table `user` */

DROP TABLE IF EXISTS `user`;

CREATE TABLE `user` (
                        `id` bigint NOT NULL AUTO_INCREMENT,
                        `tenant_id` bigint NOT NULL COMMENT '租户ID',
                        `username` varchar(50) NOT NULL,
                        `password` varchar(100) NOT NULL,
                        `real_name` varchar(50) DEFAULT NULL,
                        `role` varchar(20) DEFAULT 'USER',
                        `status` tinyint DEFAULT '1',
                        PRIMARY KEY (`id`),
                        KEY `idx_tenant_username` (`tenant_id`,`username`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `user` */

insert  into `user`(`id`,`tenant_id`,`username`,`password`,`real_name`,`role`,`status`) values
                                                                                            (1,1,'admin','$2a$10$R0ohb5wBgdc6vc4SEWab/.nd3s.IjjRyztqKe1baebvKinxmK8McS','管理员A','ADMIN',1),
                                                                                            (2,2,'admin','$2a$10$R0ohb5wBgdc6vc4SEWab/.nd3s.IjjRyztqKe1baebvKinxmK8McS','管理员B','ADMIN',1);

/*Table structure for table `wave` */

DROP TABLE IF EXISTS `wave`;

CREATE TABLE `wave` (
                        `id` bigint NOT NULL AUTO_INCREMENT,
                        `tenant_id` bigint NOT NULL,
                        `wave_no` varchar(32) NOT NULL COMMENT '波次号',
                        `wave_type` tinyint DEFAULT '0' COMMENT '0-按时间 1-按区域 2-按承运商',
                        `status` tinyint DEFAULT '0' COMMENT '0-待拣货 1-拣货中 2-已完成',
                        `order_count` int DEFAULT '0',
                        `total_quantity` int DEFAULT '0',
                        `create_time` datetime DEFAULT CURRENT_TIMESTAMP,
                        PRIMARY KEY (`id`),
                        UNIQUE KEY `uk_wave_no` (`wave_no`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

/*Data for the table `wave` */

insert  into `wave`(`id`,`tenant_id`,`wave_no`,`wave_type`,`status`,`order_count`,`total_quantity`,`create_time`) values
    (2,1,'WAVE1776134407787',0,2,1,1,'2026-04-14 10:41:13');

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
