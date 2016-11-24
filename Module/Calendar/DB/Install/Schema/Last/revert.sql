-- script: Install/Schema/Last/revert.sql
-- Отменяет установку модуля, удаляя созданные объекты схемы.


-- Пакеты

drop package pkg_CalendarEdit
/


-- Представления

drop view v_cdr_day
/
drop view v_cdr_day_type
/


-- Внешние ключи

@oms-drop-foreign-key cdr_day
@oms-drop-foreign-key cdr_day_type


-- Таблицы

drop table cdr_day
/
drop table cdr_day_type
/
