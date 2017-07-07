-- script: Test/interface-table.sql
-- ��������� �������� �������� ��������� ������� ��� ���������� ������������
-- ������ �� �������������� � ��������� �������.
-- ( �������� ������).

@reconn

declare

  outputFilePath varchar2(1000) :=
    '&outputFilePath'
  ;

begin
  pkg_ScriptUtility.generateInterfaceTempTable(
    outputFilePath => outputFilePath
    , viewName     => 'v_test_view'
  );
end;
/
