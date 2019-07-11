declare

  logger lg_logger_t := lg_logger_t.getLogger(
    moduleName    => pkg_TaskProcessorBase.Module_Name
    , objectName  => 'Install/Data/Last/lg_context_type.sql'
  );

  nChanged integer := 0;

begin
  nChanged :=
    logger.mergeContextType(
        contextTypeShortName      => pkg_TaskProcessorBase.Task_CtxTpSName
        , contextTypeName         =>
            'Задание'
        , nestedFlag              => 1
        , contextTypeDescription  =>
'Операции над заданием, в context_value_id указывается Id задания (значение поля task_id из таблицы tp_task), в message_label указывается вид операции:
"' || pkg_TaskProcessorBase.Create_TaskMsgLabel || '" - Создание;
"' || pkg_TaskProcessorBase.Exec_TaskMsgLabel || '" - Выполнение;
"' || pkg_TaskProcessorBase.Start_TaskMsgLabel || '" - Постановка на выполнение;
"' || pkg_TaskProcessorBase.Stop_TaskMsgLabel || '" - Снятие с выполнения;
"' || pkg_TaskProcessorBase.Update_TaskMsgLabel || '" - Обновление параметров;
'
    )
    + logger.mergeContextType(
        contextTypeShortName      => pkg_TaskProcessor.Line_CtxTpName
        , contextTypeName         =>
            'Строка обрабатываемого файла'
        , nestedFlag              => 1
        , contextTypeDescription  =>
'Обработка строки файла, в context_value_id указывается порядковый номер строки (начиная с 1)'
    )
  ;
  commit;
  dbms_output.put_line( 'changed: ' || nChanged);
end;
/
