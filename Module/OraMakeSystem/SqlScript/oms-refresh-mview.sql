--script: oms-refresh-mview.sql
--Обновляет материализованное представление и собирает по нему статистику.
--
--Параметры:
--mviewName                   - имя материализованного представления
--
--Замечания:
--  - прикладной скрипт, предназначен для вызова из пользовательских скриптов;
--  - статистика собирается с помощью скрипта <oms-gather-stats.sql>, который
--    вызывается с помощью <oms-run.sql>, т.о. сбор статистики не будет
--    выполняться в случае указания в <SKIP_FILE_MASK> маски
--    "*/oms-gather-stats.sql";
--

define mviewName = "&1"



prompt &mviewName: refresh ...

timing start

exec dbms_mview.refresh( '&mviewName', '?')

timing stop

@oms-run.sql ./oms-gather-stats.sql "&mviewName"



undefine mviewName
