-- script: Install/Schema/3.5.0/Local/Private/Main/revert.sql
-- ������ ��������� �������� ������ 3.5.0 ������

-- �������� ������
drop table
  op_load_lock_form_sources_tmp
/

-- �������� �������������������
drop sequence
  op_login_attempt_group_seq
/
