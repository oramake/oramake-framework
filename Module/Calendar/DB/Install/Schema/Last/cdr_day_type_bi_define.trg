--trigger: CDR_DAY_TYPE_BI_DEFINE
--������� CDR_DAY_TYPE_BI_DEFINE

CREATE OR REPLACE TRIGGER CDR_DAY_TYPE_BI_DEFINE
	BEFORE INSERT
	ON CDR_DAY_TYPE
	FOR EACH ROW
BEGIN
	if :new.Operator_ID is null then        --��������, ��������� ������.
	  :new.Operator_ID := pkg_Operator.GetCurrentUserID;
	end if;
	
	if :new.Date_Ins is null then           --���������� ���� �������� ������.
	  :new.Date_Ins := SysDate;
	end if;
	
	if :new.Day_Type_ID is null then           --���������� �������� ���������� �����.
	  select cdr_Day_Type_Seq.nextval into :new.Day_Type_ID from dual;
	end if;
END;
/
