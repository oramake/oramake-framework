-- script: Test/unit-test-10megabyte.sql
-- ������������ ������ ������ file � ������ �������� 10 ���. ����.
begin
  pkg_FileTest.unitTest( fileSize => 10000000);
end;
/
