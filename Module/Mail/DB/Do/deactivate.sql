--script: Do/deactivate.sql
--Деактивирует процессы отправки почтовых сообщений
--
--Параметры:
--batchPattern                - маска для имени пакетов ( batch_short_name),
--                              по умолчанию любые ( "%")
--
--Замечание:
-- - в случае ошибки commit не выполняется и ни один пакет не деактивируется;
-- - при деактивации выполняющимся процессам посылается команда остановки;

define batchPattern = "coalesce( '&1', '%')"

define batchTypeNameRus = "Почтовые сообщения"



declare

  cursor curBatch is
    select
      b.batch_id
      , b.batch_short_name
    from
      sch_batch b
    where
      b.batch_type_id =
        (
        select
          bt.batch_type_id
        from
          sch_batch_type bt
        where
          bt.batch_type_name_rus = '&batchTypeNameRus'
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
  dbms_output.put_line( 'Деактивировано пакетов: ' || to_char( nDone));
  commit;
end;
/



undefine batchTypeNameRus

undefine batchPattern
