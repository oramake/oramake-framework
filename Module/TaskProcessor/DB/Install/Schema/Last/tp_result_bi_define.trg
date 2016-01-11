--trigger: tp_result_bi_define
--Инициализация полей таблицы <tp_result> при вставке записи.
create or replace trigger tp_result_bi_define
  before insert
  on tp_result
  for each row
begin
                                        --Оператор, создавший строку
  if :new.operator_id is null then
    :new.operator_id := pkg_Operator.GetCurrentUserId;
  end if;
                                        --Определяем время создания строки
  if :new.date_ins is null then
    :new.date_ins := sysdate;
  end if;
end;
/
