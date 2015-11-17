--script: Do/stop-sid.sql
--Посылает обработчику команду остановки.
--
--Параметры:
--sessionSid                  - SID сессии ( null без ограничений)

define sessionSid = "&1"



begin
  pkg_TaskHandler.sendStopCommand(
    sessionSid => &sessionSid
  );
end;
/



undefine sessionSid
