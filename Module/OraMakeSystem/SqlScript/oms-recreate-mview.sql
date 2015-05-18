--script: oms-recreate-mview.sql
--Пересоздает материализованное представление и собирает по нему статистику.
--
--Параметры:
--oms_recrmv_mviewName                   - имя материализованного представления
--oms_recrmv_mviewScript                 - скрипт создания материализованного представления
--
--Замечания:
--  - прикладной скрипт, предназначен для вызова из пользовательских скриптов;
--  - удаление матпредставления осуществляется с помощью скрипта 
--    <oms-drop-mview.sql>, который вызывается с помощью <oms-run.sql>, 
--    т.о. удаление не будет выполняться в случае указания в <SKIP_FILE_MASK> 
--    маски "*/oms-drop-mview.sql";
--  - статистика собирается с помощью скрипта <oms-gather-stats.sql>, который
--    вызывается с помощью <oms-run.sql>, т.о. сбор статистики не будет
--    выполняться в случае указания в <SKIP_FILE_MASK> маски
--    "*/oms-gather-stats.sql";
--

define oms_recrmv_mviewName = "&1"
define oms_recrmv_mviewScript = "&2"

@oms-run.sql ./oms-drop-mview.sql "&oms_recrmv_mviewName"

@oms-run.sql "&oms_recrmv_mviewScript"

prompt &oms_recrmv_mviewName: refresh ...

timing start

exec dbms_mview.refresh( '&oms_recrmv_mviewName', '?', atomic_refresh=>false)

timing stop

@oms-run.sql ./oms-gather-stats.sql "&oms_recrmv_mviewName"

undefine oms_recrmv_mviewName
undefine oms_recrmv_mviewScript
