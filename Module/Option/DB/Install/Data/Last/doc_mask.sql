begin
merge into 
  doc_mask d
using
  (
  select
    1 as mask_id
    , 'Целое число' as mask_name
    , pkg_Option.StorageRuleInteger as storage_rule_id
    , '99999999999999999999999999999999999999' as mask_oracle
    , '99999999999999999999999999999999999999' as mask_delphi
  from dual
  union all select
    2
    , 'Денежная сумма'
    , pkg_Option.StorageRuleInteger
    , '9999999999999.99'
    , '9999999999999.99'
  from dual
  union all select
    3
    , 'Строка'
    , pkg_Option.StorageRuleString
    , null
    , null
  from dual
  union all select
    4
    , 'Дата'
    , pkg_Option.StorageRuleDate
    , null
    , '!00/00/0000;1;_!00/00/0000;1;_'
  from dual
  minus
  select
    t.mask_id
    , t.mask_name
    , t.storage_rule_id
    , t.mask_oracle
    , t.mask_delphi
  from
    doc_mask t
  ) s
on
  (
  d.mask_id = s.mask_id
  )
when not matched then insert
  (
  mask_id
  , mask_name
  , storage_rule_id
  , mask_oracle
  , mask_delphi
  )
values
  (
  s.mask_id
  , s.mask_name
  , s.storage_rule_id
  , s.mask_oracle
  , s.mask_delphi
  )
when matched then update set
  d.mask_name                     = s.mask_name
  , d.storage_rule_id             = s.storage_rule_id
  , d.mask_oracle                 = s.mask_oracle
  , d.mask_delphi                 = s.mask_delphi
;
  dbms_output.put_line( 'changed: ' || SQL%ROWCOUNT);
  commit;
end;
/
