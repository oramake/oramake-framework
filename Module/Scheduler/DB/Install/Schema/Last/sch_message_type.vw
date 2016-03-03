-- view: sch_message_type
-- ���� ��������� ���� ( �������������, ��������� ������ �������
-- sch_message_type ��� ��������� ������ Loggiing ������ 1.4.0 ��� �����������
-- ������������� � ������� Scheduler).
--
create or replace view
  sch_message_type
as
select
  t.message_type_code
  , t.message_type_name as message_type_name_rus
  , t.message_type_name_en as message_type_name_eng
  , t.date_ins
from
  lg_message_type t
/

comment on table sch_message_type is
  '���� ��������� ���� ( �������������, ��������� ������ ������� sch_message_type ��� ��������� ������ Loggiing ������ 1.4.0 ��� ����������� ������������� � ������� Scheduler)'
/
