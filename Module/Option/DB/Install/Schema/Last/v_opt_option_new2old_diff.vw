-- view: v_opt_option_new2old_diff
-- Различия в данных по текущим значениям настроечных параметров между новыми
-- ( opt_option_new, opt_value) и устаревшими ( opt_option, opt_option_value)
-- таблицами ( различающиеся записи из представлений v_opt_option и
-- v_opt_option_new2old).
--
create or replace force view
  v_opt_option_new2old_diff
as
select
  -- SVN root: Oracle/Module/Option
  b.*
from
  (
  select
    'V_OPT_OPTION' as view_name
    , a.*
  from
    (
    select
      t.option_id
      , t.option_name
      , t.option_short_name
      , t.is_global
      , t.link_global_local
      , t.mask_id
      , t.datetime_value
      , t.integer_value
      , t.string_value
      , t.option_value_id
    from
      v_opt_option t
    minus
    select
      t.option_id
      , t.option_name
      , t.option_short_name
      , t.is_global
      , t.link_global_local
      , t.mask_id
      , t.datetime_value
      , t.integer_value
      , t.string_value
      , t.option_value_id
    from
      v_opt_option_new2old t
    ) a
  union all
  select
    'V_OPT_OPTION_NEW2OLD' as view_name
    , a.*
  from
    (
    select
      t.option_id
      , t.option_name
      , t.option_short_name
      , t.is_global
      , t.link_global_local
      , t.mask_id
      , t.datetime_value
      , t.integer_value
      , t.string_value
      , t.option_value_id
    from
      v_opt_option_new2old t
    minus
    select
      t.option_id
      , t.option_name
      , t.option_short_name
      , t.is_global
      , t.link_global_local
      , t.mask_id
      , t.datetime_value
      , t.integer_value
      , t.string_value
      , t.option_value_id
    from
      v_opt_option t
    ) a
  ) b
where
  -- Исключаем различия, вызванные загрузкой с помощью SQL*Loader временных
  -- данных в устаревшие таблицы при обновлении параметров пакетных заданий
  b.option_id >= 0
order by
  2, 1
/



comment on table v_opt_option_new2old_diff is
  'Различия в данных по текущим значениям настроечных параметров между новыми ( opt_option_new, opt_value) и устаревшими ( opt_option, opt_option_value) таблицами ( различающиеся записи из представлений v_opt_option и v_opt_option_new2old) [ SVN root: Oracle/Module/Option]'
/
comment on column v_opt_option_new2old_diff.view_name is
  'Id параметра в таблице opt_option'
/
comment on column v_opt_option_new2old_diff.option_id is
  'Id параметра в таблице opt_option'
/
comment on column v_opt_option_new2old_diff.option_name is
  'Название параметра в таблице opt_option'
/
comment on column v_opt_option_new2old_diff.option_short_name is
  'Короткое название параметра в таблице opt_option'
/
comment on column v_opt_option_new2old_diff.is_global is
  'Устаревшее поле, не используется'
/
comment on column v_opt_option_new2old_diff.link_global_local is
  'Устаревшее поле, не используется'
/
comment on column v_opt_option_new2old_diff.mask_id is
  'Id маски для значения параметра'
/
comment on column v_opt_option_new2old_diff.datetime_value is
  'Значение параметра типа дата'
/
comment on column v_opt_option_new2old_diff.integer_value is
  'Числовое значение параметра'
/
comment on column v_opt_option_new2old_diff.string_value is
  'Строковое значение параметра'
/
comment on column v_opt_option_new2old_diff.option_value_id is
  'Id значения в таблице opt_option_value'
/
