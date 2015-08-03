-- trigger: cmn_type_exception_bi_define
-- Инициализация полей таблицы <cmn_type_exception> при вставке записи.

create or replace trigger cmn_type_exception_bi_define
  before insert
  on cmn_type_exception
  for each row
begin

  -- Id оператора, добавившего запись
  if :new.operator_id is null then
    :new.operator_id := pkg_Operator.GetCurrentUserId();
  end if;

  -- Определяем время создания строки
  if :new.date_ins is null then
    :new.date_ins := sysdate;
  end if;
end cmn_type_exception_bi_define;
/