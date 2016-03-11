-- script: Install/Schema/Last/revert.sql
-- Отменяет установку модуля, удаляя созданные объекты схемы.


-- Пакеты

drop package pkg_Subversion
/


-- Java sources

drop java source "Subversion"
/


-- Внешние ключи

@oms-drop-foreign-key svn_file_tmp


-- Таблицы

drop table svn_file_tmp
/


-- Последовательности

drop sequence svn_file_tmp_seq
/
