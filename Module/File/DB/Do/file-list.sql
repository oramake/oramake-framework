--script: Do/file-list.sql
--Показывает список файлов каталога.
--
--Параметры:
--fromPath                    - путь к каталогу
--

define fromPath = "&1"

begin
  pkg_File.FileList( '&fromPath');
end;
/

select
  *
from
  tmp_file_name fn
order by
  1
/

undefine fromPath
