-- script: Do/deactivate-all.sql
-- Деактивирует все активные батчи и записывает сообщение об остановке в лог.
--
-- Замечания:
--  - в случае ошибки commit не выполняется и ни один пакет не деактивируется;
--  - в случае ошибки при получении Id текущего зарегистрированного оператора
--    деактивация выполняется от имени оператора с operator_id=1;
--

declare

  -- Логер скрипта
  logger lg_logger_t := lg_logger_t.getLogger(
    moduleName    => pkg_Scheduler.Module_Name
    , objectName  => 'Do/deactivate-all.sql'
  );

  cursor curBatch is
    select
      b.batch_id
      , b.batch_short_name
    from
      sch_batch b
    where
      oracle_job_id is not null
    order by
      b.batch_short_name
  ;

  -- Id оператора, от имени которого выполняется операция
  operatorId integer;

  nDone integer := 0;

begin
  begin
    operatorId := pkg_Operator.getCurrentUserId();
  exception when others then
    operatorId := 1;
    dbms_output.put_line(
      'Use default operator_id: ' || operatorId
    );
  end;

  logger.info(
    'Deactivate all batches: ...'
    , contextTypeShortName  => pkg_SchedulerMain.Batch_CtxTpSName
    , messageLabel          => pkg_SchedulerMain.DeactivateAll_BatchMsgLabel
    , openContextFlag       => 1
  );
  begin

    for rec in curBatch loop
      pkg_Scheduler.deactivateBatch(
        batchId       => rec.batch_id
        , operatorId  => operatorId
      );
      nDone := nDone + 1;
    end loop;

    commit;

    logger.info(
      'Batches deactivated: ' || nDone
      , messageValue          => nDone
      , contextTypeShortName  => pkg_SchedulerMain.Batch_CtxTpSName
      , openContextFlag       => 0
    );
  exception when others then
    logger.error(
      'Error on deactivate all batches:' || chr(10) || logger.getErrorStack()
      , contextTypeShortName  => pkg_SchedulerMain.Batch_CtxTpSName
      , openContextFlag       => 0
    );
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Error on deactivate all batches.'
        )
      , true
    );
  end;
end;
/
