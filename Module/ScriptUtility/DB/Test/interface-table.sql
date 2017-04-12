-- script: Test/interface-table.sql
-- ��������� ������� ������������ ������� �� ��������� �������������
-- ( �������� ������).

@reconn

declare

  outputFilePath varchar2(1000) :=
    '&outputFilePath'
  ;

begin
  pkg_ScriptUtility.generateInterfaceTable(
    outputFilePath      => outputFilePath
    , objectPrefix      => 'ct'
  );
end;
/
