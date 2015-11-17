-- ѕерезапуск пакетов обработки задач
-- ѕерезапускает обработчики задач, выполн€ющиес€ в сесси€х указанных пакетов.
--
-- BatchList                     - список пакетов дл€ перезапуска
-- RestartTimeout                - интервал между перезапуском пакетов
-- CheckTimeout                  - ожидание перед проверкой завершени€ сессий
declare
                                        --—писок пакетов дл€ перезапуска
  batchList varchar2(4000) := pkg_Scheduler.GetContextString(
    'BatchList', riseException => 1
  );
                                        --¬рем€ ожидани€ между перезапусками
  restartTimeout number := pkg_Scheduler.GetContextInteger(
    'RestartTimeout'
  );
                                        --¬рем€ ожидани€ перед проверкой
  checkTimeout number := pkg_Scheduler.GetContextInteger(
    'CheckTimeout'
  );
                                        --—ессии пакетов
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

  nSend pls_integer := 0;               --„исло останавливаемых сессий

  restartTime date := sysdate - 1/86400;--¬рем€ начала перезапуска
  sessionList varchar2( 4000);          --—писок сессий
  workingSessionList varchar2( 4000);   --—писок работающих сессий
  sleepTimeout integer := 10;           --»нтревал между проверками
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
        'ќшибка при посылке команды остановки дл€ сессии пакета "'
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
    if checkTimeout > 0 then            --ѕроверка остановки сессий
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
          , 'Ќе завершились в отведенное врем€ следующие пакеты'
          || ' [ пакет (sid,serial#)]:' || substr( workingSessionList, 2) || '.'
          || case when errorMessage is not null then
              chr(10) || errorMessage
            end
        );
      end if;
    end if;
    jobResultMessage :=
      '¬ыполнен перезапуск ' || to_char( nSend) || ' пакет(а,ов).';
  else
    jobResultID := pkg_Scheduler.False_ResultID;
    jobResultMessage := 'Ќе найдено выполн€емых пакетов.';
  end if;
  if errorMessage is not null then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , errorMessage
    );
  end if;
end;
