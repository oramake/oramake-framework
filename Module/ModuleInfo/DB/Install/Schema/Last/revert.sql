-- script: Install/Schema/Last/revert.sql
-- Отменяет установку модуля, удаляя созданные объекты схемы.
--


-- Пакеты
drop package pkg_ModuleInfo 
/
drop package pkg_ModuleInfoInternal 
/
drop package pkg_ModuleInstall 
/


-- Представления
drop view v_mod_app_install_result
/
drop view v_mod_app_install_version
/
drop view v_mod_install_action
/
drop view v_mod_install_file
/
drop view v_mod_install_module
/
drop view v_mod_install_object
/
drop view v_mod_install_result
/
drop view v_mod_install_version
/
drop view v_mod_module
/
drop view v_mod_source_file
/



-- Таблицы
drop table mod_app_install_result
/
drop table mod_deployment
/
drop table mod_install_result
/
drop table mod_install_file
/
drop table mod_install_action
/
drop table mod_install_type
/
drop table mod_source_file
/
drop table mod_module_part
/
drop table mod_module
/


-- Последовательности
drop sequence mod_app_install_result_seq
/
drop sequence mod_deployment_seq
/
drop sequence mod_install_action_seq
/
drop sequence mod_install_file_seq
/
drop sequence mod_install_result_seq
/
drop sequence mod_module_part_seq
/
drop sequence mod_module_seq
/
drop sequence mod_source_file_seq
/
