-- view: v_cmn_case_exception
-- ������������� ��� ����������� ���������� ������ ������� <cmn_case_exception>

create or replace view v_cmn_case_exception
as
select
  -- SVN root: Oracle/Module/Common
  exception_case_id
  , native_case_name
  , genetive_case_name
  , dative_case_name
  , accusative_case_name
  , ablative_case_name
  , preposition_case_name
  , sex_code
  , type_exception_code
  , date_ins
  , operator_id
from
  cmn_case_exception t
where
  t.deleted = 0
/

comment on table v_cmn_case_exception is
  '������������� ��� ����������� ���������� ������ ����������� ���������� � ���������� �� ������� �������, ���� � ������� [SVN root: Oracle/Module/Common]'
/
comment on column v_cmn_case_exception.exception_case_id is
  '���������� ������������� ������'
/
comment on column v_cmn_case_exception.native_case_name is
  '������ ���������� � ������������ ������'
/
comment on column v_cmn_case_exception.genetive_case_name is
  '������ ���������� � ����������� ������'
/
comment on column v_cmn_case_exception.dative_case_name is
  '������ ���������� � ��������� ������'
/
comment on column v_cmn_case_exception.accusative_case_name is
  '������ ���������� � ����������� ������'
/
comment on column v_cmn_case_exception.ablative_case_name is
  '������ ���������� � ������������ ������'
/
comment on column v_cmn_case_exception.preposition_case_name is
  '������ ���������� � ���������� ������'
/
comment on column v_cmn_case_exception.sex_code is
  '��� M � �������, F - �������'
/
comment on column v_cmn_case_exception.type_exception_code is
  '��� ����������'
/
comment on column v_cmn_case_exception.date_ins is
  '���� ���������� ������'
/
comment on column v_cmn_case_exception.operator_id is
  '������������� ���������, ����������� ������'
/