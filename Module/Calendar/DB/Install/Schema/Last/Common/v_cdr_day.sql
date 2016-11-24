-- script: Install/Schema/Last/Common/v_cdr_day.sql
-- SQL для создания представлений <v_cdr_day> и <v_cdr_day( UserDb)>.
--
-- Параметры:
-- sourceTable                - имя исходной таблицы
--

define sourceTable = "&1"



create or replace force view
  v_cdr_day
as
select
  -- SVN root: Oracle/Module/Calendar
  t.day
  , t.day_type_id
  , t.date_ins
  , t.operator_id
from
  &sourceTable t
/



-- Комментарий для представления добавляется в основном скрипте
comment on column v_cdr_day.day is
  'День календаря'
/
comment on column v_cdr_day.day_type_id is
  'Id типа дня'
/
comment on column v_cdr_day.date_ins is
  'Дата добавления записи'
/
comment on column v_cdr_day.operator_id is
  'Id оператора, добавившего запись'
/



undefine sourceTable
