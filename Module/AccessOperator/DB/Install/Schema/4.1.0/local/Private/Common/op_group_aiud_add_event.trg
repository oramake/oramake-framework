-- trigger: op_group_aiud_add_event
-- Триггер для репликации изменений по группам

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
  -- Сохраняет информацию о сделанном изменении.
  -- Определяем тип события
  eventType varchar2(1) :=
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

  id1 integer;
  id2 integer;
  rpEventExists integer;

-- op_group_aiud_add_event
begin
  if deleting then
    id1 := :old.group_id;
  else
    id1 := :new.group_id;
  end if;

  select
    count(1)
  into
    rpEventExists
  from
    user_tables
  where
    table_name = 'RP_EVENT'
  ;
  -- workaround for the case of replication
  if rpEventExists = 1 then
    execute immediate
    '
    insert into rp_event(
      table_name
      , event_type
      , pk1_id
      , pk2_id
    )
    values(
      ''OP_GROUP''
      , :eventType
      , :id1
      , :id2
    )'
    using
      eventType
    , id1
    , id2
    ;
  end if;
end op_group_aiud_add_event;
/
