alter table lg_log drop constraint lg_log_fk_level_code
/

declare
  taskFkFlag integer;
begin
  select
    count(*)
  into taskFkFlag
  from
    user_tables t
  where
    t.table_name = 'TP_TASK_LOG'
  ;
  if taskFkFlag = 1 then
    execute immediate
      'alter table TP_TASK_LOG drop constraint TP_TASK_LOG_FK_LEVEL_CODE'
    ;
    dbms_output.put_line(
      'constraint droped: TP_TASK_LOG_FK_LEVEL_CODE'
    );
  end if;
end;
/

drop table
  lg_level
/

@oms-run Install/Schema/Last/lg_level.tab
@oms-run Install/Data/Last/lg_level.sql

declare
  taskFkFlag integer;
begin
  select
    count(*)
  into taskFkFlag
  from
    user_tables t
  where
    t.table_name = 'TP_TASK_LOG'
  ;
  if taskFkFlag = 1 then
    execute immediate
'alter table
  tp_task_log
add constraint
  tp_task_log_fk_level_code
foreign key
  ( level_code)
references
  lg_level ( level_code)
'
    ;
    dbms_output.put_line(
      'constraint created: TP_TASK_LOG_FK_LEVEL_CODE'
    );
  end if;
end;
/

alter table
  lg_log
add constraint
  lg_log_fk_level_code
foreign key
  ( level_code)
references
  lg_level (
    message_level_code
  )
enable novalidate
/
