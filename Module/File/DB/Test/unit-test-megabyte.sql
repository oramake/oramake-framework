-- script: Test/unit-test-megabyte.sql
-- ������������ ������ ������ file � ������ �������� 1 ��� ����.
begin
  pkg_FileTest.unitTest( fileSize => 1000000);
end;
/
