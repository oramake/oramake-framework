-- script: Install/Schema/2.3.0/revert.sql
-- ������� ���������� �������� ����� �� ������ 2.3.0.
--
-- �������� ���������:
--  - �� ������� <ml_message> ������� ���� retry_send_count
--

-- ���������� ��������� ������������ ��� ��������
@oms-set-indexTablespace.sql

alter table 
  ml_message
drop column
  retry_send_count
;

