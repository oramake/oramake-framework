--script: Do/delete.sql
--Удаляет файл или пустой каталог.
--
--Параметры:
--fromPath                    - путь к удаляемому файлу или каталогу
--

define fromPath   = "&1"



begin
  pkg_File.FileDelete(
    fromPath      => '&fromPath'
  );
end;
/



undefine fromPath
