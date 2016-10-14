-- script: Install/Config/after-action.sql
-- ƒействи€, выполн€емые после установки обновлени€ модул€.
--
-- ¬ыпол€немые действи€:
--  - в случае STOP_JOB=1 восстанавливает ранее отключенный запуск заданий
--    через dbms_job ( вызывает <Install/Config/resume-batches.sql>);
--  - в противном случае повторно активирует пакетные задани€ модул€;
--
-- «амечани€:
--  - при первоначальной установке модул€ ( INSTALL_VERSION=Last) скрипт не
--    выполн€етс€;
--

define runScript = ""
@oms-default runScript "' || case when '&STOP_JOB' = '1' then 'resume-batches.sql' else 'reactivate-batch.sql' end || '"

@@&runScript "v_ml_save_job_queue"
