-- script: Test/get-zip.sql
-- Создание zip-архива ( тест).
--

@reconn

declare

  -- Путь для выгрузки файла
  fileDir varchar2(1024) := '\\rusfinance.ru\files\work\Test\tmp';

  -- Имя файла с русскими буквами
  fileName varchar2(30) := 'Опись.txt';

  filePath varchar2(1024);

begin
  pkg_TextCreate.newText();
  pkg_TextCreate.append( 'Тест file');

  filePath := pkg_File.getFilePath(
    fileDir
    , 'textCreate-' || to_char( sysdate, 'yyyymmdd_hh24miss') || '.zip'
  );
  pkg_File.unloadBlobToFile(
    binaryData  => pkg_TextCreate.getZip( fileName)
    , toPath    => filePath
  );
  dbms_output.put_line(
    'unloaded: ' || filePath
  );
end;
/
