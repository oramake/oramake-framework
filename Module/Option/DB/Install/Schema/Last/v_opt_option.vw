-- view: v_opt_option
-- Настроечные параметры программных модулей ( актуальные данные).
create or replace force view
  v_opt_option
as
select
  -- SVN root: Oracle/Module/Option
  t.option_id
  , t.module_id
  , t.object_short_name
  , t.object_type_id
  , t.option_short_name
  , t.value_type_code
  , t.value_list_flag
  , t.encryption_flag
  , t.test_prod_sensitive_flag
  , t.access_level_code
  , t.option_name
  , t.option_description
  , t.change_number
  , t.change_date
  , t.change_operator_id
  , t.date_ins
  , t.operator_id
from
  opt_option t
where
  t.deleted = 0
/

comment on table v_opt_option is
  'Настроечные параметры программных модулей ( актуальные данные) [ SVN root: Oracle/Module/Option]'
/
comment on column v_opt_option.option_id is
  'Id параметра'
/
comment on column v_opt_option.module_id is
  'Id модуля, к которому относится параметр'
/
comment on column v_opt_option.object_short_name is
  'Короткое название объекта модуля ( уникальное в рамках модуля), к которому относится параметр ( null если не требуется разделения параметров по объектам либо параметр относится ко всему модулю)'
/
comment on column v_opt_option.object_type_id is
  'Id типа объекта'
/
comment on column v_opt_option.option_short_name is
  'Короткое название параметра ( уникальное в рамках модуля либо в рамках объекта модуля, если заполнено поле object_short_name)'
/
comment on column v_opt_option.value_type_code is
  'Код типа значения параметра'
/
comment on column v_opt_option.value_list_flag is
  'Флаг задания для параметра списка значений указанного типа ( 1 да, 0 нет)'
/
comment on column v_opt_option.encryption_flag is
  'Флаг хранения значений параметра в зашифрованном виде ( возможно только для значений строкового типа) ( 1 да, 0 нет)'
/
comment on column v_opt_option.test_prod_sensitive_flag is
  'Флаг указания для значения параметра типа базы данных ( тестовая или промышленная), для которого оно предназначено ( 1 да, 0 нет)'
/
comment on column v_opt_option.access_level_code is
  'Код уровня доступа к параметру через пользовательский интерфейс'
/
comment on column v_opt_option.option_name is
  'Название параметра'
/
comment on column v_opt_option.option_description is
  'Описание параметра'
/
comment on column v_opt_option.change_number is
  'Порядковый номер изменения записи ( начиная с 1)'
/
comment on column v_opt_option.change_date is
  'Дата изменения записи'
/
comment on column v_opt_option.change_operator_id is
  'Id оператора, изменившего запись'
/
comment on column v_opt_option.date_ins is
  'Дата добавления записи'
/
comment on column v_opt_option.operator_id is
  'Id оператора, добавившего запись'
/
