-- script: Install/Schema/Last/revert.sql
-- Отменяет установку модуля, удаляя созданные объекты схемы.


-- Пакеты

drop package pkg_AccessOperator
/
drop package pkg_Operator
/
drop package pkg_OperatorInternal
/


-- Представления

drop view v_op_operator
/
drop view v_op_operator_grant_group
/
drop view v_op_operator_grant_role
/
drop view v_op_operator_role
/
drop view v_op_password_hist
/
drop view v_op_role
/


-- Внешние ключи

@oms-drop-foreign-key op_grant_group
@oms-drop-foreign-key op_group
@oms-drop-foreign-key op_group_role
@oms-drop-foreign-key op_operator
@oms-drop-foreign-key op_operator_group
@oms-drop-foreign-key op_operator_role
@oms-drop-foreign-key op_password_hist
@oms-drop-foreign-key op_role


-- Таблицы

drop table op_grant_group
/
drop table op_group
/
drop table op_group_role
/
drop table op_operator
/
drop table op_operator_group
/
drop table op_operator_role
/
drop table op_password_hist
/
drop table op_role
/


-- Последовательности

drop sequence op_group_seq
/
drop sequence op_operator_seq
/
drop sequence op_password_hist_seq
/
drop sequence op_role_seq
/
