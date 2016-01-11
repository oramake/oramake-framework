--trigger: ml_fetch_request_bi_define
--����������� ������� ������������� ������
create or replace trigger ml_fetch_request_bi_define
 before insert
 on ml_fetch_request
 for each row
begin
                                        --���������� �������� ���������� �����.     
if :new.fetch_request_id is null then
  select 
    ml_fetch_request_seq.nextval 
  into 
    :new.fetch_request_id 
  from 
    dual;
end if;

end;--trigger;
/
