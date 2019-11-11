-- script: Install/Schema/3.10.0/op_group.sql
-- ��������� private ����� ������� <op_group>

prompt disable all triggers on op_group

alter table
  op_group
disable all triggers
/


prompt add new columns into op_group

alter table
  op_group
add
  (
  is_unused number(1,0) default 0
  , description varchar2(4000)
  , constraint op_group_ck_unused check (is_unused in (0,1) )
  )
/

comment on column op_group.is_unused is
  '������� �������������� ������ 1-��������������, 0������������� (������ �� ������ ���������� � ������ ����� ��� ���������� ���������� � � ����� ������)'
/
comment on column op_group.description is
  '�������� ������ �� ����� �� ���������'
/


alter table
  op_group
modify
  (
  is_unused not null
  )
/


prompt enable all triggers on op_group

alter table
  op_group
enable all triggers
/