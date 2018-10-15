-- script: Install/Schema/Last/revert.sql
-- Отменяет установку модуля, удаляя созданные объекты схемы.


-- Пакеты

drop package pkg_ModuleDependency
/

-- Таблицы

drop table md_module_dependency
/

drop table md_object_dependency
/

