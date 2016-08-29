-- script: Test/run.sql
-- ��������� ��� �����.
--
-- ������������ ���������������:
-- refreshMethod              - ����� ���������� ( "d" ���������� ������,
--                              "m" � ������� ������������������
--                              �������������, "t" ���������� � ��������������
--                              ��������� �������)
--                              ( �� ��������� ��� �����������)
-- loggingLevelCode           - ������� ����������� ( ��-��������� WARN)

@oms-default refreshMethod ""
@oms-default loggingLevelCode WARN

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

@oms-run Test/AutoTest/api.sql
@oms-run Test/AutoTest/refresh.sql
