-- script: Install/Grant/5.2.1/sys-privs.sql
-- ������ �������������� ��������� ���������� ��� ������ 5.2.1.
--
-- ���������:
-- userName                   - ��� ������������, � ����� ��������
--                              ����� ���������� ������
--

define userName = "&1"



grant manage scheduler to &userName
/



undefine userName
