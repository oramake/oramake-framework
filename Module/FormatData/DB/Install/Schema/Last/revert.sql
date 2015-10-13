--script: Install/Schema/Last/revert.sql
--Отменяет установку модуля, удаляя созданные объекты схемы.
--


                                        --Пакеты
drop package pkg_FormatData
/
drop package pkg_FormatBase
/


                                        --Представления
drop view v_fd_first_name_alias
/
drop view v_fd_middle_name_alias
/
drop view v_fd_no_value_alias
/


                                        --Таблицы
drop table fd_alias
/ 
drop table fd_alias_type
/
