--script: Install/Grant/Last/sys-privs.sql
--������ ��������� ����������, ����������� ��� ��������� � ������ ������.
--
--���������:
--userName                    - ��� ������������, � ����� ��������
--                              ����� ���������� ������
define userName = "&1"

grant create any synonym to &username
/

undefine userName
