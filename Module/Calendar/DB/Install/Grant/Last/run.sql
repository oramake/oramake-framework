-- script: Install/Grant/Last/run.sql
-- ������ ����������� ����� �� ������������� ������.
--
-- ���������:
-- toUserName                  - ��� ������������, �������� �������� �����
--
-- ���������:
--  - ������ ����������� ��� �������������, �������� ����������� ������� ������
--   ;
--

define toUserName = "&1"



-- ��������� ��� �������������, ����� ������������ ������������� v_cdr_day
grant select on cdr_day to &toUserName
/
create or replace synonym &toUserName..cdr_day for cdr_day
/



@oms-run Install/Grant/Last/Common/run.sql



undefine toUserName
