--script: Do/subdir-list.sql
--���������� ������ ������������ ��������.
--
--���������:
--fromPath                    - ���� � ��������
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
