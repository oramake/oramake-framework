-- trigger: sch_module_role_privilege_bi_d
-- Инициализация полей таблицы <sch_module_role_privilege> при вставке записи.
create or replace trigger sch_module_role_privilege_bi_d
  before insert
  on sch_module_role_privilege
  for each row
begin

  -- Определяем значение первичного ключа
  if :new.module_role_privilege_id is null then
    select
      sch_module_role_privilege_seq.nextval
    into :new.module_role_privilege_id
    from
      dual
    ;
  end if;

  -- Id оператора, добавившего запись
  if :new.operator_id is null then
    :new.operator_id := pkg_Operator.getCurrentUserId();
  end if;

  -- Определяем дату добавления записи
  if :new.date_ins is null then
    :new.date_ins := sysdate;
  end if;
end;
/
