-- trigger: op_operator_bu_history
-- Триггер для инициализации значений при обновлении записи

create or replace trigger op_operator_bu_history
  before update of
    operator_id
    , login
    , password
    , date_begin
    , date_finish
    , date_ins
    , operator_id_ins
    , change_password
    , operator_name
    , operator_name_en
    , operator_comment
    , login_attempt_group_id
    , action_type_code
    , computer_name
    , ip_address
    , change_number
    , change_date
    , change_operator_id
  on op_operator
  referencing old as old new as new
  for each row    
-- op_operator_bu_history
begin
  -- Используем текущего оператора если
  -- Id оператора не было задано явно
  if not updating( 'change_operator_id') or :new.change_operator_id is null then
    :new.change_operator_id := pkg_Operator.getCurrentUserId();
  end if;

  -- Сохраняем время обновления данных
  :new.change_date                := sysdate;

  -- Увеличиваем счетчик обновлений
  :new.change_number              := :old.change_number + 1;
  
  -- Сохраняем пароль, если он изменился  
  if :new.password != :old.password then
    :new.action_type_code := pkg_AccessOperator.ChangePassword_ActTpCd;
    
    insert into op_password_hist(
      operator_id
      , password
    )
    values( 
      :new.operator_id
      , :old.password
    );
  end if;

  -- Если была блокировка - устанавливаем соответствующий тип
  if :old.date_finish is null
    and :new.date_finish is not null
    and not updating( 'action_type_code')
  then
    :new.action_type_code := pkg_AccessOperator.AutoBlockOperator_ActTpCd;  
  end if;
end op_operator_bu_history;
/