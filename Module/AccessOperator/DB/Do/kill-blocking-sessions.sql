-- script: db/do/kill-blocking-sessions.sql
-- Пренудительное прерывание сессий, блокирующих установку модуля.
declare
   command varchar(4000);
begin
  for locks in (
    select distinct
      v.sid
    , v.serial#
    from
      dba_ddl_locks d
    inner join
      v$session v
    on
      v.sid = d.session_id
    where
      d.name = 'PKG_OPERATOR'
      and d.session_Id <> pkg_COmmon.getSessionSId()
  ) loop
      command := 'alter system kill session '''
        || to_char(locks.sid) || ',' || to_char(locks.serial#) || ''''
      ;
      pkg_Common.outputMessage(command);
      execute immediate command;
  end loop;
end;
/
