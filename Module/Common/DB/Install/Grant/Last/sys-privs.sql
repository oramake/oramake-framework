-- ������ ����� �� �������� ��������� ���������, ��������� �����, �������� � ������� � �����

define userName = &1

grant create public synonym to &userName
/
grant create type to &userName
/
grant create procedure to &userName
/
grant select on sys.v_$mystat to &userName
/

undefine userName