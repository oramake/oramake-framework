--script: Do/deactivate.sql
--Деактивирует пакеты.
--
--Параметры:
--batchPattern                - маска для имени пакетов ( batch_short_name),
--                              по умолчанию любые ( "%")
--batchTypePattern            - маска для типа пакетов ( batch_type_name),
--                              по умолчанию любые ( "%")
--
--Замечание:
-- - в случае ошибки commit не выполняется и ни один пакет не деактивируется;
-- - при деактивации выполняющимся процессам посылается команда остановки;

define batchPattern = "coalesce( '&1', '%')"
define batchTypePattern = "coalesce( nullif( '&2', 'null'), '%')"



declare

  cursor curBatch is
    select
      b.batch_id
      , b.batch_short_name
    from
      sch_batch b
    where
      b.batch_type_id in
        (
        select
          bt.batch_type_id
        from
          sch_batch_type bt
        where
          bt.batch_type_name_rus like &batchTypePattern
        )
      and (
        oracle_job_id is not null
        and batch_short_name like &batchPattern
      )
    order by
      b.batch_short_name
  ;  
  
  nDone integer := 0;

begin
  for rec in curBatch loop
    pkg_Scheduler.DeactivateBatch( 
      batchID => rec.batch_id
      , operatorID => pkg_Operator.GetCurrentUserID()
    );
    dbms_output.put_line( 
      rpad( rec.batch_short_name, 30)
      || ' ( batch_id =' || lpad( rec.batch_id, 3)
      || ')   - deactivated');
    nDone := nDone + 1;
  end loop;
  if nDone = 0 then
    raise_application_error( 
      pkg_Error.IllegalArgument
      , 'Не найдены пакеты для деактивации.'
    );
  end if;
  commit;
end;
/



undefine batchPattern
undefine batchTypePattern
