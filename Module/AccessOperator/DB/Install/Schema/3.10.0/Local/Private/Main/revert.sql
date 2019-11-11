-- script: Install/Schema/3.10.0/Local/Private/Main/revert.sql
-- Удаление версии 3.10.0 объектов модуля


-- Удаление внешних ключей

@oms-drop-foreign-key.sql op_operator_waiting_emp_bind


-- Удаление полей


-- Удаление таблиц

drop table
  op_operator_waiting_emp_bind
cascade constraint
/


-- Удаление последовательностей

drop sequence op_oper_waiting_emp_bind_seq
/
