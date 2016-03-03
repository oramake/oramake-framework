-- script: Install/Schema/Last/revert.sql
-- Отменяет установку модуля, удаляя созданные объекты схемы.


-- Пакеты

drop package pkg_Calendar
/


-- Внешние ключи

@oms-drop-foreign-key cdr_day
@oms-drop-foreign-key cdr_day_type


-- Таблицы

drop table cdr_day
/
drop table cdr_day_type
/


-- Последовательности

drop sequence cdr_day_type_seq
/
