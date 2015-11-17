--script: Do/stop.sql
--Посылает команду остановки сессиям обработчиков.
--
--Параметры:
--taskPattern                 - шаблон имени задачи ( строка
--                              "<module_name>:<process_full_name>" сравнивается
--                              по like с этим шаблоном, по умолчанию без
--                              ограничений)
--
--Замечания:
--  - ошибки при отправке команды сессиям игнорируются ( попытка отправки
--    команды производится всем подходящим сессиям независимо от ошибок
--    отправки);
--

define taskPattern = "coalesce( nullif( '&1', 'null'), '%')"



declare

  cursor curSession is
select
  ss.*
from
  v_th_session ss
where
  ss.module_name || ':' || ss.process_full_name like &taskPattern
order by
  ss.module_name
  , ss.process_full_name
  , ss.sid
;

begin
  for rec in curSession loop
    begin
      dbms_output.put( 
        rec.sid || ',' || rec.serial#  || ': '
        || rec.module_name || ':' || rec.process_full_name
        || ': '
      );
      pkg_TaskHandler.sendStopCommand(
        sessionSid => rec.sid
        , sessionSerial => rec.serial#
      );
      dbms_output.put_line( 'stop sended');
    exception when others then
      dbms_output.put_line( 'ERROR');
      dbms_output.put_line( substr( SQLERRM, 1, 250));
    end;
  end loop;
end;
/



undefine taskPattern
