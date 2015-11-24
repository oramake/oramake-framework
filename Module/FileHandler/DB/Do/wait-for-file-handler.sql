prompt * Waiting for file handler...

timing start

declare
                                        --Максимальное время ожидания в секундах
  maxWaitSecond constant integer := 
    coalesce( to_number( trim( '&&maxBatchWait')), 60);
                                        --Время завершения ожидания
  limitDate date := sysdate + maxWaitSecond / 86400;
                                        --Число ожидающих запросов
  nRequest integer;
					          --Доступность FileHandler
  isAccesible integer;

  procedure CheckAccessible 
  is
  begin
                                        --Проверяем доступность пакета
    execute immediate
    '
    select
      count(*)
    from
      all_objects ob
    where
      ob.object_name = ''V_FLH_REQUEST_WAIT''
      and ob.object_type = ''VIEW''
      and rownum <= 1
    '
    into isAccesible
    ;
  end CheckAccessible;

begin
  CheckAccessible;
  if isAccesible=1 then
    dbms_output.put_line( 'maxWaitSecond=' 
      || to_char( maxWaitSecond ) );
    loop
      select
        count(*)
      into nRequest 
      from
        v_flh_request_wait
      ;
      exit when nRequest = 0 or sysdate >= limitDate;
      dbms_lock.sleep( 1);
    end loop; 
    if sysdate >= limitDate then 
      raise_application_error(
        -20000
        , 'File handler waiting timed out'
      );
    end if;
  else
    dbms_output.put_line('FileHandler is not accessible.');
  end if;
end;
/
timing stop