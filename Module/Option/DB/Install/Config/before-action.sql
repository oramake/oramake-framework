--script: Install/Config/before-action.sql
--Действия выполняемые перед установкой обновления модуля.
--
--Выполняемые действия:
--  - останавливает запуск заданий

@@stop-batches.sql "v_opt_save_job_queue"
