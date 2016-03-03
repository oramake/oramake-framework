-- view: v_opt_value_history
-- Значения настроечных параметров ( история).
create or replace force view
  v_opt_value_history
as
select
  -- SVN root: Oracle/Module/Option
  d.*
from
  (
  select
    h.value_id
    , h.option_id
    , h.prod_value_flag
    , h.instance_name
    , h.used_operator_id
    , h.value_type_code
    , case when h.list_separator is not null then 1 else 0 end
      as value_list_flag
    , h.list_separator
    , h.encryption_flag
    , h.storage_value_type_code
    , h.date_value
    , h.number_value
    , h.string_value
    , h.old_option_value_id
    , h.old_option_id
    , h.old_option_value_del_date
    , h.old_option_del_date
    , h.deleted
    , h.change_number
    , h.change_date
    , h.change_operator_id
    , h.base_date_ins
    , h.base_operator_id
    , h.value_history_id
    , h.date_ins
    , h.operator_id
  from
    opt_value_history h
  union all
  select
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
    , t.old_option_value_id
    , t.old_option_id
    , t.old_option_value_del_date
    , t.old_option_del_date
    , t.deleted
    , t.change_number
    , t.change_date
    , t.change_operator_id
    , t.date_ins as base_date_ins
    , t.operator_id as base_operator_id
    , cast( null as integer) as value_history_id
    , cast( null as date) date_ins
    , cast( null as integer) operator_id
  from
    opt_value t
  ) d
/

comment on table v_opt_value_history is
  'Значения настроечных параметров ( история) [ SVN root: Oracle/Module/Option]'
/
comment on column v_opt_value_history.value_id is
  'Id значения'
/
comment on column v_opt_value_history.option_id is
  'Id параметра'
/
comment on column v_opt_value_history.prod_value_flag is
  'Флаг использования значения только в промышленных ( либо тестовых) БД ( 1 только в промышленных БД, 0 только в тестовых БД, null без ограничений)'
/
comment on column v_opt_value_history.instance_name is
  'Имя экземпляра БД, в которой может использоваться значение ( в верхнем регистре, null без ограничений)'
/
comment on column v_opt_value_history.used_operator_id is
  'Id оператора, для которого может использоваться значение ( null без ограничений)'
/
comment on column v_opt_value_history.value_type_code is
  'Код типа значения параметра'
/
comment on column v_opt_value_history.value_list_flag is
  'Флаг задания для параметра списка значений указанного типа ( 1 да, 0 нет)'
/
comment on column v_opt_value_history.list_separator is
  'Символ, используемый в качестве разделителя в списке значений, сохраненном в поле string_value ( null если список не используется)'
/
comment on column v_opt_value_history.encryption_flag is
  'Флаг хранения значений параметра в зашифрованном виде ( возможно только для значений строкового типа) ( 1 да, 0 нет)'
/
comment on column v_opt_value_history.storage_value_type_code is
  'Код типа, используемого для хранения значения параметра ( отличается от типа значения параметра в случае использования списка значений, т.к. список хранится в виде строки)'
/
comment on column v_opt_value_history.date_value is
  'Значение параметра типа дата'
/
comment on column v_opt_value_history.number_value is
  'Числовое значение параметра'
/
comment on column v_opt_value_history.string_value is
  'Строковое значение параметра ( если не задано значение в поле list_separator) либо список значений с разделителем, указанным в поле list_separator ( если оно задано). Значения параметра строкового типа хранятся в списке без изменений, значения типа дата хранятся в формате "yyyy-mm-dd hh24:mi:ss", числа хранятся в формате "tm9" с десятичным разделителем точка.'
/
comment on column v_opt_value_history.old_option_value_id is
  'Устаревшее поле: Id значения в таблице opt_option_value'
/
comment on column v_opt_value_history.old_option_id is
  'Устаревшее поле: Id параметра в таблице opt_option'
/
comment on column v_opt_value_history.old_option_value_del_date is
  'Устаревшее поле: Дата удаления значения из таблицы opt_option_value'
/
comment on column v_opt_value_history.old_option_del_date is
  'Устаревшее поле: Дата удаления параметра из таблицы opt_option'
/
comment on column v_opt_value_history.deleted is
  'Флаг логического удаления записи ( 0 - существующая, 1 - удалена)'
/
comment on column v_opt_value_history.change_number is
  'Порядковый номер изменения записи ( начиная с 1)'
/
comment on column v_opt_value_history.change_date is
  'Дата изменения записи'
/
comment on column v_opt_value_history.change_operator_id is
  'Id оператора, изменившего запись'
/
comment on column v_opt_value_history.base_date_ins is
  'Дата добавления записи в исходной таблице'
/
comment on column v_opt_value_history.base_operator_id is
  'Id оператора, добавившего запись в исходной таблице'
/
comment on column v_opt_value_history.value_history_id is
  'Id исторической записи'
/
comment on column v_opt_value_history.date_ins is
  'Дата добавления исторической записи'
/
comment on column v_opt_value_history.operator_id is
  'Id оператора, добавившего историческую запись'
/
