-- view: v_dsn_test_compare
create or replace view
  v_dsn_test_compare
as
select
  t.*
from
  dsn_test_source t
/


comment on table v_dsn_test_compare is
  '�������� �������� ������ ( ����� ��������� ������) ( �������� ������) [ SVN root: Oracle/Module/DataSync]'
/
