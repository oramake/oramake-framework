--script: OmsInternal/set-environment.sql
--Выполняет наcтройку среды выполнения в SQL*Plus.
--Выполняется автоматически при загрузке файла через <oms-load> с помощью
--SQL*Plus ( после подключения к БД до выполнения загружаемого файла).
--
--Замечания:
--  - внутренний скрипт, используется внутри OMS;
--  - для уменьшения вероятности переноса строк и улучшения читабельности вывода
--    рекомендуется устанавливать ширину буфера консоли, в которой запускается
--    make, не менее максимальной длины строки в SQL*Plus ( текущая настройка
--    4000 символов);
--

--Отключаем автоматический commit после каждого выполнения SQL или PL/SQL.
set autocommit off

--Отключаем автоматический вывод значений bind-переменных.
set autoprint off

--Устанавливаем разделитель колонок при выводе.
set colsep " "

--Включает подстановку переменных в команды ( символ подстановки '&').
--Подстановка отключается в oms-load для определенных типов файлов
--( в связи с возможными ошибками при загрузке исходников с Java).
set define on

--Отключаем показ команд перед выполнением.
set echo off

--Включаем показ заголовка ( названия колонок) при выборке.
set heading on

--Максимальное число байт для показа CLOB, LONG, BLOB, XMLType.
set long 10000

--Устанавливаем максимальную длину строки чтобы избежать переноса.
set linesize 4000

--Число байт для выборки из LOB в одной итерации.
set longchunksize 10000

--Устанавливаем максимальное число строк в странице ( чтобы избежать разбиения).
set pagesize 9999

--Включаем показ вывода, выполняемого через dbms_output с максимальным размером.
set serveroutput on size 1000000

--Использовать пробелы вместо табуляции при форматировании вывода.
set tab off

--Удаление пробелов в конце строки.
set trimspool on

--Не показывать текст SQL до и после подстановки значений переменных.
set verify off



--Временно отключаем вывод перед выполнением PL/SQL.
set termout off
set feedback off

--Разрешаем вывод на консоль из Java.
begin
  execute immediate 'begin dbms_java.set_output( 1000000); end;';
exception when others then
  null;
end;
/

--Восстанавливаем вывод
set termout on

--Включаем показ числа выбранных записей.
set feedback on
