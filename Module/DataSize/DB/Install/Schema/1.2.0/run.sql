-- script: Install/Schema/1.2.0/run.sql
-- ���������� �������� ����� �� ������ 1.2.0.
--
-- �������� ���������:
--  - ���������� ����� segment_type � �������� <dsz_segment> � <dsz_segment_group_tmp>
--

@oms-run dsz_segment.sql
@oms-run dsz_segment_group_tmp.sql
