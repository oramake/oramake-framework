-- script: Install/Schema/Last/Common/v_cdr_day.sql
-- SQL ��� �������� ������������� <v_cdr_day> � <v_cdr_day( UserDb)>.
--
-- ���������:
-- sourceTable                - ��� �������� �������
--

define sourceTable = "&1"



create or replace force view
  v_cdr_day
as
select
  -- SVN root: Oracle/Module/Calendar
  t.day
  , t.day_type_id
  , t.date_ins
  , t.operator_id
from
  &sourceTable t
/



-- ����������� ��� ������������� ����������� � �������� �������
comment on column v_cdr_day.day is
  '���� ���������'
/
comment on column v_cdr_day.day_type_id is
  'Id ���� ���'
/
comment on column v_cdr_day.date_ins is
  '���� ���������� ������'
/
comment on column v_cdr_day.operator_id is
  'Id ���������, ����������� ������'
/



undefine sourceTable
