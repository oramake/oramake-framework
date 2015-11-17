--view: v_th_session
--Сессии обработки задач.
create or replace force view v_th_session
as
select
  -- SVN root: Oracle/Module/TaskHandler
  ss.sid as sid
  , ss.serial# as serial#
  , ss.module_name as module_name
  , ss.process_name || ss.process_params_0
    as process_full_name
  , ss.action as action
  , ss.action_time_start as action_time_start
  , ss.action_limit_second as action_limit_second
  , ss.action_info as action_info
  , ss.process_name as process_name
  , ss.process_params as process_params
  , ss.saddr as saddr
  , ss.audsid as audsid
  , ss.paddr as paddr
  , ss.user# as user#
  , ss.username as username
  , ss.command as command
  , ss.ownerid as ownerid
  , ss.taddr as taddr
  , ss.lockwait as lockwait
  , ss.status as status
  , ss.server as server
  , ss.schema# as schema#
  , ss.schemaname as schemaname
  , ss.osuser as osuser
  , ss.process as process
  , ss.machine as machine
  , ss.terminal as terminal
  , ss.program as program
  , ss.type as type
  , ss.sql_address as sql_address
  , ss.sql_hash_value as sql_hash_value
  , ss.prev_sql_addr as prev_sql_addr
  , ss.prev_hash_value as prev_hash_value
  , ss.module as module
  , ss.module_hash as module_hash
  , ss.action_hash as action_hash
  , ss.client_info as client_info
  , ss.fixed_table_sequence as fixed_table_sequence
  , ss.row_wait_obj# as row_wait_obj#
  , ss.row_wait_file# as row_wait_file#
  , ss.row_wait_block# as row_wait_block#
  , ss.row_wait_row# as row_wait_row#
  , ss.logon_time as logon_time
  , ss.last_call_et as last_call_et
  , ss.pdml_enabled as pdml_enabled
  , ss.failover_type as failover_type
  , ss.failover_method as failover_method
  , ss.failed_over as failed_over
  , ss.resource_consumer_group as resource_consumer_group
  , ss.pdml_status as pdml_status
  , ss.pddl_status as pddl_status
  , ss.pq_status as pq_status
  , ss.current_queue_duration as current_queue_duration
  , ss.client_identifier as client_identifier
from
  (
  select
    ss.*
    , substr(
        ':' || ss.module_process_name
        , 2
        , instr( ':' || ss.module_process_name, ':', -1) - 2
      )
      as module_name
    , substr(
        ss.module_process_name
        , instr( ss.module_process_name, ':') + 1
      )
      as process_name
    , case
        when ss.process_params_0 like '(%)' then
          substr( ss.process_params_0, 2, length( ss.process_params_0) - 2)
        when ss.process_params_0 like '(%' then
          substr( ss.process_params_0, 2)
        else
          ss.process_params_0
      end
      as process_params
    , substr(
        ss.client_info
        , 1
        , length( ss.client_info) - length( ss.action_time) - 1
      )
      as action_info
    , to_timestamp_tz( 
        substr(
          ss.action_time
          , 1
          , instr( ss.action_time || ';', ';') - 1
        )
        , 'yy-mm-dd hh24:mi:ss.ff TZH:TZM'
      )
      as action_time_start
    , to_number(
        substr(
          ss.action_time
          , instr( ss.action_time || ';', ';') + 1
        )
      ) / 100
      as action_limit_second
  from
    (
    select
      ss.*
      , substr( ss.module, 6, instr( ss.module || '(', '(') - 6) 
        as module_process_name
      , substr( ss.module, instr( ss.module || '(', '(')) 
        as process_params_0
      , substr(
          ss.client_info
          , instr( ss.client_info, ',', -1) + 1
        )
        as action_time
    from
      v$session ss
    where
      ss.module like 'TASK:%:%'
    ) ss
  ) ss
/



comment on table v_th_session is
  'Сессии обработки задач [ SVN root: Oracle/Module/TaskHandler].'
/
comment on column v_th_session.module_name is
  'Имя модуля, к которому относится выполняемый процесс.'
/
comment on column v_th_session.process_full_name is
  'Имя выполняемого процесса с параметрами'
/
comment on column v_th_session.action is
  'Имя выполняемого действия'
/
comment on column v_th_session.action_time_start is
  'Время начала выполнения действия'
/
comment on column v_th_session.action_limit_second is
  'Лимит времени на выполнение действия ( в секундах).'
/
comment on column v_th_session.action_info is
  'Дополнительная информация по выполняемому действию'
/
comment on column v_th_session.process_name is
  'Имя выполняемого процесса'
/
comment on column v_th_session.process_params is
  'Параметры выполняемого процесса'
/
