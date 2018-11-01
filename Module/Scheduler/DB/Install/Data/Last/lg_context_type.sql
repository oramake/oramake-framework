declare

  logger lg_logger_t := lg_logger_t.getLogger(
    moduleName    => pkg_SchedulerMain.Module_Name
    , objectName  => 'Install/Data/Last/lg_context_type.sql'
  );

  nChanged integer := 0;

begin
  nChanged :=
    logger.mergeContextType(
        contextTypeShortName      => pkg_SchedulerMain.Batch_CtxTpSName
        , contextTypeName         =>
            'Пакетное задание'
        , nestedFlag              => 1
        , contextTypeDescription  =>
'Операции над пакетным заданием, в context_value_id указывается Id пакетного задания (значение поля batch_id из таблицы sch_batch), в message_label указывается вид операции:
"' || pkg_SchedulerMain.Abort_BatchMsgLabel || '" - Прерывание выполнения;
"' || pkg_SchedulerMain.Activate_BatchMsgLabel || '" - Активация;
"' || pkg_SchedulerMain.Deactivate_BatchMsgLabel || '" - Деактивация;
"' || pkg_SchedulerMain.Exec_BatchMsgLabel || '" - Выполнение;
"' || pkg_SchedulerMain.SetNextDate_BatchMsgLabel || '" - Установка даты следующего запуска;
"' || pkg_SchedulerMain.StopHandler_BatchMsgLabel || '" - Отправка команды остановки обработчика;
'
    )
    + logger.mergeContextType(
        contextTypeShortName      => pkg_SchedulerMain.Job_CtxTpSName
        , contextTypeName         =>
            'Задание'
        , nestedFlag              => 1
        , contextTypeDescription  =>
'Выполнение задания, в context_value_id указывается Id задания (значение поля job_id из таблицы sch_job)'
    )
  ;
  commit;
  dbms_output.put_line( 'changed: ' || nChanged);
end;
/
