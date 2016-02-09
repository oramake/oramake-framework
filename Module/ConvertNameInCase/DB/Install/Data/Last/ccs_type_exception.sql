-- script: Install/Data/Last/ccs_type_exception.sql
-- Установка начальных данных в таблицу <ccs_type_exception>

merge into
  ccs_type_exception dst
using
  (
  select
    t.type_exception_code
    , t.type_exception_name_rus
    , t.type_exception_name_eng
  from
    (
    select
      'L' as type_exception_code
      , 'Фамилия' as type_exception_name_rus
      , 'Last name' as type_exception_name_eng
    from
      dual
    union all
    select
      'F' as type_exception_code
      , 'Имя' as type_exception_name_rus
      , 'First name' as type_exception_name_eng
    from
      dual
    union all
    select
      'M' as type_exception_code
      , 'Отчество' as type_exception_name_rus
      , 'Middle name' as type_exception_name_eng
    from
      dual
    ) t
  minus
  select
    te.type_exception_code
    , te.type_exception_name_rus
    , te.type_exception_name_eng
  from
    ccs_type_exception te
  ) src
on
  ( dst.type_exception_code = src.type_exception_code )
when matched then
  update set
    dst.type_exception_name_rus = src.type_exception_name_rus
    , dst.type_exception_name_eng = src.type_exception_name_eng
when not matched then
  insert(
    dst.type_exception_code
    , dst.type_exception_name_rus
    , dst.type_exception_name_eng
  )
  values(
    src.type_exception_code
    , src.type_exception_name_rus
    , src.type_exception_name_eng
  )
/

commit
/
