-- view: v_opt_value
-- «начени€ настроечных параметров ( актуальные данные).
create or replace force view
  v_opt_value
as
select
  -- SVN root: Oracle/Module/Option
  t.value_id
  , t.option_id
  , t.prod_value_flag
  , t.instance_name
  , t.used_operator_id
  , t.value_type_code
  , case when t.list_separator is not null then 1 else 0 end
    as value_list_flag
  , t.list_separator
  , t.encryption_flag
  , t.storage_value_type_code
  , t.date_value
  , t.number_value
  , t.string_value
  , t.change_number
  , t.change_date
  , t.change_operator_id
  , t.date_ins
  , t.operator_id
from
  opt_value t
where
  t.deleted = 0
/

comment on table v_opt_value is
  '«начени€ настроечных параметров ( актуальные данные) [ SVN root: Oracle/Module/Option]'
/
comment on column v_opt_value.value_id is
  'Id значени€'
/
comment on column v_opt_value.option_id is
  'Id параметра'
/
comment on column v_opt_value.prod_value_flag is
  '‘лаг использовани€ значени€ только в промышленных ( либо тестовых) Ѕƒ ( 1 только в промышленных Ѕƒ, 0 только в тестовых Ѕƒ, null без ограничений)'
/
comment on column v_opt_value.instance_name is
  '»м€ экземпл€ра Ѕƒ, в которой может использоватьс€ значение ( в верхнем регистре, null без ограничений)'
/
comment on column v_opt_value.used_operator_id is
  'Id оператора, дл€ которого может использоватьс€ значение ( null без ограничений)'
/
comment on column v_opt_value.value_type_code is
  ' од типа значени€ параметра'
/
comment on column v_opt_value.value_list_flag is
  '‘лаг задани€ дл€ параметра списка значений указанного типа ( 1 да, 0 нет)'
/
comment on column v_opt_value.list_separator is
  '—имвол, используемый в качестве разделител€ в списке значений, сохраненном в поле string_value ( null если список не используетс€)'
/
comment on column v_opt_value.encryption_flag is
  '‘лаг хранени€ значений параметра в зашифрованном виде ( возможно только дл€ значений строкового типа) ( 1 да, 0 нет)'
/
comment on column v_opt_value.storage_value_type_code is
  ' од типа, используемого дл€ хранени€ значени€ параметра ( отличаетс€ от типа значени€ параметра в случае использовани€ списка значений, т.к. список хранитс€ в виде строки)'
/
comment on column v_opt_value.date_value is
  '«начение параметра типа дата'
/
comment on column v_opt_value.number_value is
  '„исловое значение параметра'
/
comment on column v_opt_value.string_value is
  '—троковое значение параметра ( если не задано значение в поле list_separator) либо список значений с разделителем, указанным в поле list_separator ( если оно задано). «начени€ параметра строкового типа хран€тс€ в списке без изменений, значени€ типа дата хран€тс€ в формате "yyyy-mm-dd hh24:mi:ss", числа хран€тс€ в формате "tm9" с дес€тичным разделителем точка.'
/
comment on column v_opt_value.change_number is
  'ѕор€дковый номер изменени€ записи ( начина€ с 1)'
/
comment on column v_opt_value.change_date is
  'ƒата изменени€ записи'
/
comment on column v_opt_value.change_operator_id is
  'Id оператора, изменившего запись'
/
comment on column v_opt_value.date_ins is
  'ƒата добавлени€ записи'
/
comment on column v_opt_value.operator_id is
  'Id оператора, добавившего запись'
/
