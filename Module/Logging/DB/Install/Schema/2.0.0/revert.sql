-- script: Install/Schema/2.0.0/revert.sql
-- �������� ��������� � �������� �����, ��������� ��� ��������� ������ 2.0.0.
--

-- ���������� ��������� ������������ ��� ��������
@oms-set-indexTablespace.sql

@oms-run lg_log.revert.sql
@oms-run add-context.revert.sql
