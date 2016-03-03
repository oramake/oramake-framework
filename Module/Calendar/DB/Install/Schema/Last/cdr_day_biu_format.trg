--trigger: CDR_DAY_BIU_FORMAT
--������� CDR_DAY_BIU_FORMAT

CREATE OR REPLACE TRIGGER CDR_DAY_BIU_FORMAT 
	BEFORE INSERT 
	OR UPDATE OF "DAY" ON "CDR_DAY" 
	FOR EACH ROW 
BEGIN
	:new.Day := trunc(:new.Day);               --�������� ���� � ������
END;
/