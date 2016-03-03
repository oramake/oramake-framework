-- script: Show/option.sql
-- ���������� ����������� ��������� ���������� ������ ( ������� ���������
-- �������� ������� � �.�.).
--
-- ���������:
-- findModuleString           - ������ ��� ������ ������ (
--                              ����� ��������� � ��������� ��� ����� �
--                              ��������� �������� ������)
--                              ( ������ ��� like ��� ����� ��������)
--

define findModuleString = "&1"



select
  t.*
from
  v_opt_option_value t
where
  upper( t.module_name) like upper( '&findModuleString')
  or upper( t.module_svn_root) like upper( '&findModuleString')
order by
  t.object_type_short_name nulls first
  , t.object_short_name nulls first
  , t.option_short_name
/



undefine findModuleString
