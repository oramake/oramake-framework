-- script: Install/Config/before-action.sql
-- В случае STOP_JOB=1  останавливает выполнение заданий в БД с помощью
-- скрипта <Install/Config/stop-batches.sql>.
--
-- Замечание:
--  - при первоначальной установке ( INSTALL_VERSION=Last) скрипт не
--    выполняется;
--

define runScript = ""
@oms-default runScript "' || case when '&STOP_JOB' = '1' then 'stop-batches.sql' end || '"

@oms-run "&runScript" "v_wbu_save_job_queue"
