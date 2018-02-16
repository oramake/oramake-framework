--trigger: tp_task_bi_define
--Инициализация полей таблицы <tp_task> при вставке записи.
create or replace trigger tp_task_bi_define
  before insert
  on tp_task
  for each row
begin
                                        --Заполняем Id записи
  if :new.task_id is null then
    select
      tp_task_seq.nextval
    into :new.task_id
    from
      dual
    ;
  end if;
                                        --Оператор, создавший строку
  if :new.operator_id is null then
    :new.operator_id := pkg_Operator.GetCurrentUserId;
  end if;
                                        --Определяем время создания строки
  if :new.date_ins is null then
    :new.date_ins := sysdate;
  end if;
                                        --Оператор, выполняющий операцию
  if :new.manage_operator_id is null then
    :new.manage_operator_id := :new.operator_id;
  end if;
                                        --Определяем время операции
  if :new.manage_date is null then
    :new.manage_date := :new.date_ins;
  end if;
end;
/
