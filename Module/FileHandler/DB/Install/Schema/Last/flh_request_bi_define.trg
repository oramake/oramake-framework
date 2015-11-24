--trigger: flh_request_bi_define
--����������� ������� ������������� ������
create or replace trigger flh_request_bi_define
 before insert
 on flh_request
 for each row
begin
                                        --���������� �������� ���������� �����
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
