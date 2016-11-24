alter index
  cdr_day_type_pk
rebuild
  tablespace &indexTablespace
/

comment on table cdr_day_type is
  'Типы дней календаря [ SVN root: Oracle/Module/Calendar]'
/
comment on column cdr_day_type.day_type_id is
  'Id типа дня'
/
comment on column cdr_day_type.day_type_name is
  'Наименование типа дня'
/
comment on column cdr_day_type.date_ins is
  'Дата добавления записи'
/
comment on column cdr_day_type.operator_id is
  'Id оператора, добавившего запись'
/


@oms-run create-mlog.sql cdr_day_type
