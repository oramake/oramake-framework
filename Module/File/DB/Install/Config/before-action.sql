--script: Install/Config/before-action.sql
--Действия выполняемые перед установкой обновления модуля.
--


@@stop-batches.sql "v_fl_save_job_queue"
