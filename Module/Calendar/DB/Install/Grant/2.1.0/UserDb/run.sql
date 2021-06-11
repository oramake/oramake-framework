-- script: Install/Grant/2.1.0/UserDb/run.sql
-- ��������� ����� �� ������������� ������ � ���������������� ��.
--
-- ���������:
-- toUserName                  - ��� ������������, �������� �������� �����
--
-- ���������:
--  - ������ ����������� ��� �������������, �������� ����������� ������� ������
--   ;
--

define toUserName = "&1"



grant execute on pkg_Calendar to &toUserName
/

-- �� ������� �������, �.�. ����� ������ ��-�� ������� ������ pkg_Calendar
-- � �������� �����
--create or replace synonym &toUserName..pkg_Calendar for pkg_Calendar
--/


grant select, merge view on v_cdr_day to &toUserName with grant option
/
create or replace synonym &toUserName..v_cdr_day for v_cdr_day
/


grant select, merge view on v_cdr_day_type to &toUserName with grant option
/
create or replace synonym &toUserName..v_cdr_day_type for v_cdr_day_type
/

grant select on mv_cdr_day to &toUserName with grant option
/

grant select on mv_cdr_day_type to &toUserName with grant option
/


undefine toUserName
