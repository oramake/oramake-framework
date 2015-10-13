-- trigger: mod_install_result_bi_define
-- Инициализация полей таблицы <mod_install_result> при вставке записи.
create or replace trigger mod_install_result_bi_define
  before insert
  on mod_install_result
  for each row
begin
                                        --Определяем значение первичного ключа
  if :new.install_result_id is null then
    select
      mod_install_result_seq.nextval
    into :new.install_result_id
    from
      dual
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
