-- script: Install/Schema/4.1.0/run.sql
-- ��������� �������� ��� ������ 4.1.0



-- ��������� ������ � ���������� ������

@oms-run op_operator_group.sql
@oms-run op_operator_role.sql



-- �������� �������

@oms-run op_grant_group_del.sql


