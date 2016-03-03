-- script: Install/Grant/Last/run.sql
-- ������ ����������� ����� �� ������������� ������.
--
-- ���������:
-- toUserName                  - ��� ������������, �������� �������� �����
--
-- ���������:
--  - ������ ����������� ��� �������������, �������� ����������� ������� ������
--   ;
--

define toUserName = "&1"



grant
  execute
on
  pkg_Scheduler
to
  &toUserName
/

create or replace synonym
  &toUserName..pkg_Scheduler
for
  pkg_Scheduler
/


grant
  execute
on
  sch_batch_option_t
to
  &toUserName
/
create or replace synonym
  &toUserName..sch_batch_option_t
for
  sch_batch_option_t
/


grant
  select
on
  v_sch_batch
to
  &toUserName
/
create or replace synonym
  &toUserName..v_sch_batch
for
  v_sch_batch
/


undefine toUserName
