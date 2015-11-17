--script: Install/Config/before-action.sql
--Действия выполняемые перед установкой обновления модуля.
--
--Выполянемые действия:
--  - отключает запуска заданий через dbms_job и ожидает остановки работающих
--    заданий ( вызыает <Install/Config/stop-batches.sql>);
--
--Замечания:
--  - при первоначальной установке модуля ( INSTALL_VERSION=Last) скрипт не
--    выполняется;
--

@@stop-batches.sql "v_th_save_job_queue"
