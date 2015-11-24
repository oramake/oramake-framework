--script: Install/Config/before-action.sql
--Действия выполняемые перед установкой обновления модуля.
--

@@stop-batches.sql "v_flh_save_job_queue"
