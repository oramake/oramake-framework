-- script: Install/Schema/Last/revert.sql
-- Отменяет установку модуля, удаляя созданные объекты схемы.


-- Пакеты

drop package pkg_ConvertNameInCase
/


-- Представления

drop view v_ccs_case_exception
/


-- Внешние ключи

@oms-drop-foreign-key ccs_case_exception
@oms-drop-foreign-key ccs_type_exception


-- Таблицы

drop table ccs_case_exception
/
drop table ccs_type_exception
/


-- Последовательности

drop sequence ccs_case_exception_seq
/
