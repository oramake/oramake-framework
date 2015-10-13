-- trigger: mod_install_type_bi_define
-- Инициализация полей таблицы <mod_install_type> при вставке записи.
create or replace trigger mod_install_type_bi_define
  before insert
  on mod_install_type
  for each row
begin
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
