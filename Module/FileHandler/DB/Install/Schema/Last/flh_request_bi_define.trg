--trigger: flh_request_bi_define
--Стандартный триггер инициализации записи
create or replace trigger flh_request_bi_define
 before insert
 on flh_request
 for each row
begin
                                        --Определяем значение первичного ключа
if :new.request_id is null then
  select
    flh_request_seq.nextval
  into 
    :new.request_id
  from
    dual
  ;
end if;

end;
/
