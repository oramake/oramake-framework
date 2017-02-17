declare
  realSumLength integer;
  isOk boolean;
  passedCount integer := 0;
  messageCount integer;
  
  procedure DoTest(
    sumMessageLength integer
    , messageCount integer
  )
  is
    type tabMessageLengths is table of integer;
    colMessageLengths tabMessageLengths;
    
    procedure GetRandomNumbers
    is
      totalLength number := 0;
    begin
      dbms_random.seed(TO_CHAR(SYSDATE,'MM-DD-YYYY HH24:MI:SS'));
      colMessageLengths := tabMessageLengths();
      colMessageLengths.extend( messageCount);
      for i in 1..messageCount loop
        while coalesce( colMessageLengths(i),0) = 0 loop
          colMessageLengths(i) := dbms_random.value(0.1,1);
        end loop;  
        totalLength := totalLength + colMessageLengths(i);
      end loop;
      realSumLength := 0;
      for i in 1..messageCount loop
        colMessageLengths(i) := 
          round( sumMessageLength * colMessageLengths(i) / totalLength);
        realSumLength := realSumLength +   colMessageLengths(i);
      end loop;
    end GetRandomNumbers; 

    procedure GenProcedures
    is
      sqlText varchar2( 32767);
    begin
      for c in colMessageLengths.first..colMessageLengths.last loop
    sqlText := '
create or replace procedure drop_me_tmp'|| to_char( c) || ' as
begin' ||
     case when c = 1 then '
     declare
       g number;
     begin
       g := 1/0;
     end;'
     else '
  drop_me_tmp' || to_char( c-1) || '();'
     end || '
exception when others then
  raise_application_error(
    -20000 - ' || to_char( trunc(c) ) || '
    , lg_logger_t.GetRootLogger().ErrorStack(
        ''Ошибка во время выполнения процедуры drop_me_tmp' || to_char(c) ||'''
        || lpad( ''*'', ' || to_char( colMessageLengths(c)) || ' , ''*'')
        || ''Error ' || to_char( -1) || ''')
      , true
  );
end;';  
        execute immediate sqlText;
      end loop;    
    end GenProcedures;  
    
    procedure DropProcedures
    is
    begin
      for i in -colMessageLengths.last..-colMessageLengths.first loop
        execute immediate
          'drop procedure drop_me_tmp' || to_char( -i);
      end loop;
    end DropProcedures;      
    
    procedure RunProcedures
    is
      message varchar2( 32767);
    begin
      execute immediate
      ' begin drop_me_tmp' || to_char( colMessageLengths.count) || '; end;';
      isOk := false;
    exception when others then 
      begin
        message := pkg_Logging.GetErrorStack;
       
        isOk := 
           length( replace( message , '*')) - length( message) + realSumLength = 0;
      exception when others then
        pkg_Common.OutputMessage('1');
        raise;
      end;    
    end RunProcedures;
    
  begin
    begin
      DropProcedures;
    exception when others then null;
    end;  
    GetRandomNumbers;
    GenProcedures;
    RunProcedures;
    if isOk = false then
     lg_logger_t.GetRootLogger().SetLevel( pkg_Logging.Trace_LevelCode);
     RunProcedures;
     lg_logger_t.GetRootLogger().SetLevel( pkg_Logging.Info_LevelCode);
    end if;
    DropProcedures;
  end;
  
begin
  lg_logger_t.GetRootLogger().SetLevel( pkg_Logging.Info_LevelCode);
  for i in 1..100 loop
    messageCount := 1;
    DoTest( 
      10000
      , messageCount
    );  
    if isOk = false then
      dbms_output.put_line( 'test' || i );
      dbms_output.put_line( 'message count: ' ||  to_char(messageCount));
      dbms_output.put_line( 'real sum length: ' || realSumLength );
      dbms_output.put_line( case when isOk then 'passed' else 'not passed' end);
    end if;  
    if isOk then 
      passedCount := passedCount + 1; 
    end if;
  end loop;  
  dbms_output.put_line( 'passedCount: ' ||  to_char(passedCount));
end;
/
