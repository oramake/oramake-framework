-- script: Test/run.sql
-- ��������� ��� �����.
--
-- ������������ ���������������:
-- loggingLevelCode           - ������� ����������� ( ��-��������� WARN)
-- testCaseNumber             - ����� ������������ ��������� ������
--                              ( �� ��������� ��� �����������)
--

@oms-default loggingLevelCode WARN
@oms-default testCaseNumber ""

set feedback off

declare
  loggingLevelCode varchar2(10) := '&loggingLevelCode';
begin
  lg_logger_t.getRootLogger().setLevel( pkg_Logging.Warning_LevelCode);
  lg_logger_t.getLogger( pkg_MailBase.Module_Name).setLevel(
    coalesce( loggingLevelCode, pkg_Logging.Warning_LevelCode)
  );
end;
/

set feedback on

@oms-run Test/AutoTest/email-validation.sql
@oms-run Test/AutoTest/send-mail.sql
@oms-run Test/AutoTest/send-message.sql
@oms-run Test/AutoTest/send-html-message.sql
@oms-run Test/AutoTest/fetch-message.sql
