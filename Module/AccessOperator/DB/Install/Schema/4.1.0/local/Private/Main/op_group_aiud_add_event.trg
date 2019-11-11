-- trigger: op_group_aiud_add_event
-- ������� ��� ���������� ��������� �� �������

CREATE OR REPLACE TRIGGER op_group_aiud_add_event
  after delete or insert or update of
    group_id
    , group_name
    , group_name_en
    , is_unused
    , description
    , date_ins
    , operator_id
  on op_group
  for each row
declare
  -- ��������� ���������� � ��������� ���������.
  -- ���������� ��� �������
  eventType rp_event.event_type%type :=
    case when
      deleting
    then
      'D'
    when
      inserting
    then
      'I'
    when
      updating
    then
      'U'
    end
  ;

  id1 rp_event.pk1_id%type;
  id2 rp_event.pk1_id%type;

-- op_group_aiud_add_event
begin
  if deleting then
    id1 := :old.group_id;
  else
    id1 := :new.group_id;
  end if;

  insert into rp_event(
    table_name
    , event_type
    , pk1_id
    , pk2_id
  )
  values(
    'OP_GROUP'
    , eventType
    , id1
    , id2
  );
end op_group_aiud_add_event;
/
