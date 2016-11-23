--trigger: OP_OPERATOR_BI_DEFINE
-- create trigger OP_OPERATOR_BI_DEFINE
CREATE OR REPLACE TRIGGER OP_OPERATOR_BI_DEFINE

 BEFORE INSERT
 ON OP_OPERATOR
 FOR EACH ROW
BEGIN
if :new.Operator_ID_Ins is null then    --��������, ��������� ������.
  :new.Operator_ID_Ins := pkg_Operator.GetCurrentUserID;
end if;

if :new.Date_Ins is null then           --���������� ���� �������� ������.
  :new.Date_Ins := SysDate;
end if;

if :new.Operator_ID is null then        --���������� �������� ���������� �����.
  select op_Operator_Seq.nextval into :new.Operator_ID from dual;
end if;

END;--trigger;
/
