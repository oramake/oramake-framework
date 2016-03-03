-- trigger: opt_object_type_bi_define
-- »нициализаци€ полей таблицы <opt_object_type> при вставке записи.
create or replace trigger opt_object_type_bi_define
  before insert
  on opt_object_type
  for each row
begin

  -- ќпредел€ем значение первичного ключа
  if :new.object_type_id is null then
    select
      opt_object_type_seq.nextval
    into :new.object_type_id
    from
      dual
    ;
  end if;

  -- «апись действующа€ по умолчанию
  if :new.deleted is null then
    :new.deleted := 0;
  end if;

  -- Id оператора, добавившего запись
  if :new.operator_id is null then
    :new.operator_id := pkg_Operator.getCurrentUserId();
  end if;

  -- ќпредел€ем дату добавлени€ записи
  if :new.date_ins is null then
    :new.date_ins := sysdate;
  end if;
end;
/
