-- view: v_dsn_test_app_dst_src
create or replace view
  v_dsn_test_app_dst_src
as
select
  t.app_source_id
  , t.owner
  , t.object_name
  , t.object_type
  , t.last_ddl_time
  , t.clob_column
  , t.blob_column
  , t.object_full_name
from
  dsn_test_app_source t
/


comment on table v_dsn_test_app_dst_src is
  'Тестовый источник данных для выгрузки в dsn_test_app_dst с помощью appendData [ SVN root: Oracle/Module/DataSync]'
/
