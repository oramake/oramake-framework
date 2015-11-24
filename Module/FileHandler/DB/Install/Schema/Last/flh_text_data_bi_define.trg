--trigger: flh_text_data_bi_define
--Стандартный триггер инициализации записи
create or replace trigger flh_text_data_bi_define
 before insert
 on flh_text_data
 for each row
begin
                                        --Определяем значение первичного ключа
if :new.text_data_id is null then
  select
    flh_text_data_seq.nextval
  into 
    :new.text_data_id
  from
    dual
  ;
end if;

end;
/
