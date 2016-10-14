-- script: Install/Config/before-action.sql
-- Действия, выполняемые перед установкой обновления модуля.
--
-- Выполянемые действия:
--  - в случае STOP_JOB=1 останавливает выполнение всех заданий БД;
--    ( вызывает <Install/Config/stop-batches.sql>);
--  - в противном случае деактивирует пакетные задания модуля;
--

define runScript = ""
@oms-default runScript "' || case when '&STOP_JOB' = '1' then 'stop-batches.sql' else 'deactivate-batch.sql' end || '"

@@&runScript "v_ml_save_job_queue"
