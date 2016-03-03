create or replace trigger sch_interval_type_bi_define
 before insert
 on sch_interval_type
 for each row
begin
                                        --Оператор, создавший строку.
if :new.Operator_ID is null then
  :new.Operator_ID := pkg_Operator.GetCurrentUserID;
end if;
                                        --Определяем дату создания строки.
if :new.Date_Ins is null then
  :new.Date_Ins := SysDate;
end if;

end;--trigger;
/
