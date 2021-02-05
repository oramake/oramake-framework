-- script: Do/set-next-date.sql
-- Устанавливает дату следующего запуска активированного пакета.
--
-- Параметры:
-- batchPattern               - Маска для имени пакетов ( batch_short_name),
--                              по умолчанию любые ( "%")
-- nextDate                   - Дата следующего запуска ( null по умолчанию
--                              немедленно)
--
-- Замечание:
--  - в случае ошибки commit не выполняется и дата не меняется;

define batchPattern = "coalesce( '&1', '%')"
define nextDate = "&2"



declare

  cursor curBatch is
    select
      b.batch_id
      , b.batch_short_name
    from
      sch_batch b
    where
      b.activated_flag = 1
      and b.batch_short_name like &batchPattern
    order by
      b.batch_short_name
  ;

  nextDate timestamp with time zone :=
    cast( &nextDate as timestamp with time zone)
    at time zone to_char( systimestamp, 'tzh:tzm')
  ;

  nDone integer := 0;

begin
  for rec in curBatch loop
    pkg_Scheduler.setNextDate(
      batchID => rec.batch_id
      , nextDate => nextDate
      , operatorID => pkg_Operator.getCurrentUserID()
    );
    dbms_output.put_line(
      rpad( rec.batch_short_name, 30)
      || ' ( batch_id =' || lpad( rec.batch_id, 3)
      || ')   - set date '
      || to_char( nextDate, 'dd.mm.yyyy hh24:mi:ss.ff3 tzh:tzm')
    );
    nDone := nDone + 1;
  end loop;
  if nDone = 0 then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Пакеты не найдены.'
    );
  end if;
  commit;
end;
/



undefine batchPattern
undefine nextDate
