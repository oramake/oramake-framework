-- script: Do/kill-blocking-sessions.sql
-- ѕрерывание сессий, блокирующих пакет pkg_Operator
declare
  sqlText varchar2(1000);
begin
  for c in (
select * from v$session where sid in
(select session_id from dba_ddl_locks where name = 'PKG_OPERATOR' AND OWNER='INFORMATION')
) loop
     sqlText := 'alter system kill session ''';
     sqlText := sqlText || to_char(c.sid) || ',' || to_char(c.serial#) || '''' ;
     pkg_COmmon.outputMessage(sqlText);
     execute immediate sqlText;
  end loop;
end;
/
