--trigger: doc_input_document_bi_define
create or replace trigger doc_input_document_bi_define
 before insert
 on doc_input_document
 for each row
begin
                                        --Определяем значение первичного ключа
if :new.input_document_id is null then
  select
    doc_input_document_seq.nextval
  into :new.input_document_id
  from
    dual
  ;
end if;

end;
/
