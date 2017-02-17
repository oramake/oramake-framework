-- script: Test/Error-Stack/error-stack.sql
-- Скрипт для тестирование стека ошибок большой длины
declare
  sqlText varchar2( 32767);
  toOutput boolean := true;
  toExecute boolean := true;
begin
  for c in 1..100 loop
    sqlText := '
create or replace procedure drop_me_tmp'|| to_char( c) || ' as
begin' ||
     case when c = 1 then '
  if 1/0 > 1/0 then
    null;
  end if;'
     when c = 50 then
       '
declare
  messageText varchar2( 32767);       
begin
  begin
    drop_me_tmp' || to_char( c-1) || '();
  exception when others then   
    messageText := pkg_Logging.GetErrorStack();
  end;  
  raise_application_error(
    -20000 - ' || to_char( trunc(c/4) ) || '
    , lg_logger_t.GetRootLogger().ErrorStack(
         substr( ''Специальная ошибка drop_me_tmp: "'' || messageText || ''"'', 1, 32767)
      )   
  );  
end;
     '
     else '
  drop_me_tmp' || to_char( c-1) || '();'
     end || '
exception when others then
  raise_application_error(
    -20000 - ' || to_char( trunc(c) ) ||
    case when c > 0 then
    '
    , lg_logger_t.GetRootLogger().ErrorStack(
        ''Ошибка во время выполнения процедуры drop_me_tmp' || to_char( c) || ' ''
        || lpad( ''_'', 100, ''_'')
        || ''Error ' || to_char( -1) || ''')
      , true
    '
    else
    '
    , lg_logger_t.GetRootLogger().ErrorStack(
        ''Ошибка во время выполнения процедуры drop_me_tmp' || to_char( c) || ' ''
        || lpad( ''_'', 10000, ''_'')
        || ''Error ' || to_char( c) || ''')
      , true
    '
    end
    ||
    '
  );
end;';
      if toOutput then
        pkg_Common.OutputMessage( sqlText || chr(10) || '/');
      end if;
      if toExecute then
        execute immediate sqlText;
      end if;
  end loop;
end;
/

declare
  lg lg_logger_t := lg_logger_t.GetRootLogger();
begin
  lg.SetLevel( pkg_Logging.Debug_LevelCode);
  drop_me_tmp100();
--exception when others then 
--  pkg_Common.OutputMessage(pkg_Logging.GetErrorStack);
end;    
/
begin
  for i in 1..100 loop
    execute immediate
      'drop procedure drop_me_tmp' || to_char( 100 - i + 1);
  end loop;
end DropProcedures;   
/
