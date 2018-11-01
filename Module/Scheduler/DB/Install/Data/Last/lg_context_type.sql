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
            '�������� �������'
        , nestedFlag              => 1
        , contextTypeDescription  =>
'�������� ��� �������� ��������, � context_value_id ����������� Id ��������� ������� (�������� ���� batch_id �� ������� sch_batch), � message_label ����������� ��� ��������:
"' || pkg_SchedulerMain.Abort_BatchMsgLabel || '" - ���������� ����������;
"' || pkg_SchedulerMain.Activate_BatchMsgLabel || '" - ���������;
"' || pkg_SchedulerMain.Deactivate_BatchMsgLabel || '" - �����������;
"' || pkg_SchedulerMain.Exec_BatchMsgLabel || '" - ����������;
"' || pkg_SchedulerMain.SetNextDate_BatchMsgLabel || '" - ��������� ���� ���������� �������;
"' || pkg_SchedulerMain.StopHandler_BatchMsgLabel || '" - �������� ������� ��������� �����������;
'
    )
    + logger.mergeContextType(
        contextTypeShortName      => pkg_SchedulerMain.Job_CtxTpSName
        , contextTypeName         =>
            '�������'
        , nestedFlag              => 1
        , contextTypeDescription  =>
'���������� �������, � context_value_id ����������� Id ������� (�������� ���� job_id �� ������� sch_job)'
    )
  ;
  commit;
  dbms_output.put_line( 'changed: ' || nChanged);
end;
/
