-- script: Install/Schema/Last/run.sql
-- Выполняет установку последней версии объектов схемы.


-- Определяем табличное пространство для индексов
@oms-set-indexTablespace.sql


-- Таблицы

@oms-run op_group.tab
@oms-run op_group_role.tab
@oms-run op_lock_type.tab
@oms-run op_login_attempt_group.tab
@oms-run op_operator.tab
@oms-run op_operator_group.tab
@oms-run op_operator_role.tab
@oms-run op_password_hist.tab
@oms-run op_role.tab


-- Outline-ограничения целостности

@oms-run op_group.con
@oms-run op_group_role.con
@oms-run op_lock_type.con
@oms-run op_login_attempt_group.con
@oms-run op_operator.con
@oms-run op_operator_group.con
@oms-run op_operator_role.con
@oms-run op_password_hist.con
@oms-run op_role.con
