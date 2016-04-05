-- script: Install/Schema/Last/run.sql
-- Выполняет установку последней версии объектов схемы.


-- Определяем табличное пространство для индексов
@oms-set-indexTablespace.sql


-- Таблицы

@oms-run sch_batch.tab
@oms-run sch_batch_content.tab
@oms-run sch_batch_role.tab
@oms-run sch_batch_type.tab
@oms-run sch_condition.tab
@oms-run sch_interval.tab
@oms-run sch_interval_type.tab
@oms-run sch_job.tab
@oms-run sch_load_condition_tmp.tab
@oms-run sch_load_interval_tmp.tab
@oms-run sch_load_schedule_tmp.tab
@oms-run sch_module_role_privilege.tab
@oms-run sch_privilege.tab
@oms-run sch_result.tab
@oms-run sch_schedule.tab


-- Outline-ограничения целостности

@oms-run sch_batch.con
@oms-run sch_batch_content.con
@oms-run sch_batch_role.con
@oms-run sch_batch_type.con
@oms-run sch_condition.con
@oms-run sch_interval.con
@oms-run sch_interval_type.con
@oms-run sch_job.con
@oms-run sch_module_role_privilege.con
@oms-run sch_privilege.con
@oms-run sch_result.con
@oms-run sch_schedule.con


-- Последовательности

@oms-run sch_batch_content_seq.sqs
@oms-run sch_batch_role_seq.sqs
@oms-run sch_batch_seq.sqs
@oms-run sch_batch_type_seq.sqs
@oms-run sch_condition_seq.sqs
@oms-run sch_interval_seq.sqs
@oms-run sch_job_seq.sqs
@oms-run sch_module_role_privilege_seq.sqs
@oms-run sch_result_seq.sqs
@oms-run sch_schedule_seq.sqs



-- Синоним и индекс

@oms-run sch_log.sql
