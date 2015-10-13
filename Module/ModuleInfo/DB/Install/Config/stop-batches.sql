-- script: Install/Config/stop-batches.sql
-- ������������� ���������� ������� � ��.
--
-- ����������� ��������:
--  - ������� ������������� ��� ���������� ������������� �������� ���������
--    JOB_QUEUE_PROCESSES;
--  - ��������� ������ ����� ������� ����� dbms_job, ������������ ��������
--    ��������� JOB_QUEUE_PROCESSES ������ 0;
--  - ������� ��������� ���������� �������, ���������� ����� ������ Scheduler
--    ( �������� � ������� maxBatchWait ������);
--    ����� �������, ���������� ���������
--  - � ������, ���� ������� �� ����������� �� ������������� �����,
--    ��������������� ������ ������� � �������
--    <Install/Config/resume-batches.sql> � ������� ������;
--  - �������� ������� ��������� ��������� ���������� �������� ( � �������
--    ������ TaskHandler);
--  - ������� ��������� ���������� ���� �������, ���������� ����� ������ Scheduler
--    ( �������� � ������� maxBatchWait ������);
--  - � ������, ���� ������� �� ����������� �� ������������� �����,
--    ��������������� ������ ������� � �������
--    <Install/Config/resume-batches.sql> � ������� ������;
--
-- ���������:
-- viewName                   - ��� ������������� ��� ���������� ����������
--                              �������������� � �� �������� ���������
--                              JOB_QUEUE_PROCESSES
--
-- ���������������:
-- maxBatchWait               - ������������ ����� �������� ��������� ������
--                              � �������� ( �� ��������� 60)
--

define viewName=&1
define viewColumnName = "JOB_QUEUE_PROCESSES";

prompt Getting JOB_QUEUE_PROCESSES value...

@@get-saved-value.sql "&viewName" "jobQueueProcessesDef"

declare
  savedJobQueueProcesses number := to_number('&jobQueueProcessesDef');
  param varchar2(100) := lower('job_queue_processes');
  strval varchar2(100);
  jobQueueProcessesVal number;

  procedure CreateOrReplaceView is
  begin

    execute immediate
'create or replace view &viewName
as
select
  to_number( ' || to_char( jobQueueProcessesVal ) || ' )
  as &viewColumnName
from
  dual
';
    execute immediate
'comment on table &viewName is
''���������� �������� ��� ��������� JOB_QUEUE_PROCESSES
�� ����� ��������� ������''';
    dbms_output.put_line('Value saved in view &viewName.');
  end CreateOrReplaceView;

  procedure DropView is
  begin
    execute immediate 'drop view &viewName';
  end DropView;

begin
  if
    dbms_utility.get_parameter_value(
      param, jobQueueProcessesVal , strval ) <> 0 then
    raise_application_error(
      -20000
      , 'Unexcected result of get_parameter_value.'
    );
  end if;
  dbms_output.put_line('JOB_QUEUE_PROCESSES: '
    || to_char( jobQueueProcessesVal ) );
  if jobQueueProcessesVal  = 0 and savedJobQueueProcesses <> 0 then
    dbms_output.put_line(
      'Warning. There''s a non-zero value saved in view &viewName' || '.'
    );
  else
    CreateOrReplaceView;
    dbms_output.put_line('Set JOB_QUEUE_PROCESSES = 0');
    begin
      execute immediate
        'alter system set JOB_QUEUE_PROCESSES = 0';
      dbms_output.put_line('System altered');
    exception when others then
      DropView;
      raise;
    end;
  end if;
end;
/

prompt Working batches...

select
  sid
   , batch_short_name
from
  v_sch_batch ss
where
  sid is not null
/
prompt * Waiting non-handler batch stop...

var resumedViewName varchar2( 30 )

timing start

declare
                                        --������������ ����� �������� � ��������
  maxWaitSecond constant integer :=
    coalesce( to_number( trim( '&&maxBatchWait')), 60);
                                        --����� ���������� ��������
  limitDate date := sysdate + maxWaitSecond / 86400;
                                        --����� ������ ������
  nSession integer;

begin
  dbms_output.put_line( 'maxWaitSecond='
    || to_char( maxWaitSecond ) );
  :resumedViewName := '';
  loop
    select
      count(*)
    into
      nSession
    from
      v_sch_batch ss
    where
      sid is not null
      and not exists
      (
      select
        1
      from
        v_th_session t
      where
        t.sid = ss.sid
        and t.serial# = ss.serial#
      )
    ;
    exit when nSession = 0 or sysdate >= limitDate;
    dbms_lock.sleep( 1);
  end loop;
  if sysdate >= limitDate then
    :resumedViewName := '&viewName';
  end if;
end;
/
timing stop

                --���� resumedViewName �� null
                --����� �����������
define resumedViewNameDef= ""
column "resumedViewNameColumn" new_value resumedViewNameDef format A30
select
   :resumedViewName as "resumedViewNameColumn"
from
  dual
/
column "resumedViewNameColumn" clear
@@resume-batches.sql "&resumedViewNameDef"

begin
  if :resumedViewName is not null then
    raise_application_error(
      -20000
      , 'Batch ( non-handler) stop waiting timed out'
    );
  end if;
end;
/

prompt Send stop command for all handlers...

declare

  isAccesible integer;

begin
                                        --��������� ����������� ������
  select
    count(*)
  into isAccesible
  from
    all_objects ob
  where
    ob.object_name = 'PKG_TASKHANDLER'
    and ob.object_type = 'PACKAGE'
    and rownum <= 1
  ;
                                        --�������� ������� ���������
  if isAccesible = 1 then
    execute immediate
      'begin pkg_TaskHandler.SendStopCommand; end;'
    ;
  else
    dbms_output.put_line(
      'Warning: skip send stop command'
      || ' ( package pkg_TaskHandler not accesible).'
    );
  end if;
end;
/
prompt * Waiting all batch stop...

var resumedViewName varchar2( 30 )

timing start

declare
                                        --������������ ����� �������� � ��������
  maxWaitSecond constant integer :=
    coalesce( to_number( trim( '&&maxBatchWait')), 60);
                                        --����� ���������� ��������
  limitDate date := sysdate + maxWaitSecond / 86400;
                                        --����� ������ ������
  nSession integer;

begin
  dbms_output.put_line( 'maxWaitSecond='
    || to_char( maxWaitSecond ) );
  :resumedViewName := '';
  loop
    select
      count(*)
    into nSession
    from
      v_sch_batch ss
    where
      sid is not null
    ;
    exit when nSession = 0 or sysdate >= limitDate;
    dbms_lock.sleep( 1);
  end loop;
  if sysdate >= limitDate then
    :resumedViewName := '&viewName';
  end if;
end;
/
timing stop

-- ���� resumedViewName �� null ����� �����������
define resumedViewNameDef= ""
column "resumedViewNameColumn" new_value resumedViewNameDef format A30
select
   :resumedViewName as "resumedViewNameColumn"
from
  dual
/
column "resumedViewNameColumn" clear
@@resume-batches.sql "&resumedViewNameDef"

begin
  if :resumedViewName is not null then
    raise_application_error(
      -20000
      , 'Batch ( all) stop waiting timed out'
    );
  end if;
end;
/
