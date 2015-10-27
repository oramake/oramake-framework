-- script: Do/check-exists.sql
-- ��������� �������� ������� ����� ��� ��������.
--
-- ���������:
-- fromPath                   - ���� � ����� ��� ��������
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
