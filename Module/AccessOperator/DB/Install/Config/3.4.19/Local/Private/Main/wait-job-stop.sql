prompt * Waiting job stop...

timing start

declare
                                        --Максимальное время ожидания в секундах
  maxWaitSecond constant integer := 10;
                                        --Время завершения ожидания
  limitDate date := sysdate + maxWaitSecond / 86400;
                                        --Число job-ов
  jr integer;

begin
  loop
    select
      count(*)
    into 
      jr
    from
      dba_jobs_running ss
    ;
    exit when jr = 0 or sysdate >= limitDate;
    dbms_lock.sleep( 1);
  end loop;
end;
/

timing stop