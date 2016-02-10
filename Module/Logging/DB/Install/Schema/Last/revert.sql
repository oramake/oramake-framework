-- script: Install/Schema/Last/revert.sql
-- Отменяет установку модуля, удаляя созданные объекты схемы.


-- Удаление общих объектов схемы
@oms-run Install/Schema/Last/Common/revert.sql


-- Пакеты

drop package pkg_Logging
/
drop package pkg_LoggingErrorStack
/
drop package pkg_LoggingInternal
/


-- Типы

@oms-drop-type lg_logger_t


-- Внешние ключи

@oms-drop-foreign-key lg_destination
@oms-drop-foreign-key lg_level
@oms-drop-foreign-key lg_log
@oms-drop-foreign-key lg_message_type


-- Таблицы

drop table lg_destination
/
drop table lg_level
/
drop table lg_log
/
drop table lg_message_type
/


-- Последовательности

drop sequence lg_log_seq
/
