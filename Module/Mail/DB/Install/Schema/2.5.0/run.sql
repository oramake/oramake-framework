-- script: Install/Schema/2.5.0/run.sql
-- ���������� �������� ����� �� ������ 2.5.0.
--
-- �������� ���������:
--   ��������� ������� ����� <ml_message>: 
--   sender_address varchar2(100), recipient_address varchar2(100). 

-- ���������� ��������� ������������ ��� ��������
@oms-set-indexTablespace.sql

@oms-run ml_message.sql
