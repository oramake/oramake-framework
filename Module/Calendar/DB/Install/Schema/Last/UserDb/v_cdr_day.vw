-- view: v_cdr_day( UserDb)
-- Дни календаря ( пользовательская БД)
-- ( для создания представления используется скрипт
--  <Install/Schema/Last/Common/v_cdr_day.sql>
-- ).
--

@oms-run Install/Schema/Last/Common/v_cdr_day.sql mv_cdr_day

comment on table v_cdr_day is
  'Дни календаря ( пользовательская БД) [ SVN root: Oracle/Module/Calendar]'
/
