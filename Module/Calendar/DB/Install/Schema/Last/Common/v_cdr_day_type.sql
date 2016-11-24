-- script: Install/Schema/Last/Common/v_cdr_day_type.sql
-- SQL для создания представлений <v_cdr_day_type> и <v_cdr_day_type( UserDb)>.
--
-- Параметры:
-- sourceTable                - имя исходной таблицы
--

define sourceTable = "&1"



create or replace force view
  v_cdr_day_type
as
select
  -- SVN root: Oracle/Module/Calendar
  t.day_type_id
  , t.day_type_name
  , t.date_ins
  , t.operator_id
from
  &sourceTable t
/



-- Комментарий для представления добавляется в основном скрипте
comment on column v_cdr_day_type.day_type_id is
  'Id типа дня'
/
comment on column v_cdr_day_type.day_type_name is
  'Наименование типа дня'
/
comment on column v_cdr_day_type.date_ins is
  'Дата добавления записи'
/
comment on column v_cdr_day_type.operator_id is
  'Id оператора, добавившего запись'
/



undefine sourceTable
