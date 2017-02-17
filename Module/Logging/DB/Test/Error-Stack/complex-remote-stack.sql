-- Тестирование получения стека через два линка
-- на базе где генерируется ошибка полагается dblink пустой
declare
  sqlText varchar2( 32767);
  toOutput boolean := true;
  toExecute boolean := true;
  dblink varchar2(30) := '&dblink';
begin
  for c in 1..100 loop
    pkg_Common.OutputMessage( 'prompt ' || c);
    sqlText := '
create or replace procedure drop_me_tmp'|| to_char( c) || ' as
begin' ||
     case when c = 1 and dblink is null then '
  if 1/0 > 0 then
    null;
  end if;'
     when c = 1 and dblink is not null then '
  execute immediate 
    ''begin drop_me_tmp100@' || dblink || ';end;''
  ;'
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
    case when c = 1 and dblink is not null then
    '
    , lg_logger_t.GetRootLogger().RemoteErrorStack(
        ''Ошибка во время выполнения процедуры drop_me_tmp_' || dblink || '_' || to_char( c) || ' ''
        || lpad( ''_'', 50, ''_'')
        || ''Error ' || to_char( -1) || ''', ''' || dblink || ''')
      , true
    '
    else
    '
    , lg_logger_t.GetRootLogger().ErrorStack(
        ''Ошибка во время выполнения процедуры drop_me_tmp_' || dblink || '_' || to_char( c) || ' ''
        || lpad( ''_'', 50, ''_'')
        || ''Error ' || to_char( -1) || ''')
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
      pkg_Common.OutputMessage( 'prompt execute_' || c);
      if toExecute then
        execute immediate sqlText;
      end if;
      pkg_Common.OutputMessage( 'prompt afteexecute_' || c);
  end loop;
end;
/
begin
  for i in 1..100 loop
    execute immediate
      'alter procedure drop_me_tmp' || to_char( i) || ' compile';
  end loop;
end;  
/
begin
  drop_me_tmp100();
end;
/
grant execute on drop_me_tmp100 to public
/
create public synonym drop_me_tmp100 for drop_me_tmp100
/
