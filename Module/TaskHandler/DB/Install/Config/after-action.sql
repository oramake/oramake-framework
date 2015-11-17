--script: Install/Config/after-action.sql
--ƒействи€, выполн€емые после установки обновлени€ модул€.
--
--¬ыпол€немые действи€:
--  - восстанавливает ранее отключенный запуск заданий через dbms_job
--    ( вызывает <Install/Config/resume-batches.sql>);
--
--«амечани€:
--  - при первоначальной установке модул€ ( INSTALL_VERSION=Last) скрипт не
--    выполн€етс€;
--

@@resume-batches.sql "v_th_save_job_queue"
