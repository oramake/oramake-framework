--trigger: flh_request_file_list_bi
--Стандартный триггер инициализации записи
create or replace trigger flh_request_file_list_bi
 before insert
 on flh_request_file_list
 for each row
begin
                                        --Определяем значение первичного ключа
if :new.request_file_list_id is null then
  select
    flh_request_file_list_seq.nextval
  into 
    :new.request_file_list_id
  from
    dual
  ;
end if;

end;
/
