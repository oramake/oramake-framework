-- script: Test/interface-table.sql
-- Генерация скриптов создания временных таблицы для обновления интерфейсных
-- таблиц по представлениям с исходными данными.
-- ( тестовый скрипт).

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
