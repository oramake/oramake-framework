--trigger: flh_request_file_list_bi
--����������� ������� ������������� ������
create or replace trigger flh_request_file_list_bi
 before insert
 on flh_request_file_list
 for each row
begin
                                        --���������� �������� ���������� �����
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
