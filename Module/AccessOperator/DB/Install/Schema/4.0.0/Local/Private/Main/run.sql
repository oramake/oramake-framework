-- script: Install/Schema/4.0.0/Local/Private/Main/run.sql
-- Установка уравненной версии объектов модуля

-- Удаление пакетов

@oms-run Do/drop-object.sql package pkg_AccessOperatorInternal
@oms-run Do/drop-object.sql package pkg_ReplicateOperator


-- Удаление представлений

@oms-run Do/drop-object.sql view v_op_operator_waiting_emp_bnd


-- Удаление таблиц

@oms-run Do/rename-table.sql op_operator_waiting_emp_bind eop_operator_waiting_emp_bind
@oms-run Do/rename-table.sql op_load_lock_form_sources_tmp rp_load_lock_form_sources_tmp


-- Триггеры

@oms-run Do/drop-object.sql trigger op_grant_group_aiud_add_event
@oms-run Do/drop-object.sql trigger op_group_aiud_add_event
@oms-run Do/drop-object.sql trigger op_group_role_aid_add_event
@oms-run Do/drop-object.sql trigger op_login_atm_grp_aiu_add_event
@oms-run Do/drop-object.sql trigger op_operator_aiud_add_event
@oms-run Do/drop-object.sql trigger op_operator_grp_aid_add_event
@oms-run Do/drop-object.sql trigger op_role_aiud_add_event


-- Последовательность

@oms-run Do/drop-object.sql sequence op_oper_waiting_emp_bind_seq
