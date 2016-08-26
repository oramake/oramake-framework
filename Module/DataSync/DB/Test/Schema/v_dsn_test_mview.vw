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
  'Тестовый источник данных ( метод обновления с помощью материализованного представления) ( исходные данные) [ SVN root: Oracle/Module/DataSync]'
/
