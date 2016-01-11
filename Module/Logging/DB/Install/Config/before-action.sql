--script: Install/Config/before-action.sql
--Действия выполняемые перед установкой обновления модуля.
--
--Выполянемые действия:
--  - деактивирует батчи модуля

@@stop-batches.sql "v_lg_save_job_queue"
