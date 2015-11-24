-- view: v_flh_cached_directory_wait
--
-- Представление для выборки не обновлённых директорий
create or replace view v_flh_cached_directory_wait as 
select
/* SVN root: Oracle/Module/FileHandler */
  d.cached_directory_id as cached_directory_id
  , d.path as path
  , 
  coalesce(
    d.priority_order
    , 
    (
    select
      cache_priority_order
    from
      flh_batch_config c
    where
      d.batch_short_name = c.batch_short_name
    ) 
  ) as priority_order       
  , d.batch_short_name
from
  flh_cached_directory d
where
  d.list_refresh_timeout is null
  or d.last_refresh < systimestamp - d.list_refresh_timeout  
/   
comment on table v_flh_cached_directory_wait is
'Представление для выборки не обновлённых директорий
[ SVN root: Oracle/Module/FileHandler] 
'
/
