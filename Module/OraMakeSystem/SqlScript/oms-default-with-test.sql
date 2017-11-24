-- script: oms-default-with-test.sql
-- Устанавливает значение по умолчанию для макропеременной SQL*Plus с учетом
-- типа БД ( промышленная или тестовая).
--
-- Параметры:
-- varName                    - имя макропеременной
-- prodDefaultValue           - значение по умолчанию для промышленной БД
-- testDefaultValue           - значение по умолчанию для тестовой БД
-- ...                        - дополнительные параметры, которые можно
--                              использовать в defaultValue с помощью ссылок
--                              вида $(3),$(4),...,$(7)
--
-- Замечания:
--  - прикладной скрипт, предназначен для вызова из пользовательских скриптов;
--  - тип БД ( промышленная или тестовая) определяется на основе результата
--    выполнения функции pkg_Common.IsProduction ( 1 промышленная, иначе
--    тестовая) модуля Common ( SVN root: Oracle/Module/Common);
--  - если макропеременной уже присвоено непустое значение, то оно не
--    изменяется, что позволяет явно задать значение макропеременной при
--    установке с помощью параметра SQL_DEFINE ( см. <Установка модуля в БД>);
--  - установка значения макропеременной производится с помощью SQL-запроса из
--    таблицы dual, при этом предполагается, что значение defaultValue является
--    строкой и оно заключается в одинарные кавычки, поэтому для использования
--    SQL-выражения в defaultValue значение должно быть передано в виде
--    "' || <SQL-выражение> || '" ( см. примеры ниже);
--  - следует учитывать, что длина параметров в SQL*Plus ограничена 239
--    символами ( актуально для параметров prodDefaultValue и testDefaultValue);
--  - для установки значения макропеременной используется скрипт
--    <oms-default.sql>;
--
--
--
-- Примеры:
--  - установка строкового значения
--
-- (code)
--
-- @oms-default-with-test.sql sourceDbLink Nic NicT
--
-- (end)
--
--  - установка значения с использованием SQL-выражения
--
-- (code)
--
-- @oms-default-with-test.sql sourceDbLink "' || case pkg_Common.GetInstanceName when 'ProdDb' then 'Prod' else 'Test' end || '" TestDbLink
--
-- (end)
--

-- Parameters are passed implicitly, because When called with "@@", an error
-- may occur with certain parameter values
define 4 = "&3"
define 3 = "&2"
define 2 = "' ||-
case pkg_Common.IsProduction when 1 then '$(1)' else '$(2)' end-
|| '"

@@oms-default.sql
