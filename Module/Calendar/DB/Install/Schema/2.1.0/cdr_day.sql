alter index
  cdr_day_pk
rebuild
  tablespace &indexTablespace
/

alter table
  cdr_day
add (
  constraint cdr_day_ck_day check
  ( day = trunc( day))
)
/



comment on table cdr_day is
  '��� ��������� [ SVN root: Oracle/Module/Calendar]'
/
comment on column cdr_day.day is
  '���� ���������'
/
comment on column cdr_day.day_type_id is
  'Id ���� ���'
/
comment on column cdr_day.date_ins is
  '���� ���������� ������'
/
comment on column cdr_day.operator_id is
  'Id ���������, ����������� ������'
/


@oms-run create-mlog.sql cdr_day
