-- view: v_cdr_day_type( UserDb)
-- Типы дней календаря ( пользовательская БД)
-- ( для создания представления используется скрипт
--  <Install/Schema/Last/Common/v_cdr_day_type.sql>
-- ).
--

@oms-run Install/Schema/Last/Common/v_cdr_day_type.sql mv_cdr_day_type

comment on table v_cdr_day_type is
  'Типы дней календаря ( пользовательская БД) [ SVN root: Oracle/Module/Calendar]'
/
