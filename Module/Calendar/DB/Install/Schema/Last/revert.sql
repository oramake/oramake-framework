-- script: Install/Schema/Last/revert.sql
-- �������� ��������� ������, ������ ��������� ������� �����.


-- ������

drop package pkg_Calendar
/


-- ������� �����

@oms-drop-foreign-key cdr_day
@oms-drop-foreign-key cdr_day_type


-- �������

drop table cdr_day
/
drop table cdr_day_type
/


-- ������������������

drop sequence cdr_day_type_seq
/
