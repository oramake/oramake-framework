-- script: Install/Grant/Last/link-user.sql
-- ������ ����� ��� ������������, ��� ������� �������� ���� ��
-- ���������������� ��.
--
-- ���������:
-- toUserName                 - ������������ ��� ������ ����
--

define toUserName = &1



@oms-run Install/Grant/Last/master-table.sql cdr_day
@oms-run Install/Grant/Last/master-table.sql cdr_day_type



undefine toUserName
