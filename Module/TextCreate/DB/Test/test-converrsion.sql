-- script: Test/test-converrsion.sql
-- ���� ����������� BLOB � CLOB, � �������.
--
begin
  pkg_TextCreateTest.testConversion( '����������� � clob');
end;
/
