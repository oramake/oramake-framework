-- script: Test/unit-test-2gigabyte.sql
-- ������������ ������ ������ file � ������ �������� 2 ����. ����.
begin
  pkg_FileTest.unitTest( fileSize => 2000000000);
end;
/
