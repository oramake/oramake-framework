--script: Do/subdir-list.sql
--Показывает список подкаталогов каталога.
--
--Параметры:
--fromPath                    - путь к каталогу
--

define fromPath = "&1"

begin
  dbms_output.put_line( 'found: ' || pkg_File.SubdirList( '&fromPath'));
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
