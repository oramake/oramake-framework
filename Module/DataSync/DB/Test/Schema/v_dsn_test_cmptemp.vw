-- view: v_dsn_test_cmptemp
create or replace view
  v_dsn_test_cmptemp
as
select
  t.*
from
  dsn_test_source t
/


comment on table v_dsn_test_cmptemp is
  '�������� �������� ������ ( ����� ��������� ������ � �������������� ��������� �������) ( �������� ������) [ SVN root: Oracle/Module/DataSync]'
/
