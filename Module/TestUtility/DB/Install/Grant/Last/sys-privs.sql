--script: Install/Schema/Last/sys-privs.sql
--������ ��������� ����������, ����������� ��� ��������� � ������ ������.
--
--���������:
--userName                    - ��� ������������, � ����� ��������
--                              ����� ���������� ������
define userName = "&1"



grant create job to &userName
/

grant manage scheduler to &userName
/


undefine userName
