-- script: Install/Grant/5.0.0/sys-privs.sql
-- ������ �������������� ��������� ���������� ��� ������ 5.0.0.
--
-- ���������:
-- userName                   - ��� ������������, � ����� ��������
--                              ����� ���������� ������
--

define userName = "&1"



grant create job to &userName
/



undefine userName
