alter index
  cdr_day_pk
rebuild
  tablespace &indexTablespace
/

alter table
  cdr_day
add (
  constraint cdr_day_ck_day check
  ( day = trunc( day))
)
/



comment on table cdr_day is
  'Дни календаря [ SVN root: Oracle/Module/Calendar]'
/
comment on column cdr_day.day is
  'День календаря'
/
comment on column cdr_day.day_type_id is
  'Id типа дня'
/
comment on column cdr_day.date_ins is
  'Дата добавления записи'
/
comment on column cdr_day.operator_id is
  'Id оператора, добавившего запись'
/


@oms-run create-mlog.sql cdr_day
