-- script: Install/Schema/2.1.0/run.sql
-- ���������� �������� ����� �� ������ 2.1.0.
--
-- �������� ���������:
--  - ��������� ������� ��� ������ <cdr_day> � <cdr_day_type> � ������
--    �� ����������;
--

-- ���������� ��������� ������������ ��� ��������
@oms-set-indexTablespace.sql

@oms-run drop-old-objects.sql

@oms-run cdr_day_type.sql
@oms-run cdr_day.sql
