begin
merge into
  doc_storage_rule d
using
  (
  select
    pkg_Option.StorageRuleInteger as storage_rule_id
    , 'Integer_Value' as storage_rule_name
    , 'DP.GetInteger' as fn_get_by_content
    , 'GIP' as fn_get_by_property
  from dual
  union all select
    pkg_Option.StorageRuleString
    , 'String_Value'
    , 'DP.GetString'
    , 'GSP'
  from dual
  union all select
    pkg_Option.StorageRuleDate
    , 'Date_Value'
    , 'DP.GetDate'
    , 'GDP'
  from dual
  minus
  select
    t.storage_rule_id
    , t.storage_rule_name
    , t.fn_get_by_content
    , t.fn_get_by_property
  from
    doc_storage_rule t
  ) s
on
  (
  d.storage_rule_id = s.storage_rule_id
  )
when not matched then insert
  (
  storage_rule_id
  , storage_rule_name
  , fn_get_by_content
  , fn_get_by_property
  )
values
  (
  s.storage_rule_id
  , s.storage_rule_name
  , s.fn_get_by_content
  , s.fn_get_by_property
  )
when matched then update set
  d.storage_rule_name             = s.storage_rule_name
  , d.fn_get_by_content           = s.fn_get_by_content
  , d.fn_get_by_property          = s.fn_get_by_property
;
  dbms_output.put_line( 'changed: ' || SQL%ROWCOUNT);
  commit;
end;
/
