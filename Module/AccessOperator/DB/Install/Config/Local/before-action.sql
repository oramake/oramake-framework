-- script: Install/Config/before-action.sql
-- Действия, выполняемые перед установкой обновления модуля.
--
-- Выполянемые действия:
--  - в случае STOP_JOB=1 останавливает выполнение всех заданий БД;
--    ( вызывает <Install/Config/stop-job.sql>);
--  - в противном случае деактивирует пакетные задания всех модулей
--    ( с ожиданием остановки обработчиков);
--
-- Замечания:
--  - при первоначальной установке модуля ( INSTALL_VERSION=Last) скрипт не
--    выполняется;
--

define runScript = ""
@oms-default runScript "' || case when '&STOP_JOB' = '1' then 'stop-job.sql' else 'stop-all-batch.sql' end || '"

@@&runScript "v_sch_save_job_queue"
