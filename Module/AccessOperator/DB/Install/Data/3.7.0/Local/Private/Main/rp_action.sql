-- script: Install/Data/3.7.0/Local/Private/Main/rp_action.sql
-- ƒобавлние начальных данных в таблицу <rp_action>

merge into
  rp_action dst
using
  (
  select
    t.action_type_code
    , t.database_link
    , t.customize_type_code
  from
    (
    select
      'OP' as action_type_code
      , 'http://ssmrcrm1:7777/InfoBankService.svc/jsonp/UserIntegrate' as database_link
      , 'CRM' as customize_type_code
    from
      dual
    ) t
  minus
  select
    a.action_type_code
    , a.database_link
    , a.customize_type_code
  from
    rp_action a
  ) src
on
  (
  dst.action_type_code = src.action_type_code
  and upper( dst.database_link ) = upper( src.database_link )
  )
when matched then
  update set
    dst.customize_type_code = src.customize_type_code
when not matched then
  insert(
    dst.action_type_code
    , dst.database_link
    , dst.customize_type_code
  )
  values(
    src.action_type_code
    , src.database_link
    , src.customize_type_code
  )
/

commit
/
