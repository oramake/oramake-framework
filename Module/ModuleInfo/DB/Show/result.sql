-- script: Show/result.sql
-- ���������� ���������� �� ����������� ���� ������������� ��������� ( ��
-- ������ <v_mod_install_result>), ��� ���� ��������� ��������� 30 �������
-- ���� ������ �� ��������� �������.
--
-- ���������:
-- modulePattern              - ������ ( ������ ��� like, �������� ������
--                              ��������������� ��� ������ ( module_name)
--                              ��� ���� � ��������� �������� ������
--                              ( svn_root) ��� ����� ��������)
--

@@cdef.sql

select
  a.*
from
  (
  select
    t.*
  from
    v_mod_install_result t
  where
    ( upper( t.module_name) like upper( '&1')
      or upper( t.svn_root) like upper( '&1')
    )
  order by
    t.install_result_id desc
  ) a
where
  ( rownum <= 30
    or a.install_date >= add_months( trunc( sysdate), -6)
  )
order by
  a.install_result_id
/
