-- script: Do/copy.sql
-- Копирует файл.
--
-- Параметры:
-- fromPath                   - путь к исходному файлу
-- toPath                     - путь для копирования
-- overwrite                  - флаг перезаписи ( 1 перезаписывать, по умолчанию
--                              без перезаписи)
--

define fromPath   = "&1"
define toPath     = "&2"
define overwrite  = "&3"



begin
  pkg_File.fileCopy(
    fromPath      => '&fromPath'
    , toPath      => '&toPath'
    , overwrite   => case when '&overwrite' = '1' then 1 else 0 end
  );
end;
/



undefine fromPath
undefine toPath
undefine overwrite
