-- view: v_dsn_test_mview_ext
create or replace view
  v_dsn_test_mview_ext
as
select
  t.owner
  , t.table_name
  , t.row_uid
  , t.tablespace_name
  , t.status
  , t.num_rows
  , t.last_analyzed
  , t.clob_column
  , t.blob_column
from
  dsn_test_source t
/


comment on table v_dsn_test_mview_ext is
  'Тестовый источник данных ( метод обновления с помощью материализованного представления, с дополнительными колонками) ( исходные данные) [ SVN root: Oracle/Module/DataSync]'
/
