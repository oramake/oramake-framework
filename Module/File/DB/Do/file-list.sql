--script: Do/file-list.sql
--���������� ������ ������ ��������.
--
--���������:
--fromPath                    - ���� � ��������
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
