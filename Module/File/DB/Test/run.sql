-- script: Test/run.sql
-- ��������� ������������ ������.
-- ������������ ����������� c ������� ��������� <pkg_FileTest.unitTest> ���
-- ������ �������� � 1 MB.
--
-- ������������ ���������������:
-- testDirectory              - ���������� ��� ������������
-- loggingLevelCode           - ������� ����������� ( ��-��������� DEBUG)
-- httpInternetFileTest       - ���� ������������ ���������� �������� �� HTTP
--                              c ������� � �������� ( 1 ��, 0 ��� ( ��
--                              ���������))
--

@oms-default testDirectory ""
@oms-default loggingLevelCode DEBUG
@oms-default httpInternetFileTest 0

set feedback off

exec lg_logger_t.getRootLogger().setLevel( '&loggingLevelCode');

set feedback on


begin
  if '&testDirectory' is not null then
    pkg_Common.outputMessage( 'setting test directory');
    pkg_FileTest.setTestDirectory( '&testDirectory');
  end if;
end;
/

@oms-run Test/AutoTest/unit.sql
@oms-run Test/AutoTest/fs-operation.sql
@oms-run Test/AutoTest/http-operation.sql
