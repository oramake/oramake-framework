-- script: oms-gather-stats.sql
-- Собирает статистику по таблице или материализованному представлению
-- текущего пользователя.
--
-- Параметры:
-- tableName                  - имя таблицы ( материализованного представления)
--
-- Замечания:
--  - прикладной скрипт, предназначен для вызова из пользовательских скриптов;
--  - собирается полная статистика, включая статистику по полям и индексам;
--  - параметры сбора статистики аналогичны параметрам, используемым при
--    регулярном сборе статистики в БД ( в случае изменения последних в
--    скрипт должны вноситься изменения);
--

define tableName = "&1"



prompt &tableName: gather stats ...

timing start

begin
  dbms_stats.gather_table_stats(
    ownname         => user
    , tabname       => '&tableName'
    , method_opt    =>'FOR ALL INDEXED COLUMNS SIZE AUTO'
    , cascade       => true
  );
end;
/

timing stop



undefine tableName
