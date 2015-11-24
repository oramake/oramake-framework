--trigger: flh_batch_config_bi_define
--����������� ������� ������������� ������
create or replace trigger flh_batch_config_bi_define
 before insert
 on flh_batch_config
 for each row
begin
 						    -- ��������, ��������� ������		 	
  if :new.operator_id is null then
    :new.operator_id := pkg_Operator.GetCurrentUserId;
  end if;
                                        -- ���������� �������� 
						    -- ���������� �����
if :new.batch_config_id is null then
  select
    flh_batch_config_seq.nextval
  into 
    :new.batch_config_id 
  from
    dual
  ;
end if;

end;
/
