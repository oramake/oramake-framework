--view: v_th_command_pipe
--Командные пайпы обработчиков заданий.
create or replace force view v_th_command_pipe
as
select
  -- SVN root: Oracle/Module/TaskHandler
  to_number( substr( pp.session_id, 1, instr( pp.session_id, '_') - 1))
    as sid
  , to_number( substr( pp.session_id, instr( pp.session_id, '_') + 1))
    as serial#
  , pp.ownerid
  , pp.name
  , pp.type
  , pp.pipe_size
from
  (
  select
    pp.*
    , substr( pp.name, instr( pp.name, '_', -1, 2) + 1)
      as session_id
  from
    v$db_pipes pp
  where
    pp.name like 'PKG\_TASKHANDLER.COMMANDPIPE\__%\__%' escape '\'
  ) pp
where
  rtrim( ltrim( pp.session_id, '0123456789'), '0123456789') = '_'
/



comment on table v_th_command_pipe is
  'Командные пайпы обработчиков заданий [ SVN root: Oracle/Module/TaskHandler].'
/
comment on column v_th_command_pipe.sid is
  'SID сессии обработчика ( из v$session).'
/
comment on column v_th_command_pipe.serial# is
  'serial# сессии обработчика ( из v$session).'
/
