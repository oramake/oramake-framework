-- script: Test/test-batch.sql
-- ������������ ������. ���������� �����, ���������, ������� ����������
-- ������ � ������������, ����� ���������� ��� ����������.
--
-- ���������:
-- 1                          - ������ ����� ��� ������ ����� ","

define batchShortNameList=&1

begin
  pkg_SchedulerTest.testBatch(
    batchShortNameList => '&batchShortNameList'
  );
end;
/

undefine batchShortNameList
