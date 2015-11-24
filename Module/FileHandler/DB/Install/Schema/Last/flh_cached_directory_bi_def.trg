--trigger: flh_cached_directory_bi_def
--����������� ������� ������������� ������
create or replace trigger flh_cached_directory_bi_def
 before insert
 on flh_cached_directory
 for each row
begin
 						    -- ��������, ��������� ������		 	
  if :new.operator_id is null then
    :new.operator_id := pkg_Operator.GetCurrentUserId;
  end if;
                                        -- ���������� �������� 
						    -- ���������� �����
if :new.cached_directory_id is null then
  select
    flh_cached_directory_seq.nextval
  into 
    :new.cached_directory_id
  from
    dual
  ;
end if;

end;
/
