--script: Do/stop-all.sql
--Посылает команду остановки всем сессиям, для которых существует командный
--канал.
--
--Замечания:
--  - скрипт не использует пользовательские пакеты ( включая <pkg_TaskHandler>)
--    чтобы оставаться работоспобным в случае их инвалидации;
--

declare
  
  cursor curSession is
    select
      ss.sid
      , ss.serial#
      , cp.name as pipe_name
    from
      v$session ss
      inner join v_th_command_pipe cp
        on cp.sid = ss.sid
        and cp.serial# = ss.serial#
    order by
      1, 2
  ;

  PROCEDURE SENDMESSAGE
   (PIPENAME VARCHAR2
   ,TIMEOUT INTEGER := dbms_pipe.maxwait
   ,MAXPIPESIZE INTEGER := 8192
   )
   IS
  --Посылает сообщение в канал.
  --
  --Параметры:
  --pipeName                    - имя канала
  --timeout                     - таймаут ожидания (в секундах)
  --maxPipeSize                 - требуемый максимальный размер канала

                                          --Результат операции с каналом
    pipeStatus number := null;            
    
  --SendMessage
  begin
                                          --Посылаем сообщение
    pipeStatus := dbms_pipe.send_message(
      pipename  => pipeName
      , timeout => timeout
      , maxpipesize => maxPipeSize
    );
                                          --Проверяем успешность посылки
    if pipeStatus <> 0 then
      if pipeStatus = 1 then
        raise_application_error(
          -20001
          , 'Неуспешный результат отправки сообщения ('
            || ' код ' || to_char( pipeStatus)
            || ').'
        );
      end if;
    end if;
  exception when others then
    dbms_pipe.reset_buffer;
    raise_application_error(
      -20001
      , 'Ошибка при отправке сообщения в канал "' || pipeName || '".'
      , true
    );
  end SendMessage;

begin
  for rec in curSession loop
    dbms_output.put_line( 
      rec.sid || ',' || rec.serial# || ' stop...'
    );
    dbms_pipe.pack_message( 'stop');
    SendMessage( rec.pipe_name);
  end loop;
end;
/
