-- script: Test/run.sql
-- ��������� ������������ ������.
-- ������������ ����������� c ������� ��������� <pkg_FileTest.unitTest> ���
-- ������ �������� � 1 MB.
--
-- ������������ ���������������:
-- loggingLevelCode           - ������� ����������� ( ��-��������� DEBUG)
-- httpInternetFileTest       - ���� ������������ ���������� �������� �� HTTP
--                              c ������� � �������� ( 1 ��, 0 ��� ( ��
--                              ���������))
--

@oms-default loggingLevelCode DEBUG
@oms-default httpInternetFileTest 0

set feedback off

exec lg_logger_t.getRootLogger().setLevel( '&loggingLevelCode');

set feedback on



@oms-run Test/AutoTest/unit.sql
@oms-run Test/AutoTest/fs-operation.sql
@oms-run Test/AutoTest/http-operation.sql
