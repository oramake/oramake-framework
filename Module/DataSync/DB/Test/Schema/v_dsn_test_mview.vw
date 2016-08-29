-- view: v_dsn_test_mview
create or replace view
  v_dsn_test_mview
as
select
  t.owner
  , t.table_name
  , t.row_uid
  , t.tablespace_name
  , t.status
  , t.num_rows
  , t.last_analyzed
from
  dsn_test_source t
/


comment on table v_dsn_test_mview is
  'Тестовый источник данных ( метод обновления с помощью материализованного представления) ( исходные данные) [ SVN root: Oracle/Module/DataSync]'
/
