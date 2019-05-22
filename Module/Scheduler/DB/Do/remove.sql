--script: Do/remove.sql
--Удаляет пакеты из БД.
--Из таблиц sch_* удаляются все данные, относящиеся к пакету, кроме логов.
--Также удаляются неиспользуемые задания ( <sch_job>).
--
--Параметры:
--batchPattern                - маска для имени пакетов ( batch_short_name)
--
--Замечания:
-- - изменения не фиксируются ( нужно явно выполнить commit);
-- - в случае ошибки все изменения откатываются;
-- - удаляемые пакеты должны быть предварительно деактивированы;
--

define batchPattern = "&1"



declare

  cursor curBatch is
    select
      b.batch_id
      , b.batch_short_name
      , b.activated_flag
    from
      sch_batch b
    where
      b.batch_short_name like '&batchPattern'
    order by
      b.batch_short_name
  ;

  nDone integer := 0;

begin
  for rec in curBatch loop
    begin
      if rec.activated_flag = 1 then
        raise_application_error(
          pkg_Error.IllegalArgument
          , 'Активированный пакет не может быть удален.'
        );
      end if;
      pkg_SchedulerLoad.deleteBatch( batchId => rec.batch_id);
      dbms_output.put_line(
        rpad( rec.batch_short_name, 30)
        || ' ( batch_id =' || lpad( rec.batch_id, 3)
        || ')   - removed');
      nDone := nDone + 1;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , 'Ошибка при удалении пакета ' || rec.batch_short_name || '('
          || ' batch_id=' || to_char( rec.batch_id)
          || ').'
        , true
      );
    end;
  end loop;
  if nDone = 0 then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Не найдены пакеты для удаления.'
    );
  else
    dbms_output.put_line( 'removed ( need commit): ' || nDone);
  end if;
end;
/



undefine batchPattern
