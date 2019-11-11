-- trigger: op_operator_bi_define
-- Триггер для инициализации знчений по умолчанию при добавлении новой записи

create or replace trigger op_operator_bi_define
  before insert 
  on op_operator
  for each row
-- op_operator_bi_define
begin
  -- Определяем значение первичного ключа
  if :new.operator_id is null then        
    select 
      op_operator_seq.nextval 
    into 
      :new.operator_id 
    from 
      dual
    ;
  end if;
  
  -- Тип действия
  if :new.action_type_code is null then
    :new.action_type_code := 'CREATEOPERATOR';
  end if;

  -- Id оператора, добавившего запись
  if :new.operator_id_ins is null then
    :new.operator_id_ins :=
      coalesce( :new.change_operator_id, pkg_Operator.getCurrentUserId())
    ;
  end if;
  
  -- Определяем дату создания строки
  if :new.date_ins is null then           
    :new.date_ins := sysdate;
  end if;

  -- Определяем номер изменения.
  if :new.change_number is null then
    :new.change_number := 1;
  end if;

  -- Определяем время изменения строки.
  if :new.change_date is null then
    :new.change_date := :new.date_ins;
  end if;

  -- Оператор, изменивший строку
  if :new.change_operator_id is null then
    :new.change_operator_id := :new.operator_id_ins;
  end if;
end op_operator_bi_define;
/