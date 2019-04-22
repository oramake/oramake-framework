-- script: Install/Schema/5.1.0/run.sql
-- Обновление объектов схемы до версии 5.1.0.
--
-- Основные изменения:
--  - удалены представления v_sch_batch_root_log, v_sch_batch_root_log_old,
--    v_sch_batch_result, sch_message_type;
--  - удален синоним sch_log и индексы sch_log_ix_root_batch_date_log,
--    sch_log_ix_root_date_ins;
--

@oms-run drop-old-object.sql
