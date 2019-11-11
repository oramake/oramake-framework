-- trigger: op_group_role_bu_history
-- Триггер для инифиализации значений при изменении записи в <op_group_role>.

create or replace trigger op_group_role_bu_history
  before update
  on op_group_role
  for each row
-- op_group_role_bu_history
begin
  -- Используем текущего оператора если Id оператора не был задан явно
  if not updating( 'change_operator_id') or :new.change_operator_id is null
      then
    :new.change_operator_id := pkg_Operator.getCurrentUserId();
  end if;

  -- Сохраняем время обновления данных
  :new.change_date := sysdate;

  -- Увеличиваем счетчик обновлений
  :new.change_number := :old.change_number + 1;
end op_group_role_bu_history;
/