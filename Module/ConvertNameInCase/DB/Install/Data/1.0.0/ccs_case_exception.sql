-- script: Install/Data/1.0.0/ccs_case_exception.sql
-- ƒÓ·‡‚ÎÂÌËÂ ËÒÍÎ˛˜ÂÌËÈ ÒÍÎÓÌÂÌËÈ ‘»Œ ‚ ÒÔ‡‚Ó˜ÌËÍ

merge into
  ccs_case_exception dst
using
  (
  select
    '—¿À' as native_case_name
    , '—¿À' as genetive_case_name
    , '—¿À' as dative_case_name
    , '—¿À' as accusative_case_name
    , '—¿À' as ablative_case_name
    , '—¿À' as preposition_case_name
    , 'M' as sex_code
    , 'L' as type_exception_code
  from
    dual
  union all
  select
    '—¿À' as native_case_name
    , '—¿À' as genetive_case_name
    , '—¿À' as dative_case_name
    , '—¿À' as accusative_case_name
    , '—¿À' as ablative_case_name
    , '—¿À' as preposition_case_name
    , 'W' as sex_code
    , 'L' as type_exception_code
  from
    dual
  union all
  select
    'Œ√À€' as native_case_name
    , 'Œ√À€' as genetive_case_name
    , 'Œ√À€' as dative_case_name
    , 'Œ√À€' as accusative_case_name
    , 'Œ√À€' as ablative_case_name
    , 'Œ√À€' as preposition_case_name
    , 'M' as sex_code
    , 'L' as type_exception_code
  from
    dual
  union all
  select
    'Œ√À€' as native_case_name
    , 'Œ√À€' as genetive_case_name
    , 'Œ√À€' as dative_case_name
    , 'Œ√À€' as accusative_case_name
    , 'Œ√À€' as ablative_case_name
    , 'Œ√À€' as preposition_case_name
    , 'W' as sex_code
    , 'L' as type_exception_code
  from
    dual
  union all
  select
    ' €«€' as native_case_name
    , ' €«€' as genetive_case_name
    , ' €«€' as dative_case_name
    , ' €«€' as accusative_case_name
    , ' €«€' as ablative_case_name
    , ' €«€' as preposition_case_name
    , 'M' as sex_code
    , 'L' as type_exception_code
  from
    dual
  union all
  select
    ' €«€' as native_case_name
    , ' €«€' as genetive_case_name
    , ' €«€' as dative_case_name
    , ' €«€' as accusative_case_name
    , ' €«€' as ablative_case_name
    , ' €«€' as preposition_case_name
    , 'W' as sex_code
    , 'L' as type_exception_code
  from
    dual
  union all
  select
    ' €—' as native_case_name
    , ' €—' as genetive_case_name
    , ' €—' as dative_case_name
    , ' €—' as accusative_case_name
    , ' €—' as ablative_case_name
    , ' €—' as preposition_case_name
    , 'M' as sex_code
    , 'L' as type_exception_code
  from
    dual
  union all
  select
    ' €—' as native_case_name
    , ' €—' as genetive_case_name
    , ' €—' as dative_case_name
    , ' €—' as accusative_case_name
    , ' €—' as ablative_case_name
    , ' €—' as preposition_case_name
    , 'W' as sex_code
    , 'L' as type_exception_code
  from
    dual
  union all
  select
    '«¿ƒ≈' as native_case_name
    , '«¿ƒ≈' as genetive_case_name
    , '«¿ƒ≈' as dative_case_name
    , '«¿ƒ≈' as accusative_case_name
    , '«¿ƒ≈' as ablative_case_name
    , '«¿ƒ≈' as preposition_case_name
    , 'M' as sex_code
    , 'L' as type_exception_code
  from
    dual
  union all
  select
    '«¿ƒ≈' as native_case_name
    , '«¿ƒ≈' as genetive_case_name
    , '«¿ƒ≈' as dative_case_name
    , '«¿ƒ≈' as accusative_case_name
    , '«¿ƒ≈' as ablative_case_name
    , '«¿ƒ≈' as preposition_case_name
    , 'W' as sex_code
    , 'L' as type_exception_code
  from
    dual
  union all
  select
    '¿À‹' as native_case_name
    , '¿À‹' as genetive_case_name
    , '¿À‹' as dative_case_name
    , '¿À‹' as accusative_case_name
    , '¿À‹' as ablative_case_name
    , '¿À‹' as preposition_case_name
    , 'M' as sex_code
    , 'L' as type_exception_code
  from
    dual
  union all
  select
    '¿À‹' as native_case_name
    , '¿À‹' as genetive_case_name
    , '¿À‹' as dative_case_name
    , '¿À‹' as accusative_case_name
    , '¿À‹' as ablative_case_name
    , '¿À‹' as preposition_case_name
    , 'W' as sex_code
    , 'L' as type_exception_code
  from
    dual
  union all
  select
    ' ¿–¿' as native_case_name
    , ' ¿–¿' as genetive_case_name
    , ' ¿–¿' as dative_case_name
    , ' ¿–¿' as accusative_case_name
    , ' ¿–¿' as ablative_case_name
    , ' ¿–¿' as preposition_case_name
    , 'M' as sex_code
    , 'L' as type_exception_code
  from
    dual
  union all
  select
    ' ¿–¿' as native_case_name
    , ' ¿–¿' as genetive_case_name
    , ' ¿–¿' as dative_case_name
    , ' ¿–¿' as accusative_case_name
    , ' ¿–¿' as ablative_case_name
    , ' ¿–¿' as preposition_case_name
    , 'W' as sex_code
    , 'L' as type_exception_code
  from
    dual
  union all
  select
    '“≈–' as native_case_name
    , '“≈–' as genetive_case_name
    , '“≈–' as dative_case_name
    , '“≈–' as accusative_case_name
    , '“≈–' as ablative_case_name
    , '“≈–' as preposition_case_name
    , 'M' as sex_code
    , 'L' as type_exception_code
  from
    dual
  union all
  select
    '“≈–' as native_case_name
    , '“≈–' as genetive_case_name
    , '“≈–' as dative_case_name
    , '“≈–' as accusative_case_name
    , '“≈–' as ablative_case_name
    , '“≈–' as preposition_case_name
    , 'W' as sex_code
    , 'L' as type_exception_code
  from
    dual
  ) src
on
  (
  upper( trim( dst.native_case_name ) ) = upper( trim( src.native_case_name ) )
  and dst.sex_code = src.sex_code
  and dst.type_exception_code = src.type_exception_code
  )
when matched then
  update set
    dst.genetive_case_name = src.genetive_case_name
    , dst.dative_case_name = src.dative_case_name
    , dst.accusative_case_name = src.accusative_case_name
    , dst.ablative_case_name = src.ablative_case_name
    , dst.preposition_case_name = src.preposition_case_name
    , dst.deleted = 0
when not matched then
  insert(
    dst.native_case_name
    , dst.genetive_case_name
    , dst.dative_case_name
    , dst.accusative_case_name
    , dst.ablative_case_name
    , dst.preposition_case_name
    , dst.sex_code
    , dst.type_exception_code
    , dst.operator_id
  )
  values(
    src.native_case_name
    , src.genetive_case_name
    , src.dative_case_name
    , src.accusative_case_name
    , src.ablative_case_name
    , src.preposition_case_name
    , src.sex_code
    , src.type_exception_code
    , pkg_operator.getCurrentUserId()
  )
/

commit
/
