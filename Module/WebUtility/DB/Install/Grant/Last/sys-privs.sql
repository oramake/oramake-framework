-- script: Install/Schema/Last/sys-privs.sql
-- ������ ��������� ����������, ����������� ��� ������ ������.
--
-- ���������:
-- userName                   - ��� ������������, � ����� ��������
--                              ����� ���������� ������
--
-- ���������:
-- - ��� ���������� ���� �� ����� dbms_crypto ��������� ������ ����� ����
--  ���������, �� ��� ������� ����������/������������ �������� ����������
--  ����� ��������� ������;
--



define userName = "&1"



grant execute on utl_http to &userName
/

grant execute on dbms_lob to &userName
/

grant execute on dbms_utility to &userName
/



create or replace synonym &userName..utl_http for utl_http
/

create or replace synonym &userName..dbms_lob for dbms_lob
/

create or replace synonym &userName..dbms_utility for dbms_utility
/

undefine userName
