-- script: Install/Schema/Last/revert.sql
-- Отменяет установку модуля, удаляя созданные объекты схемы.
--


--Пакеты
drop package pkg_TaskHandler
/



--Представления
drop view v_th_command_pipe
/
drop view v_th_session
/
