-- script: Install/Schema/Last/revert.sql
-- �������� ��������� ������, ������ ��������� ������� �����.


-- ������

drop package pkg_CalendarEdit
/


-- �������������

drop view v_cdr_day
/
drop view v_cdr_day_type
/


-- ������� �����

@oms-drop-foreign-key cdr_day
@oms-drop-foreign-key cdr_day_type


-- �������

drop table cdr_day
/
drop table cdr_day_type
/
