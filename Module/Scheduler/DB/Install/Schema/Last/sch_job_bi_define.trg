create or replace trigger sch_job_bi_define
 before insert
 on sch_job
 for each row
begin

if :new.Job_ID is null then             --Определяем значение первичного ключа.
  select SCH_Job_Seq.nextval into :new.Job_ID from dual;
end if;

if :new.Operator_ID is null then        --Оператор, создавший строку.
  :new.Operator_ID := pkg_Operator.GetCurrentUserID;
end if;

if :new.Date_Ins is null then           --Определяем дату создания строки.
  :new.Date_Ins := SysDate;
end if;

end;--trigger;
/
