-- script: Install/Schema/Last/revert.sql
-- �������� ��������� ������, ������ ��������� ������� �����.


-- ������

drop package pkg_AccessOperator
/
drop package pkg_Operator
/


-- �������������

drop view v_op_operator
/
drop view v_op_operator_role
/
drop view v_op_role
/


-- ������� �����

@oms-drop-foreign-key op_group
@oms-drop-foreign-key op_group_role
@oms-drop-foreign-key op_operator
@oms-drop-foreign-key op_operator_group
@oms-drop-foreign-key op_operator_role
@oms-drop-foreign-key op_role


-- �������

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
drop table op_role
/


-- ������������������

drop sequence op_group_seq
/
drop sequence op_operator_seq
/
drop sequence op_role_seq
/
