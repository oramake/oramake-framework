-- script: Install/Grant/Last/UserDb/run.sql
-- ������ ����������� ����� �� ������������� ������ � ���������������� ��.
--
-- ���������:
-- toUserName                  - ��� ������������, �������� �������� �����
--
-- ���������:
--  - ������ ����������� ��� �������������, �������� ����������� ������� ������
--   ;
--

define toUserName = "&1"



@oms-run Install/Grant/Last/Common/run.sql



undefine toUserName
