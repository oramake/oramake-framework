--script: Do/activate.sql
--Активирует пакеты.
--
--Параметры:
--batchPattern                - маска для имени пакетов ( batch_short_name),
--                              по умолчанию любые ( "%")
--batchTypePattern            - маска для типа пакетов ( batch_type_name),
--                              по умолчанию любые ( "%")
--usedDayCount                - только пакеты, которые выполнялись или
--                              управлялись в последние usedDayCount дней
--                              ( 0 текущий день, по умолчанию null ( без
--                              ограничения))
--
--Замечания:
--  - в случае ошибки commit не выполняется и ни один пакет не активируется;
--  - в случае, если пакет уже активирован, время очередного запуска будет
--    перерасчитано по расписанию и текущий номер повтора ( если есть) будет
--    сброшен;
--  

define batchPattern     = "coalesce( nullif( '&1', 'null'), '%')"
define batchTypePattern = "coalesce( nullif( '&2', 'null'), '%')"
define usedDayCount     = "nullif( '&3', 'null')"




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
        b.batch_short_name like &batchPattern
        and case when &usedDayCount is not null then
            (
            select
              max( brl.date_ins)
            from
              v_sch_batch_root_log brl
            where
              brl.batch_id = b.batch_id
              and brl.message_type_code in (
                  pkg_Scheduler.BStart_MessageTypeCode
                  , pkg_Scheduler.BManage_MessageTypeCode
                )
            )
            + &usedDayCount
          else
            sysdate
          end
          >= trunc( sysdate)
      )
    order by
      b.batch_short_name
  ;  
  
  nDone integer := 0;

begin
  for rec in curBatch loop
    pkg_Scheduler.ActivateBatch( 
      batchID => rec.batch_id
      , operatorID => pkg_Operator.GetCurrentUserID()
    );
    dbms_output.put_line( 
      rpad( rec.batch_short_name, 30)
      || ' ( batch_id =' || lpad( rec.batch_id, 3)
      || ')   - activated');
    nDone := nDone + 1;
  end loop;
  if nDone = 0 then
    raise_application_error( 
      pkg_Error.IllegalArgument
      , 'Не найдены пакеты для активации.'
    );
  end if;
  commit;
end;
/



undefine batchPattern
undefine batchTypePattern
undefine usedDayCount
