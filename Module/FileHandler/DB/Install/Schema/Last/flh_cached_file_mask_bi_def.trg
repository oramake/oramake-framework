--trigger: flh_cached_file_mask_bi_def
--����������� ������� ������������� ������
create or replace trigger flh_cached_file_mask_bi_def
 before insert
 on flh_cached_file_mask
 for each row
begin
 						    -- ��������, ��������� ������		 	
  if :new.operator_id is null then
    :new.operator_id := pkg_Operator.GetCurrentUserId;
  end if;
                                        -- ���������� �������� 
						    -- ���������� �����
if :new.cached_file_mask_id is null then
  select
    flh_cached_file_mask_seq.nextval
  into 
    :new.cached_file_mask_id
  from
    dual
  ;
end if;

end;
/
