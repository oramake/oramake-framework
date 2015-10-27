--trigger: tmp_file_name_bi_define
create or replace trigger tmp_file_name_bi_define
 before insert
 on tmp_file_name
 for each row
begin
                                        --Определяем значение первичного ключа
if :new.file_name_id is null then
  select
    tmp_file_name_seq.nextval
  into :new.file_name_id
  from
    dual
  ;
end if;

end;--trigger;
/
