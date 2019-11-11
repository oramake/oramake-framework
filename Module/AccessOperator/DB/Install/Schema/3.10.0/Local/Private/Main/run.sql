-- script: Install/Schema/3.10.0/Local/Private/Main/run.sql
-- Установка объектов версии 3.10.0 модуля


@oms-set-indexTablespace.sql



-- Запуск скриптов


-- Создание таблиц

@oms-run Install/Schema/Last/Local/Private/Main/op_operator_waiting_emp_bind.tab



-- Внешние ограничения целостности

@oms-run Install/Schema/Last/Local/Private/Main/op_operator_waiting_emp_bind.con


-- Последовательности

@oms-run Install/Schema/Last/Local/Private/Main/op_oper_waiting_emp_bind_seq.sqs


-- Представления

@oms-run Install/Schema/Last/Local/Private/Main/v_op_operator_waiting_emp_bnd.vw


-- Триггеры

@oms-run Install/Schema/Last/Local/Private/Main/op_oper_wait_emp_bind_bi_def.trg
@oms-run Install/Schema/Last/Local/Private/Main/op_group_aiud_add_event.trg
@oms-run Install/Schema/Last/Local/Private/Main/op_login_atm_grp_aiu_add_event.trg
@oms-run Install/Schema/Last/Local/Private/Main/op_operator_bi_define.trg
@oms-run Install/Schema/Last/Local/Private/Main/op_role_aiud_add_event.trg



