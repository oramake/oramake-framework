-- script: Install/Config/after-action.sql
-- В случае наличия в БД модуля Scheduler восстанавливает ранее отключенный
-- запуск заданий в БД с помощью скрипта <Install/Config/resume-batches.sql>.
--
-- Замечание:
--  - наличие модуля Scheduler проверяется по возможности выборки из
--    v_sch_batch значения колонки batch_short_name;
--  - при первоначальной установке ( INSTALL_VERSION=Last) скрипт не
--    выполняется;
--

define runScript = ""
@oms-default runScript "' || ( select 'resume-batches.sql' from all_tab_columns where table_name='V_SCH_BATCH' and column_name = 'BATCH_SHORT_NAME') || '"

@oms-run "&runScript" "v_mod_save_job_queue"
