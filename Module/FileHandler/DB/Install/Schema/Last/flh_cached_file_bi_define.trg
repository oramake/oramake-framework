--trigger: flh_cached_file_bi_define
--����������� ������� ������������� ������
create or replace trigger flh_cached_file_bi_define
 before insert
 on flh_cached_file
 for each row
begin
                                        --���������� �������� ���������� �����
if :new.cached_file_id is null then
  select
    flh_cached_file_seq.nextval
  into 
    :new.cached_file_id
  from
    dual
  ;
end if;

end;
/
