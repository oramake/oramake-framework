-- script: Test/interface-table.sql
-- ��������� �������� �������� ��������� ������� ��� ���������� ������������
-- ������ �� �������������� � ��������� �������.
-- ( �������� ������).

@reconn

declare

  outputFilePath varchar2(1000) :=
    '\\test-disk\files\tmp\ScriptUtility\InterfaceTable'
  ;

begin
  pkg_ScriptUtility.generateInterfaceTempTable(
    outputFilePath => outputFilePath
    , viewName     => 'v_test_view'
  );
end;
/
