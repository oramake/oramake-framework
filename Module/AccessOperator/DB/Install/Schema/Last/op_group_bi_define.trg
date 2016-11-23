--trigger: OP_GROUP_BI_DEFINE
-- create trigger OP_GROUP_BI_DEFINE
CREATE OR REPLACE TRIGGER OP_GROUP_BI_DEFINE
 BEFORE INSERT
 ON OP_GROUP
 FOR EACH ROW
BEGIN
if :new.Operator_ID is null then        --��������, ��������� ������.
  :new.Operator_ID := pkg_Operator.GetCurrentUserID;
end if;

if :new.Date_Ins is null then           --���������� ���� �������� ������.
  :new.Date_Ins := SysDate;
end if;

if :new.Group_ID is null then           --���������� �������� ���������� �����.
  select op_Group_Seq.nextval into :new.Group_ID from dual;
end if;

END;--trigger;
/
