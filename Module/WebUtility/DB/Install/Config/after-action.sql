-- script: Install/Config/after-action.sql
-- В случае STOP_JOB=1 восстанавливает ранее отключенный запуск заданий в БД
-- с помощью скрипта <Install/Config/resume-batches.sql>.
--
-- Замечание:
--  - при первоначальной установке ( INSTALL_VERSION=Last) скрипт не
--    выполняется;
--

define runScript = ""
@oms-default runScript "' || case when '&STOP_JOB' = '1' then 'resume-batches.sql' end || '"

@oms-run "&runScript" "v_wbu_save_job_queue"
