-- script: Test/run.sql
-- ��������� ��� �����
--
-- ������������ ���������������:
-- loggingLevelCode           - ������� ����������� (��-��������� WARN)
-- testCaseNumber             - ����� ������������ ��������� ������
--                              (�� ��������� ��� �����������)
-- saveDataFlag               - ���� ���������� �������� ������
--                              (1 ��, 0 ��� (�� ���������))
--

@oms-default loggingLevelCode WARN
@oms-default testCaseNumber ""
@oms-default saveDataFlag ""

set feedback off

declare
  loggingLevelCode varchar2(10) := '&loggingLevelCode';
begin
  lg_logger_t.getRootLogger().setLevel(
    coalesce( loggingLevelCode, pkg_Logging.Warning_LevelCode)
  );
end;
/

set feedback on

@oms-run Test/AutoTest/load-batch.sql
@oms-run Test/AutoTest/web-api.sql
@oms-run Test/AutoTest/batch-option.sql

prompt Long tests...
@oms-run Test/AutoTest/batch-operation.sql
