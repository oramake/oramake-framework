-- script: Install/Schema/Last/run.sql
-- ��������� ��������� ��������� ������ �������� �����.

-- ������������� ��������� ������������ ��� ��������
@oms-set-indexTablespace.sql

-- �������

@oms-run Install/Schema/Last/md_object_dependency_tmp.tab
