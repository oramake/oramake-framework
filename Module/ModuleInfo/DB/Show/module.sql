-- script: Show/module.sql
-- ���������� ������������� ������ ( ����������� ������ ������ �������� �����
-- �������� ����� �������, �� ������ <v_mod_install_module>).
--
-- ���������:
-- modulePattern              - ������ ( ������ ��� like, �������� ������
--                              ��������������� ��� ������ ( module_name)
--                              ��� ���� � ��������� �������� ������
--                              ( svn_root) ��� ����� ��������)
--

@@cdef.sql

select
  t.*
from
  v_mod_install_module t
where
  ( upper( t.module_name) like upper( '&1')
    or upper( t.svn_root) like upper( '&1')
  )
order by
  t.install_result_id
/
