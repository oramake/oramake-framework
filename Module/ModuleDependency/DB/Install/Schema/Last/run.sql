-- script: Install/Schema/Last/run.sql
-- ��������� ��������� ��������� ������ �������� �����.

-- ������������� ��������� ������������ ��� ��������
@oms-set-indexTablespace.sql

-- �������

@oms-run md_module_dependency.tab
@oms-run md_object_dependency.tab
@oms-run md_object_dependency_tmp.tab