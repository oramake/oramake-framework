-- script: Show/action.sql
-- ���������� ������������� �������� �� ��������� ������� ( �� ������
-- <v_mod_install_action>), ��� ���� ��������� ��������� 30 ������� ����
-- ������ �� ��������� �������.
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
    v_mod_install_action t
  where
    ( upper( t.module_name) like upper( '&1')
      or upper( t.svn_root) like upper( '&1')
    )
  order by
    t.install_action_id desc
  ) a
where
  ( rownum <= 30
    or a.date_ins >= add_months( trunc( sysdate), -6)
  )
order by
  a.install_action_id
/
