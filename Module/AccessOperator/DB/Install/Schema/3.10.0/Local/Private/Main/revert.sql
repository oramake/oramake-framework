-- script: Install/Schema/3.10.0/Local/Private/Main/revert.sql
-- �������� ������ 3.10.0 �������� ������


-- �������� ������� ������

@oms-drop-foreign-key.sql op_operator_waiting_emp_bind


-- �������� �����


-- �������� ������

drop table
  op_operator_waiting_emp_bind
cascade constraint
/


-- �������� �������������������

drop sequence op_oper_waiting_emp_bind_seq
/
