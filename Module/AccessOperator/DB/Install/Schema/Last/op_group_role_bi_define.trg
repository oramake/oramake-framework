--trigger: OP_GROUP_ROLE_BI_DEFINE
-- create trigger OP_GROUP_ROLE_BI_DEFINE
CREATE OR REPLACE TRIGGER OP_GROUP_ROLE_BI_DEFINE

 BEFORE INSERT
 ON OP_GROUP_ROLE
 FOR EACH ROW
BEGIN
if :new.Operator_ID is null then        --��������, ��������� ������.
  :new.Operator_ID := pkg_Operator.GetCurrentUserID;
end if;

if :new.Date_Ins is null then           --���������� ���� �������� ������.
  :new.Date_Ins := SysDate;
end if;

END;--trigger;
/
