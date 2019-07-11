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
            '�������'
        , nestedFlag              => 1
        , contextTypeDescription  =>
'�������� ��� ��������, � context_value_id ����������� Id ������� (�������� ���� task_id �� ������� tp_task), � message_label ����������� ��� ��������:
"' || pkg_TaskProcessorBase.Create_TaskMsgLabel || '" - ��������;
"' || pkg_TaskProcessorBase.Exec_TaskMsgLabel || '" - ����������;
"' || pkg_TaskProcessorBase.Start_TaskMsgLabel || '" - ���������� �� ����������;
"' || pkg_TaskProcessorBase.Stop_TaskMsgLabel || '" - ������ � ����������;
"' || pkg_TaskProcessorBase.Update_TaskMsgLabel || '" - ���������� ����������;
'
    )
    + logger.mergeContextType(
        contextTypeShortName      => pkg_TaskProcessor.Line_CtxTpName
        , contextTypeName         =>
            '������ ��������������� �����'
        , nestedFlag              => 1
        , contextTypeDescription  =>
'��������� ������ �����, � context_value_id ����������� ���������� ����� ������ (������� � 1)'
    )
  ;
  commit;
  dbms_output.put_line( 'changed: ' || nChanged);
end;
/
