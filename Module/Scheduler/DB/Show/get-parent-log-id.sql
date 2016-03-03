-- script: get-parent-log-id.sql
-- По log_id получается корень лога.
declare
  logId integer := &1;
  parentLogId integer;
begin
  loop
    select
      parent_log_id
    into
      parentLogId
    from
      sch_log
    where
      log_id = logId
    ;
    exit when parentLogId is null;
    logId := parentLogId;
  end loop;
  pkg_Common.outputMessage( to_char( logId));
end;
/
