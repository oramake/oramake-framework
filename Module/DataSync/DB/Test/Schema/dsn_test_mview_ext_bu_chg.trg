-- trigger: dsn_test_mview_ext_bu_chg
-- Измененяет значения change_number и change_date при изменении записи.
create or replace trigger dsn_test_mview_ext_bu_chg
  before update
  on dsn_test_mview_ext
  for each row
begin
  :new.change_date := sysdate;
end;
/
