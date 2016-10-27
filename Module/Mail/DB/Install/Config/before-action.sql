-- script: Install/Config/before-action.sql
-- Действия, выполняемые перед установкой обновления модуля.
--
-- Выполянемые действия:
--  - в случае STOP_JOB=1 останавливает выполнение всех заданий БД;
--    ( вызывает <Install/Config/stop-job.sql>);
--  - в противном случае деактивирует пакетные задания модуля
--    ( с ожиданием остановки обработчиков);
--

define runScript = ""
@oms-default runScript "' || case when '&STOP_JOB' = '1' then 'stop-job.sql' else 'stop-batch.sql' end || '"

@@&runScript "v_ml_save_job_queue"
