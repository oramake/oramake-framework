alter index
  cdr_day_type_pk
rebuild
  tablespace &indexTablespace
/

comment on table cdr_day_type is
  '���� ���� ��������� [ SVN root: Oracle/Module/Calendar]'
/
comment on column cdr_day_type.day_type_id is
  'Id ���� ���'
/
comment on column cdr_day_type.day_type_name is
  '������������ ���� ���'
/
comment on column cdr_day_type.date_ins is
  '���� ���������� ������'
/
comment on column cdr_day_type.operator_id is
  'Id ���������, ����������� ������'
/


@oms-run create-mlog.sql cdr_day_type
