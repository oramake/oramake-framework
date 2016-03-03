-- view: v_opt_option
create or replace force view v_opt_option
(
  option_id
  , option_name
  , option_short_name
  , is_global
  , link_global_local
  , mask_id
  , datetime_value
  , integer_value
  , string_value
  , option_value_id
)
as
select
  oo.option_id
  , oo.option_name
  , oo.option_short_name
  , oo.is_global
  , oo.link_global_local
  , oo.mask_id
  , oov.datetime_value
  , oov.integer_value
  , oov.string_value
  , oov.option_value_id
from
  opt_option oo
  , opt_option_value oov
  , (select option_id, max(date_ins) as mdins from opt_option_value group by option_id) ooin
where
  ooin.mdins = oov.date_ins
  and oov.option_id = ooin.option_id
  and oo.option_id = oov.option_id
/

comment on table v_opt_option is
  '”старевшее представление ( следует использовать v_opt_option_value) [ SVN root: Oracle/Module/Option]'
/
