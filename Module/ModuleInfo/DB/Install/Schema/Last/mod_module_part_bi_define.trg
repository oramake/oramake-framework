-- trigger: mod_module_part_bi_define
-- Инициализация полей таблицы <mod_module_part> при вставке записи.
create or replace trigger mod_module_part_bi_define
  before insert
  on mod_module_part
  for each row
begin
                                        --Определяем значение первичного ключа
  if :new.module_part_id is null then
    select
      mod_module_part_seq.nextval
    into :new.module_part_id
    from
      dual
    ;
  end if;
                                        --Часть с номером 1 считается основной
  if :new.is_main_part is null then
    :new.is_main_part :=
      case :new.part_number
        when 1 then 1
        else 0
      end
    ;
  end if;
                                        --Id оператора, добавившего запись
  if :new.operator_id is null then
    :new.operator_id := pkg_ModuleInfoInternal.getCurrentOperatorId();
  end if;
                                        --Определяем дату добавления записи
  if :new.date_ins is null then           
    :new.date_ins := sysdate;
  end if;
end;
/
