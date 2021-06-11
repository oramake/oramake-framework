--script: Install/Config/Local/resume-job.sql
--Восстанавливает выполнение заданий в БД
--
--Выполняемые действия:
--  - разрешает запуск новых заданий через dbms_job, устанавливая значение
--    параметра JOB_QUEUE_PROCESSES равным ранее сохраненному значению;
--  - удаляет представление, использовавшееся для сохранения значения параметра
--    JOB_QUEUE_PROCESSES;
--
--Параметры:
--resumedViewName             - имя представления со значением параметра
--                              JOB_QUEUE_PROCESSES для восстановления
--
--Макропеременные:
--forcedJobQueueProcesses     - устанавливаемое значение параметра
--                              JOB_QUEUE_PROCESSES ( по умолчанию берется
--                              ранее сохраненное в представлении)
--

define resumedViewName="&1"

begin
  if '&resumedViewName' is null then
    dbms_output.put_line('No actions in resume-job');
  else
    dbms_output.put_line('Getting saved JOB_QUEUE_PROCESSES...');
  end if;
end;
/

@@get-saved-value.sql "&resumedViewName" "jobQueueProcessesDef"

declare
  savedJobQueueProcesses number:= to_number('&jobQueueProcessesDef');
  param varchar2(100) := lower('job_queue_processes');
  strval varchar2(100);
  jobQueueProcessesVal number;
                                        --Новое значение параметра
  newJobQueueProcesses varchar2(50);
begin
  if '&resumedViewName' is not null then
    if savedJobQueueProcesses is null then
      raise_application_error(
       -20000
        , 'There is no saved value in view &resumedViewName'
      );
    else
      if
        dbms_utility.get_parameter_value(
          param, jobQueueProcessesVal , strval ) <> 0 then
        raise_application_error(
          -20000
          , 'Unexcected result of get_parameter_value.'
        );
      end if;
      if savedJobQueueProcesses = 0
         and coalesce( jobQueueProcessesVal, 0 )  <> 0
      then
        raise_application_error(
          -20000
          , 'Current parameter JOB_QUEUE_PROCESSES value <> 0.'
        );
      end if;
      newJobQueueProcesses := coalesce(
          to_char( to_number( trim( '&forcedJobQueueProcesses')))
          , to_char( savedJobQueueProcesses)
      );
      dbms_output.put_line(
        'Set JOB_QUEUE_PROCESSES = ' || newJobQueueProcesses
      );
      execute immediate
        'alter system set JOB_QUEUE_PROCESSES = ' || newJobQueueProcesses
      ;
      dbms_output.put_line('System altered');
      execute immediate 'drop view &resumedViewName';
      dbms_output.put_line('View &resumedViewName dropped');
    end if;
  end if;
end;
/
