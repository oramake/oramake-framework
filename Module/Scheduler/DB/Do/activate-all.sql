-- script: Do/activate-all.sql
-- Активирует пакетные задания.
--
-- Параметры:
-- usedDayCount               - только пакеты, которые останавливались
--                              скриптом <Do/deactivate-all.sql> в последние
--                              usedDayCount дней
--                              (0 текущий день, null без ограничения
--                                (по умолчанию))
--


declare

  usedDayCount number := to_number( '&1');

  -- Логер скрипта
  logger lg_logger_t := lg_logger_t.getLogger(
    moduleName    => pkg_Scheduler.Module_Name
    , objectName  => 'Do/activate-all.sql'
  );

  cursor curBatch is
    select
      b.batch_id
      , b.batch_name_rus
      , b.batch_short_name
      , b.oracle_job_id
      , b.next_date
    from
      v_sch_batch b
      left join
        (
        select distinct
          lg.context_value_id as batch_id
        from
          v_sch_batch_operation bo
          inner join lg_log lg
            on lg.sessionid = bo.sessionid
              and lg.log_id between bo.start_log_id and bo.finish_log_id
              and lg.context_type_id = bo.batch_context_type_id
              and lg.context_type_level = bo.execution_level + 1
              and lg.message_label
                = pkg_SchedulerMain.Deactivate_BatchMsgLabel
              and lg.context_value_id is not null
        where
          bo.batch_id is null
          and bo.batch_operation_label
            = pkg_SchedulerMain.DeactivateAll_BatchMsgLabel
          and bo.processed_count > 0
          and bo.start_time_utc >=
            sys_extract_utc(
              to_timestamp_tz(
                to_char( systimestamp, 'dd.mm.yyyy tzh:tzm')
                , 'dd.mm.yyyy tzh:tzm'
              )
              - numtodsinterval( usedDayCount, 'DAY')
            )
        ) d
        on d.batch_id = b.batch_id
    where
      (usedDayCount is null or d.batch_id is not null)
    order by
      b.batch_short_name
  ;

  -- Id оператора, от имени которого выполняется операция
  operatorId integer;

  nChecked integer := 0;

  nDone integer := 0;

begin
  operatorId := pkg_Operator.getCurrentUserId();

  logger.info(
    'Начало массовой активации пакетных заданий ('
      || 'usedDayCount=' || usedDayCount
      || ') ...'
    , contextTypeShortName  => pkg_SchedulerMain.Batch_CtxTpSName
    , messageLabel          => pkg_SchedulerMain.ActivateAll_BatchMsgLabel
    , openContextFlag       => 1
  );
  begin
    for rec in curBatch loop
      nChecked := nChecked + 1;
      if rec.oracle_job_id is null then
        pkg_Scheduler.activateBatch(
          batchId       => rec.batch_id
          , operatorId  => operatorId
        );
        nDone := nDone + 1;
      else
        logger.info(
          'Пакетное задание уже было активировано: "'
          || rec.batch_name_rus || '" [' || rec.batch_short_name ||  ']'
          || ' ( batch_id=' || rec.batch_id
          || ', дата запуска '
            || to_char( rec.next_date, 'dd.mm.yyyy hh24:mi:ss')
          || ').'
        );
      end if;
    end loop;
    if nChecked = 0 then
      raise_application_error(
        pkg_Error.IllegalArgument
        , 'Не найдены пакетные задания для активации ('
          || ' usedDayCount=' || usedDayCount
          || ').'
      );
    end if;
    commit;
    logger.info(
      'Активировано пакетных заданий: ' || nDone
      , messageValue          => nDone
      , contextTypeShortName  => pkg_SchedulerMain.Batch_CtxTpSName
      , openContextFlag       => 0
    );
  exception when others then
    logger.error(
      'Ошибка при массовой активации пакетных заданий:'
        || chr(10) || logger.getErrorStack()
      , contextTypeShortName  => pkg_SchedulerMain.Batch_CtxTpSName
      , openContextFlag       => 0
    );
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при массовой активации пакетных заданий.'
        )
      , true
    );
  end;
end;
/
