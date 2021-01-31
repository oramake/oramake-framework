-- script: Install/Schema/3.5.0/run.sql
-- Установка объектов версии 3.5.0 модуля

@oms-set-indexTablespace.sql

-- Создание таблиц
@oms-run Install/Schema/Last/op_lock_type.tab
@oms-run Install/Schema/Last/op_login_attempt_group.tab


-- Запуск скритов
@oms-run Install/Data/1.0.0/op_lock_type.sql
@oms-run Install/Data/3.5.0/Local/Private/Main/op_login_attempt_group.sql
@oms-run op_operator.sql

-- Внешние ограничения целостности
@oms-run Install/Schema/Last/op_lock_type.con
@oms-run Install/Schema/Last/op_login_attempt_group.con
@oms-run op_operator.con

-- Создание представлений
@oms-run Install/Schema/Last/v_op_operator.vw
@oms-run Install/Schema/Last/v_op_login_attempt_group.vw
@oms-run Install/Schema/Last/v_op_operator_to_lock.vw

-- Создание пакетов
@oms-run ./pkg_Operator.pks
@oms-run ./pkg_Operator.pkb
