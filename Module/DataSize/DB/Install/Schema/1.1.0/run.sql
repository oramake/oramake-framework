-- script: Install/Schema/1.1.0/run.sql
-- ���������� �������� ����� �� ������ 1.1.0.
--
-- �������� ���������:
--  - ���������� ����� segment_name, partition_name
--

-- ���������� ��������� ������������ ��� ��������
@oms-set-indexTablespace.sql

@oms-run dsz_segment.sql
