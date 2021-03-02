-- script: Install/Schema/Last/revert.sql
-- Отменяет установку модуля, удаляя созданные объекты схемы.


-- Пакеты

drop package pkg_WebUtility
/
drop package pkg_WebUtilityBase
/
drop package pkg_WebUtilityNtlm
/


-- Типы

@oms-drop-type wbu_header_list_t
@oms-drop-type wbu_header_t
@oms-drop-type wbu_parameter_list_t
@oms-drop-type wbu_parameter_t
@oms-drop-type wbu_part_list_t
@oms-drop-type wbu_part_t
