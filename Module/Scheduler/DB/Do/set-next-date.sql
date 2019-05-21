--script: Do/set-next-date.sql
--”станавливает дату следующего запуска активированного пакета.
--
--ѕараметры:
--batchPattern                - маска дл€ имени пакетов ( batch_short_name),
--                              по умолчанию любые ( "%")
--nextDate                    - дата следующего запуска ( null по умолчанию
--                              немедленно)
--
--«амечание:
-- - в случае ошибки commit не выполн€етс€ и дата не мен€етс€;

define batchPattern = "coalesce( '&1', '%')"
define nextDate = "coalesce( &2, sysdate)"



declare

  cursor curBatch is
    select
      b.batch_id
      , b.batch_short_name
    from
      sch_batch b
    where
      b.active_flag = 1
      and b.batch_short_name like &batchPattern
    order by
      b.batch_short_name
  ;

  nextDate date := &nextDate;

  nDone integer := 0;

begin
  for rec in curBatch loop
    pkg_Scheduler.SetNextDate(
      batchID => rec.batch_id
      , nextDate => nextDate
      , operatorID => pkg_Operator.GetCurrentUserID()
    );
    dbms_output.put_line(
      rpad( rec.batch_short_name, 30)
      || ' ( batch_id =' || lpad( rec.batch_id, 3)
      || ')   - set date '
      || to_char( nextDate, 'dd.mm.yy hh24:mi:ss')
    );
    nDone := nDone + 1;
  end loop;
  if nDone = 0 then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'ѕакеты не найдены.'
    );
  end if;
  commit;
end;
/



undefine batchPattern
undefine nextDate
