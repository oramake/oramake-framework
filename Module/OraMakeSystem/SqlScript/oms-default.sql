--script: oms-default.sql
--Устанавливает значение по умолчанию для макропеременной SQL*Plus.
--
--Параметры:
--varName                     - имя макропеременной
--defaultValue                - значение по умолчанию
--...                         - дополнительные параметры, которые можно
--                              использовать в defaultValue с помощью ссылок
--                              вида $(1),$(2),...,$(7)
--
--Замечания:
--  - прикладной скрипт, предназначен для вызова из пользовательских скриптов;
--  - если макропеременной уже присвоено непустое значение, то оно не
--    изменяется, что позволяет явно задать значение макропеременной при
--    установке с помощью параметра SQL_DEFINE ( см. <Установка модуля в БД>);
--  - установка значения макропеременной производится с помощью SQL-запроса из
--    таблицы dual, при этом предполагается, что значение defaultValue является
--    строкой и оно заключается в одинарные кавычки, поэтому для использования
--    SQL-выражения в defaultValue значение должно быть передано в виде
--    "' || <SQL-выражение> || '" ( см. примеры ниже);
--  - длина параметров в SQL*Plus ограничена 239 символами, в случае
--    необходимости для уменьшения длины параметра defaultValue можно
--    использованать ссылки на дополнительные параметры вида $(n), где n
--    порядковый номер дополнительного параметра от 1 до 7 ( см. примеры ниже);
--  - скрипт использует временный файл, который создается с использованием
--    префикса полного пути из макропеременной OMS_TEMP_FILE_PREFIX;
--
--
--
--Примеры:
--  - установка строкового значения
--
--(code)
--
--@oms-default.sql userName operation
--
--(end)
--
--  - установка значения с использованием SQL-выражения
--
--(code)
--
--@oms-default.sql userName "' || user || '"
--
--(end)
--
--  - установка значения с использованием дополнительных параметров
--
--(code)
--
--@oms-default.sql userName "' || $(1) || '" "user"
--
--(end)
--
--

define varName = "&1"
define defaultValue = "&2"

define oms_temp_file_name = "&OMS_TEMP_FILE_PREFIX..oms-default"



set termout off
spool &oms_temp_file_name
prompt select coalesce( '&&&varName', '&defaultValue') as "&varName" from dual
spool off
set termout on

get &oms_temp_file_name nolist

set termout off
change /$(1)/&3/
change /$(2)/&4/
change /$(3)/&5/
change /$(4)/&6/
change /$(5)/&7/
change /$(6)/&8/
change /$(7)/&9/
set termout on

set feedback off
column "&varName" new_value &varName head "&varName" format A60
/
column "&varName" clear
prompt
set feedback on



undefine oms_temp_file_name

undefine varName
undefine defaultValue
