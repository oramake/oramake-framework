-- script: db/install/schema/4.1.0/local/private/Common/run.sql
-- ���������� �������� ����� �� ������ 1.1.0.
--
-- �������� ���������:
--  - ����������� �������� (������� ������, TODO: �����������)
--

-- ���������� ��������� ������������ ��� ��������
@oms-set-indexTablespace.sql

@oms-run op_group_aiud_add_event.trg


