-- script: OmsInternal/set-environment.sql
-- Выполняет наcтройку среды выполнения в SQL*Plus.
-- Выполняется автоматически при загрузке файла через <oms-load> с помощью
-- SQL*Plus ( после подключения к БД до выполнения загружаемого файла).
--
-- Замечания:
--  - внутренний скрипт, используется внутри OMS;
--  - для уменьшения вероятности переноса строк и улучшения читабельности вывода
--    рекомендуется устанавливать ширину буфера консоли, в которой запускается
--    make, не менее максимальной длины строки в SQL*Plus ( текущая настройка
--    4000 символов);
--

-- Disable automatic commit after each SQL or PL / SQL execution
set autocommit off

-- Disable automatic output of values of bind variables
set autoprint off

-- Set the column separator in the output
set colsep " "

-- Enables the substitution of variables in commands ( the substitution symbol
-- '&').
-- The substitution is disabled in oms-load for certain file types
-- ( due to possible errors when loading sources from Java).
set define on

-- Disable showing commands before execution
set echo off

-- Enables the display of title (the name of the columns)
set heading on

-- Maximum number of bytes to display CLOB, LONG, BLOB, XMLType
set long 10000

-- Set the maximum length of line (to avoid splitting)
set linesize 4000

-- Number of bytes to retrieve from the LOB in one iteration
set longchunksize 10000

-- Set the maximum number of lines per page (to avoid splitting)
set pagesize 9999

-- We turn on display of the output executed through dbms_output with the
-- maximum size
set serveroutput on size 1000000

-- Use spaces instead of tabs when formatting output
set tab off

-- Removing spaces at the end of a line
set trimspool on

-- Do not show the text of SQL before and after substituting the values of
-- variables
set verify off



-- Temporarily disable output before executing PL / SQL
set termout off
set feedback off

-- Разрешаем вывод на консоль из Java.
begin
  execute immediate 'begin dbms_java.set_output( 1000000); end;';
exception when others then
  null;
end;
/

-- Enable output
set termout on

-- Enable showing the number of selected records
set feedback on
