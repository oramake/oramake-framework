-- Перезапуск пакетов обработки задач
-- Перезапускает обработчики задач, выполняющиеся в сессиях указанных пакетов.
declare

  -- Список пакетов для перезапуска
  batchList varchar2(4000) := pkg_Scheduler.GetContextString(
    'BatchList', riseException => 1
  );

  -- Время ожидания между перезапусками
  restartTimeout number := pkg_Scheduler.GetContextInteger(
    'RestartTimeout'
  );

  -- Время ожидания перед проверкой
  checkTimeout number := pkg_Scheduler.GetContextInteger(
    'CheckTimeout'
  );

  cursor curBatch( batchList varchar2) is
select
  b.batch_short_name
  , b.sid
  , b.serial#
  , b.batch_short_name || ' (' || b.sid || ',' || b.serial# || ')'
    as session_name
from
  (
  select
    b.*
    , instr( ',' || batchList || ',', ',' || b.batch_short_name || ',')
      as list_position
  from
    v_sch_batch b
  where
    b.sid is not null
  ) b
where
  b.list_position > 0
order by
  b.list_position
;

  cursor curSession( sessionList varchar2) is
select
  ss.sid
  , ss.serial#
  , substr(
      substr(
        sessionList
        , 1
        , instr( sessionList, ')', ss.list_position)
      )
      , instr( substr( sessionList, 1, ss.list_position), ',', -1) + 2
    )
    as session_name
from
  (
  select
    ss.*
    , instr( sessionList, '(' || ss.sid || ',' || ss.serial# || ')')
      as list_position
  from
    v$session ss
  ) ss
where
  ss.list_position > 0
order by
  ss.list_position
;

  nSend pls_integer := 0;

  restartTime date := sysdate - 1/86400;
  sessionList varchar2( 4000);
  workingSessionList varchar2( 4000);
  sleepTimeout integer := 10;
  errorMessage varchar2( 4000);

begin
  for rec in curBatch( batchList) loop
    begin
      if nSend > 0 and restartTimeout > 0 then
        dbms_lock.sleep( restartTimeout);
      end if;
      pkg_TaskHandler.SendStopCommand( rec.sid, rec.serial#);
      sessionList := sessionList || ', ' || rec.session_name;
      nSend := nSend + 1;
    exception when others then
      errorMessage := substr(
        'Ошибка при посылке команды остановки для сессии пакета "'
          || rec.batch_short_name || '" ( sid,serial#='
          || rec.sid || ',' || rec.serial# || ').'
        || chr(10) || SQLERRM
        || case when errorMessage is not null then
            chr(10) || errorMessage
          end
        , 1, 4000
      );
    end;
  end loop;
  if nSend > 0 then
    if checkTimeout > 0 then
      loop
        workingSessionList := null;
        for rec in curSession( sessionList) loop
          workingSessionList := workingSessionList || ', ' || rec.session_name;
        end loop;
        exit when workingSessionList is null or checkTimeout <= 0;
        sleepTimeout := least( checkTimeout, sleepTimeout);
        dbms_lock.sleep( sleepTimeout);
        checkTimeout := checkTimeout - sleepTimeout;
      end loop;
      if workingSessionList is not null then
        raise_application_error(
          pkg_Error.ProcessError
          , 'Не завершились в отведенное время следующие пакеты'
          || ' [ пакет (sid,serial#)]:' || substr( workingSessionList, 2) || '.'
          || case when errorMessage is not null then
              chr(10) || errorMessage
            end
        );
      end if;
    end if;
    jobResultMessage :=
      'Выполнен перезапуск ' || to_char( nSend) || ' пакет(а,ов).';
  else
    jobResultID := pkg_Scheduler.False_ResultID;
    jobResultMessage := 'Не найдено выполняемых пакетов.';
  end if;
  if errorMessage is not null then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , errorMessage
    );
  end if;
end;
