--script: Install/Grant/Last/all-to-public.sql
--������ ����� �� ������������� ������ ���� �������������.
--����������� � ������� ������ ���� ������������ public � �������� ���������
--���������.
--
--���������:
--  - ��� ��������� ���������� ������� ��������� ����� �� ��������/��������
--    ��������� ���������;

grant execute on pkg_TextCreate to public
/
create or replace public synonym pkg_TextCreate for pkg_TextCreate
/
