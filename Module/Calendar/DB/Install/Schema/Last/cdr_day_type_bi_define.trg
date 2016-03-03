--trigger: CDR_DAY_TYPE_BI_DEFINE
--Триггер CDR_DAY_TYPE_BI_DEFINE

CREATE OR REPLACE TRIGGER CDR_DAY_TYPE_BI_DEFINE
	BEFORE INSERT
	ON CDR_DAY_TYPE
	FOR EACH ROW
BEGIN
	if :new.Operator_ID is null then        --Оператор, создавший строку.
	  :new.Operator_ID := pkg_Operator.GetCurrentUserID;
	end if;
	
	if :new.Date_Ins is null then           --Определяем дату создания строки.
	  :new.Date_Ins := SysDate;
	end if;
	
	if :new.Day_Type_ID is null then           --Определяем значение первичного ключа.
	  select cdr_Day_Type_Seq.nextval into :new.Day_Type_ID from dual;
	end if;
END;
/
