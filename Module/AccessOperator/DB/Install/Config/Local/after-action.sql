-- script: Install/Config/after-action.sql
-- ƒействи€, выполн€емые после установки обновлени€ модул€.
--
-- ¬ыпол€немые действи€:
--  - в случае STOP_JOB=1 восстанавливает ранее отключенный запуск заданий
--    через dbms_job ( вызывает <Install/Config/resume-job.sql>);
--  - в противном случае повторно активирует пакетные задани€ всех модулей
--    ( с ожиданием запуска обработчиков);
--
-- «амечани€:
--  - при первоначальной установке модул€ ( INSTALL_VERSION=Last) скрипт не
--    выполн€етс€;
--

define runScript = ""
@oms-default runScript "' || case when '&STOP_JOB' = '1' then 'resume-job.sql' else 'resume-all-batch.sql' end || '"

@@&runScript "v_sch_save_job_queue"


@@compile_all_invalid.sql