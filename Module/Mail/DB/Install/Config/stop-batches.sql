--script: Install/Config/stop-batches.sql
--ќстанавливает выполнение заданий в Ѕƒ.
--
--¬ыполн€емые действи€:
--  - создает представление дл€ сохранени€ существующего значение параметра
--    JOB_QUEUE_PROCESSES;
--  - отключает запуск новых заданий через dbms_job, устанавлива€ значение
--    параметра JOB_QUEUE_PROCESSES равным 0;
--  - ожидает остановки выполнени€ заданий, запущенных через модуль Scheduler
--    ( максимум в течении maxBatchWait секунд);
--	кроме заданий-обработчиков ( из v_th_session)
--  - в случае, если задани€ не завершились за установленное врем€,
--    восстанавливает запуск заданий с помощью
--    <Install/Config/resume-batches.sql> и генерит ошибку;
--  - посылает команду остановки посто€нно запущенным задани€м ( с помощью
--    модул€ TaskHandler);
--  - ожидает остановки выполнени€ всех заданий, запущенных через модуль Scheduler
--    ( максимум в течении maxBatchWait секунд);
--  - в случае, если задани€ не завершились за установленное врем€,
--    восстанавливает запуск заданий с помощью
--    <Install/Config/resume-batches.sql> и генерит ошибку;
--
--ѕараметры:
--viewName                    - им€ представлени€ дл€ временного сохранени€
--                              установленного в Ѕƒ значени€ параметра
--                              JOB_QUEUE_PROCESSES
--
--ћакропеременные:
--maxBatchWait                - максимальное врем€ ожидани€ остановки батчей
--                              в секундах ( по умолчанию 60)
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
''—охранЄнное значение дл€ параметра JOB_QUEUE_PROCESSES
на врем€ установки модул€''';
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
                                        --ћаксимальное врем€ ожидани€ в секундах
  maxWaitSecond constant integer := 
    coalesce( to_number( trim( '&&maxBatchWait')), 60);
                                        --¬рем€ завершени€ ожидани€
  limitDate date := sysdate + maxWaitSecond / 86400;
                                        --„исло сессий модул€ 
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
      -- Ќет пустого расписани€ ( не обработчик)
      and not exists
      (
      select
        null
      from
        sch_schedule sd
      where
        sd.batch_id = ss.batch_id
        and not exists
          (
          select
            null
          from
            sch_interval iv
          where
            iv.schedule_id = sd.schedule_id
          )
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

						    --≈сли resumedViewName не null
						    --батчи запускаютс€
define resumedViewNameDef= ""
@oms-default resumedViewNameDef "' || :resumedViewName || '"
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
                                        --ѕровер€ем доступность пакета
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
                                        --ѕосылаем команду остановки
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
                                        --ћаксимальное врем€ ожидани€ в секундах
  maxWaitSecond constant integer := 
    coalesce( to_number( trim( '&&maxBatchWait')), 60);
                                        --¬рем€ завершени€ ожидани€
  limitDate date := sysdate + maxWaitSecond / 86400;
                                        --„исло сессий модул€ 
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
						    --≈сли resumedViewName не null
						    --батчи запускаютс€
define resumedViewNameDef= ""
@oms-default resumedViewNameDef "' || :resumedViewName || '"
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
