-- script: Install/Grant/Last/Local/Private/Main/v_op_operator_role.sql
-- ������ �������������� ���� ������������, � ����� �������� ���������������

--
-- toUserName                 - ��� ������������, �������� �������� �����
--


define toUserName = "&1"



grant select on v_op_operator_role to ocrm
/

create or replace synonym ocrm.v_op_operator_role for v_op_operator_role
/



undefine toUserName
