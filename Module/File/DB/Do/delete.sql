--script: Do/delete.sql
--������� ���� ��� ������ �������.
--
--���������:
--fromPath                    - ���� � ���������� ����� ��� ��������
--

define fromPath   = "&1"



begin
  pkg_File.FileDelete(
    fromPath      => '&fromPath'
  );
end;
/



undefine fromPath
