-- view: v_flh_request_wait
-- Запросы, ожидающие обработки к модулю FileHandler
--
create or replace view v_flh_request_wait
as
/* SVN root: Oracle/Module/FileHandler */
select
  request_id as request_id
  , handler_sid as handler_sid
  , handler_serial# as handler_serial#
                                       -- Приоритет запроса
                                       -- переопределяет приоритет батча
  , coalesce(
      r.priority_order
      ,
      (
      select
        c.request_priority_order
      from
        flh_batch_config c
      where
        c.batch_short_name = r.batch_short_name
      )
    ) as priority_order
  , operation_code as operation_code
  , batch_short_name as batch_short_name
  , used_cached_directory_id as used_cached_directory_id
from
  (
  select /*+index(r flh_request_ix_wait)*/
    case request_state_code when 'WAIT' then
      request_id
    end as request_id
    ,
    case request_state_code when 'WAIT' then
      handler_sid
    end as handler_sid
    ,
    case request_state_code when 'WAIT' then
      handler_serial#
    end as handler_serial#
    ,
    case request_state_code when 'WAIT' then
      priority_order
    end as priority_order
    ,
    case request_state_code when 'WAIT' then
      operation_code
    end as operation_code
    ,
    case request_state_code when 'WAIT' then
      batch_short_name
    end as batch_short_name
    ,
    case request_state_code when 'WAIT' then
      used_cached_directory_id
    end as used_cached_directory_id
  from
    flh_request r
  ) r
where
  request_id is not null
/
comment on table v_flh_request_wait is
'Запросы, ожидающие обработки к модулю FileHandler
[ SVN root: Oracle/Module/FileHandler]
'
/
