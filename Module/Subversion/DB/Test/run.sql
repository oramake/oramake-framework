-- script: Test/run.sql
-- ���������� ���� ������.
--
begin
  pkg_SubversionTest.testGetList();
end;
/

select * from tmp_file_name
/

begin
  pkg_SubversionTest.testGetFile();
end;
/
