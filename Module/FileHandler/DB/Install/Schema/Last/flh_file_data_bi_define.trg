--trigger: flh_file_data_bi_define
--����������� ������� ������������� ������
create or replace trigger flh_file_data_bi_define
 before insert
 on flh_file_data
 for each row
begin
                                        --���������� �������� ���������� �����
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
