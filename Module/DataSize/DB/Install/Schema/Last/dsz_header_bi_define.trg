--trigger: dsz_header_bi_define
--����������� ������� ������������� ������
create or replace trigger dsz_header_bi_define
 before insert
 on dsz_header
 for each row
 when ( 
   new.operator_id is null 
   or new.date_ins is null 
   or new.header_id is null
 )
begin
                                        -- ��������, ��������� ������.
if :new.operator_id is null then
  :new.operator_id := pkg_Operator.GetCurrentUserID;
end if;
                                        -- ���������� ����� �������� ������.
if :new.date_ins is null then
  :new.date_ins := sysdate;
end if;
					          -- �������������� ��������� ����
if :new.header_id is null then
  :new.header_id := pkg_DataSize.GetNextHeaderId;
end if;

end;--trigger;
/
