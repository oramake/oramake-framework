-- script: Do/check-exists.sql
-- Выполняет проверку наличия файла или каталога.
--
-- Параметры:
-- fromPath                   - путь к файлу или каталогу
--

define fromPath   = "&1"



begin
  dbms_output.put_line(
    case when
      pkg_File.checkExists(
        fromPath      => '&fromPath'
      )
    then
      'exists'
    else
      'not exists'
    end
    || ': &fromPath'
  );
end;
/



undefine fromPath
