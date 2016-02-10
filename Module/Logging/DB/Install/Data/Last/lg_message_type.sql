begin
merge into
  lg_message_type d
using
  (
  select
    pkg_LoggingInternal.Error_MessageTypeCode as message_type_code
    , 'Ошибка' as message_type_name
    , 'Error' as message_type_name_en
  from dual
  union all select
    pkg_LoggingInternal.Warning_MessageTypeCode
    , 'Предупреждение'
    , 'Warning'
  from dual
  union all select
    pkg_LoggingInternal.Info_MessageTypeCode
    , 'Информация'
    , 'Information'
  from dual
  union all select
    pkg_LoggingInternal.Debug_MessageTypeCode
    , 'Отладка'
    , 'Debug'
  from dual
  minus
  select
    t.message_type_code
    , t.message_type_name
    , t.message_type_name_en
  from
    lg_message_type t
  ) s
on
  (
  d.message_type_code = s.message_type_code
  )
when not matched then insert
  (
  message_type_code
  , message_type_name
  , message_type_name_en
  )
values
  (
  s.message_type_code
  , s.message_type_name
  , s.message_type_name_en
  )
when matched then update set
  d.message_type_name            = s.message_type_name
  , d.message_type_name_en       = s.message_type_name_en
;
  dbms_output.put_line( 'changed: ' || SQL%ROWCOUNT);
  commit;
end;
/
