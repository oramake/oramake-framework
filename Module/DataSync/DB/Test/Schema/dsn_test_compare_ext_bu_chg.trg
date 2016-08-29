-- trigger: dsn_test_compare_ext_bu_chg
-- ���������� �������� change_number � change_date ��� ��������� ������.
create or replace trigger dsn_test_compare_ext_bu_chg
  before update
  on dsn_test_compare_ext
  for each row
begin
  :new.change_number := :old.change_number + 1;
  :new.change_date := sysdate;
end;
/
