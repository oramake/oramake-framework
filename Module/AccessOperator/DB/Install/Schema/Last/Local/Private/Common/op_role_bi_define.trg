-- trigger: op_role_bi_define
-- Инициализация полей таблицы <op_role> при добавлении записи.

create or replace trigger op_role_bi_define
  before insert
  on op_role
  for each row
-- op_role_bi_define
begin
  -- Определяем значение первичного ключа
  if :new.role_id is null then
    select
      op_role_seq.nextval
    into
      :new.role_id
    from
      dual
    ;
  end if;

  -- Id оператора, добавившего запись
  if :new.operator_id is null then
    :new.operator_id :=
      coalesce( :new.change_operator_id, pkg_Operator.getCurrentUserId())
    ;
  end if;

  -- Определяем дату добавления записи
  if :new.date_ins is null then
    :new.date_ins := sysdate;
  end if;

  -- Определяем номер изменения
  if :new.change_number is null then
    :new.change_number := 1;
  end if;

  -- Определяем время изменения строки
  if :new.change_date is null then
    :new.change_date := :new.date_ins;
  end if;

  -- Оператор, изменивший строку
  if :new.change_operator_id is null then
    :new.change_operator_id := :new.operator_id;
  end if;
end op_role_bi_define;
/