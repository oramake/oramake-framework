create or replace trigger sch_interval_bi_define
 before insert
 on sch_interval
 for each row
begin
                                        --Определяем значение первичного ключа.
if :new.Interval_ID is null then
  select SCH_Interval_Seq.nextval into :new.Interval_ID from dual;
end if;
                                        --Оператор, создавший строку.
if :new.Operator_ID is null then
  :new.Operator_ID := pkg_Operator.GetCurrentUserID;
end if;
                                        --Определяем дату создания строки.
if :new.Date_Ins is null then
  :new.Date_Ins := SysDate;
end if;
                                        --Тривиальный шаг по умолчанию
if :new.Step is null then
  :new.Step := 1;
end if;

end;--trigger;
/
