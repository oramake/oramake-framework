-- view: v_cdr_day_type
-- Типы дней календаря
-- ( для создания представления используется скрипт
--  <Install/Schema/Last/Common/v_cdr_day_type.sql>
-- ).
--

@oms-run Install/Schema/Last/Common/v_cdr_day_type.sql cdr_day_type

comment on table v_cdr_day_type is
  'Типы дней календаря [ SVN root: Oracle/Module/Calendar]'
/
