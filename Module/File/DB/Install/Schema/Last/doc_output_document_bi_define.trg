--trigger: doc_output_document_bi_define
create or replace trigger doc_output_document_bi_define
 before insert
 on doc_output_document
 for each row
begin
                                        --Определяем значение первичного ключа
if :new.output_document_id is null then
  select
    doc_output_document_seq.nextval
  into :new.output_document_id
  from
    dual
  ;
end if;

end;
/
