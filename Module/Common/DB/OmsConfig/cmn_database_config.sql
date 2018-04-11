declare

  -- Настроечные данные
  cursor dataCur( instanceName varchar2) is
with cfg_data as
  (
  select
    'ProdDefaultDBConfig' as instance_name
    , 1 as is_production
    , null as ip_address_production
    , null as main_instance_name
    , 0 as test_notify_flag
    , null as sender_domain
    , null as smtp_server
    , null as notify_email
    , 1 as default_flag
  from dual
  union all
  select
    'TestDefaultDBConfig' as instance_name
    , 0 as is_production
    , null as ip_address_production
    , null as main_instance_name
    , 0 as test_notify_flag
    , null as sender_domain
    , null as smtp_server
    , null as notify_email
    , 1 as default_flag
  from dual
  union all
  select
    'ProdDB' as instance_name
    , 1 as is_production
    , null as ip_address_production
    , null as main_instance_name
    , 1 as test_notify_flag
    , null as sender_domain
    , null as smtp_server
    , null as notify_email
    , 0 as default_flag
  from dual
  union all
  select
    'ProdStandbyDB' as instance_name
    , 1 as is_production
    , null as ip_address_production
    , 'ProdDB' as main_instance_name
    , 1 as test_notify_flag
    , null as sender_domain
    , null as smtp_server
    , null as notify_email
    , 0 as default_flag
  from dual
  )
select
  d.*
from
  (
  select
    max( coalesce( a.main_instance_name, a.instance_name))
      as main_instance_name
  from
    cfg_data a
  where
    lower( a.instance_name) = lower( instanceName)
  ) b
  inner join cfg_data d
    on d.default_flag = 1
      or lower( coalesce( d.main_instance_name, d.instance_name))
        = lower( b.main_instance_name)
  ;

  -- Список instance_name сохраняемых в таблице записей
  instanceNameList cmn_string_table_t := cmn_string_table_t();

  -- Число удаленных записей
  nDeleted integer := 0;

  -- Число измененных записей
  nMerged integer := 0;

begin
  for rec in dataCur(
        pkg_Common.getInstanceName( ignoreMainInstanceNameFlag => 1)
      )
      loop
    merge into
      cmn_database_config d
    using
      (
      select
        rec.instance_name as instance_name
        , rec.is_production as is_production
        , rec.ip_address_production as ip_address_production
        , rec.main_instance_name as main_instance_name
        , rec.test_notify_flag as test_notify_flag
        , rec.sender_domain as sender_domain
        , rec.smtp_server as smtp_server
        , rec.notify_email as notify_email
        , rec.default_flag as default_flag
      from
        dual
      minus
      select
        t.instance_name
        , t.is_production
        , t.ip_address_production
        , t.main_instance_name
        , t.test_notify_flag
        , t.sender_domain
        , t.smtp_server
        , t.notify_email
        , t.default_flag
      from
        cmn_database_config t
      ) s
    on (
      lower( d.instance_name) = lower( s.instance_name)
    )
    when not matched then insert
    (
      instance_name
      , is_production
      , ip_address_production
      , main_instance_name
      , test_notify_flag
      , sender_domain
      , smtp_server
      , notify_email
      , default_flag
    )
    values
    (
      s.instance_name
      , s.is_production
      , s.ip_address_production
      , s.main_instance_name
      , s.test_notify_flag
      , s.sender_domain
      , s.smtp_server
      , s.notify_email
      , s.default_flag
    )
    when matched then update set
      d.is_production                 = s.is_production
      , d.ip_address_production       = s.ip_address_production
      , d.main_instance_name          = s.main_instance_name
      , d.test_notify_flag            = s.test_notify_flag
      , d.sender_domain               = s.sender_domain
      , d.smtp_server                 = s.smtp_server
      , d.notify_email                = s.notify_email
      , d.default_flag                = s.default_flag
    ;
    nMerged := nMerged + SQL%ROWCOUNT;

    -- Уточняем регистр instance_name (т.к. не могли это сделать в merge)
    if nMerged <> 0 then
      update
        cmn_database_config t
      set
        t.instance_name = rec.instance_name
      where
        lower( t.instance_name) = lower( rec.instance_name)
        and t.instance_name <> rec.instance_name
      ;
    end if;
    instanceNameList.extend(1);
    instanceNameList( instanceNameList.last) := rec.instance_name;
  end loop;
  delete from
    cmn_database_config t
  where
    t.instance_name not in
      (
      select
        tt.column_value as instance_name
      from
        table( cast( instanceNameList as cmn_string_table_t)) tt
      )
  ;
  nDeleted := nDeleted + SQL%ROWCOUNT;
  commit;
  dbms_output.put_line(
    'deleted: ' || to_char( nDeleted)
    || ', merged: ' || to_char( nMerged)
  );
end;
/
