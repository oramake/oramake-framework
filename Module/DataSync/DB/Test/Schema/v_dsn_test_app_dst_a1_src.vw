-- view: v_dsn_test_app_dst_a1_src
create or replace view
  v_dsn_test_app_dst_a1_src
as
select
  t.app_source_id
  , a.order_number
  , t.owner
  , t.object_name
  , t.last_ddl_time
from
  dsn_test_app_source t
  cross join
    (
    select 1 as order_number from dual
    union all select 2 from dual
    ) a
/


comment on table v_dsn_test_app_dst_a1_src is
  'Тестовый источник данных для выгрузки в dsn_test_app_dst_a1 с помощью appendData [ SVN root: Oracle/Module/DataSync]'
/
