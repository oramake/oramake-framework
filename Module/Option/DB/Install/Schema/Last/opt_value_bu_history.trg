-- trigger: opt_value_bu_history
-- При изменении записи в <opt_value> добавляет историческую запись со
-- старыми данными в <opt_value_history>.
create or replace trigger opt_value_bu_history
  before update
  on opt_value
  for each row
declare

  -- Старые данные в виде записи
  hs opt_value_history%rowtype;

begin

  -- Проверка неизменности уникального ключа
  if :new.option_id <> :old.option_id
      or coalesce(
          :new.prod_value_flag != :old.prod_value_flag
          , coalesce( :new.prod_value_flag, :old.prod_value_flag)
            is not null
        )
      or coalesce(
          :new.instance_name != :old.instance_name
          , coalesce( :new.instance_name, :old.instance_name)
            is not null
        )
      or coalesce(
          :new.used_operator_id != :old.used_operator_id
          , coalesce( :new.used_operator_id, :old.used_operator_id)
            is not null
        )
      then
    raise_application_error(
      pkg_Error.ProcessError
      , 'Запрещено изменять значения полей уникального ключа'
        || ' ( option_id, prod_value_flag, instance_name, used_operator_id).'
    );
  end if;

  -- Используем текущего оператора если Id оператора не был задан явно
  if not updating( 'change_operator_id') or :new.change_operator_id is null
      then
    :new.change_operator_id := pkg_Operator.getCurrentUserId();
  end if;

  -- Сохраняем время обновления данных
  :new.change_date := sysdate;

  -- Увеличиваем счетчик обновлений
  :new.change_number := :old.change_number + 1;

  -- Заполняем поля с данными
  hs.value_id                       := :old.value_id;
  hs.option_id                      := :old.option_id;
  hs.prod_value_flag                := :old.prod_value_flag;
  hs.instance_name                  := :old.instance_name;
  hs.used_operator_id               := :old.used_operator_id;
  hs.value_type_code                := :old.value_type_code;
  hs.list_separator                 := :old.list_separator;
  hs.encryption_flag                := :old.encryption_flag;
  hs.storage_value_type_code        := :old.storage_value_type_code;
  hs.date_value                     := :old.date_value;
  hs.number_value                   := :old.number_value;
  hs.string_value                   := :old.string_value;

  -- Устанавливаем служебные поля
  hs.deleted                        := :old.deleted;
  hs.change_number                  := :old.change_number;
  hs.change_date                    := :old.change_date;
  hs.change_operator_id             := :old.change_operator_id;
  hs.base_date_ins                  := :old.date_ins;
  hs.base_operator_id               := :old.operator_id;
  hs.date_ins                       := :new.change_date;
  hs.operator_id                    := :new.change_operator_id;

  -- Сохраняем старые данные
  select
    opt_value_history_seq.nextval
  into
    hs.value_history_id
  from
    dual
  ;
  insert into opt_value_history values hs;
end;
/
