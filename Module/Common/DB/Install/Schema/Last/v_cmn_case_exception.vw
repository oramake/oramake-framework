-- view: v_cmn_case_exception
-- Представление для отображения актуальных данных таблицы <cmn_case_exception>

create or replace view v_cmn_case_exception
as
select
  -- SVN root: Oracle/Module/Common
  exception_case_id
  , native_case_name
  , genetive_case_name
  , dative_case_name
  , accusative_case_name
  , ablative_case_name
  , preposition_case_name
  , sex_code
  , type_exception_code
  , date_ins
  , operator_id
from
  cmn_case_exception t
where
  t.deleted = 0
/

comment on table v_cmn_case_exception is
  'Представление для отображения актуальных данных справочника исключений в склонениях по падежам фамилий, имен и отчеств [SVN root: Oracle/Module/Common]'
/
comment on column v_cmn_case_exception.exception_case_id is
  'Уникальный идентификатор записи'
/
comment on column v_cmn_case_exception.native_case_name is
  'Строка исключение в именительном падеже'
/
comment on column v_cmn_case_exception.genetive_case_name is
  'Строка исключение в родительном падеже'
/
comment on column v_cmn_case_exception.dative_case_name is
  'Строка исключение в дательном падеже'
/
comment on column v_cmn_case_exception.accusative_case_name is
  'Строка исключение в винительном падеже'
/
comment on column v_cmn_case_exception.ablative_case_name is
  'Строка исключение в творительном падеже'
/
comment on column v_cmn_case_exception.preposition_case_name is
  'Строка исключение в предложном падеже'
/
comment on column v_cmn_case_exception.sex_code is
  'Пол M – мужской, F - женский'
/
comment on column v_cmn_case_exception.type_exception_code is
  'Тип исключения'
/
comment on column v_cmn_case_exception.date_ins is
  'Дата добавления записи'
/
comment on column v_cmn_case_exception.operator_id is
  'Идентификатор оператора, добавившего запись'
/