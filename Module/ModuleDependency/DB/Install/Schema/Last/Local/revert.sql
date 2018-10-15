-- script: Install/Schema/Last/revert.sql
-- Отменяет установку модуля, удаляя созданные объекты схемы.


-- Пакеты

drop package pkg_ModuleDependencySource
/

-- Таблицы

drop table md_object_dependency_tmp
/

