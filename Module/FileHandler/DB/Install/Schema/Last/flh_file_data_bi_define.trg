--trigger: flh_file_data_bi_define
--Стандартный триггер инициализации записи
create or replace trigger flh_file_data_bi_define
 before insert
 on flh_file_data
 for each row
begin
                                        --Определяем значение первичного ключа
if :new.file_data_id is null then
  select
    flh_file_data_seq.nextval
  into 
    :new.file_data_id
  from
    dual
  ;
end if;

end;
/
