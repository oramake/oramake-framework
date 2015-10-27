-- trigger: prm_session_action_bi_define
-- ����������� ������� ������������� ������
create or replace trigger prm_session_action_bi_define
 before insert
 on prm_session_action
 for each row
 when ( 
   new.operator_id is null 
   or new.date_ins is null 
   or new.session_action_id is null
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
if :new.session_action_id is null then
  select
    prm_session_action_seq.nextval 
  into    
    :new.session_action_id
  from
    dual;  
end if;

end;--trigger;
/
