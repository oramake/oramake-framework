-- script: Install/Schema/Last/UserDb/revert.sql
-- �������� ��������� ������, ������ ��������� ������� ����� �
-- ���������������� ��.
--

-- �������������

drop view v_cdr_day
/
drop view v_cdr_day_type
/


-- ����������������� �������������

drop materialized view mv_cdr_day
/
drop materialized view mv_cdr_day_type
/
