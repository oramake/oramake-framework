-- view: v_dsn_test_mview
create or replace view
  v_dsn_test_mview
as
select
  t.*
from
  dsn_test_source t
/


comment on table v_dsn_test_mview is
  '�������� �������� ������ ( ����� ���������� � ������� ������������������ �������������) ( �������� ������) [ SVN root: Oracle/Module/DataSync]'
/
