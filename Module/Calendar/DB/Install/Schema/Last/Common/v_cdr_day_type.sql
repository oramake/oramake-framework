-- script: Install/Schema/Last/Common/v_cdr_day_type.sql
-- SQL ��� �������� ������������� <v_cdr_day_type> � <v_cdr_day_type( UserDb)>.
--
-- ���������:
-- sourceTable                - ��� �������� �������
--

define sourceTable = "&1"



create or replace force view
  v_cdr_day_type
as
select
  -- SVN root: Oracle/Module/Calendar
  t.day_type_id
  , t.day_type_name
  , t.date_ins
  , t.operator_id
from
  &sourceTable t
/



-- ����������� ��� ������������� ����������� � �������� �������
comment on column v_cdr_day_type.day_type_id is
  'Id ���� ���'
/
comment on column v_cdr_day_type.day_type_name is
  '������������ ���� ���'
/
comment on column v_cdr_day_type.date_ins is
  '���� ���������� ������'
/
comment on column v_cdr_day_type.operator_id is
  'Id ���������, ����������� ������'
/



undefine sourceTable
