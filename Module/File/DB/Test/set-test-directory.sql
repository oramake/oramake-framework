-- script: Test/set-test-directory.sql
-- ������������� ���������� ��� ������������ ������.
--
-- ��������, ����� ���������� ���������� ��� ftp � ��������
-- unit-test_megabyte.sql;
--
begin
  pkg_FileTest.setTestDirectory( '&1');
end;
/

