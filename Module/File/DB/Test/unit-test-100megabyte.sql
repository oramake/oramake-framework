-- script: Test/unit-test-100megabyte.sql
-- ������������ ������ ������ file � ������ �������� 100 ���. ����.
begin
  pkg_FileTest.unitTest( fileSize => 100000000);
end;
/
