-- script: Install/Schema/2.0.0/run.sql
-- ���������� �������� ����� �� ������ 2.0.0.
--
-- �������� ���������:
--  - � ������� <lg_log> ��������� ���� sessionid;
--

-- ���������� ��������� ������������ ��� ��������
@oms-set-indexTablespace.sql

@oms-run drop-lg_log_ai_save_parent.sql

@oms-run add-sessionid.sql

