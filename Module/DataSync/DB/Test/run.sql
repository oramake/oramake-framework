-- script: Test/run.sql
-- ��������� ��� �����.
--
-- ������������ ���������������:
-- refreshMethod              - ����� ���������� ( "d" ���������� ������,
--                              "m" � ������� ������������������
--                              �������������, "t" ���������� � ��������������
--                              ��������� �������)
--                              ( �� ��������� ��� �����������)
-- loggingLevelCode           - ������� ����������� ������
--                              (�� ��������� �� rootLoggingLevelCode ���
--                              "WARN")
-- rootLoggingLevelCode       - ������� ����������� ���� �������
--                              (�� ��������� "WARN")
-- testCaseNumber             - ����� ������������ ��������� ������
--                              (�� ��������� ��� �����������)

@oms-default refreshMethod ""
@oms-default loggingLevelCode ""
@oms-default rootLoggingLevelCode ""
@oms-default testCaseNumber ""

set feedback off

declare
  loggingLevelCode varchar2(10) := '&loggingLevelCode';
  rootLoggingLevelCode varchar2(10) := '&rootLoggingLevelCode';
begin
  lg_logger_t.getRootLogger().setLevel(
    coalesce( rootLoggingLevelCode, pkg_Logging.Warning_LevelCode)
  );
  lg_logger_t.getLogger( pkg_DataSync.Module_Name).setLevel(
    coalesce(
      loggingLevelCode
      , rootLoggingLevelCode
      , pkg_Logging.Warning_LevelCode
    )
  );
end;
/

set feedback on

@oms-run Test/AutoTest/api.sql
@oms-run Test/AutoTest/refresh.sql
@oms-run Test/AutoTest/append-data.sql
