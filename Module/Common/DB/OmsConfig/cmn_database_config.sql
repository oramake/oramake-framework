declare

  -- Настроечные данные для экземпляров БД
  cursor curData is
select
  a.*
from
  (
  select
    'ProdDB' as instance_name
    , 1 as is_production
    , null as ip_address_production
    , 1 as test_notify_flag
    , null as sender_domain
    , null as smtp_server
    , null as notify_email
    , 0 as default_flag
  from dual
  ) a
where
  lower( a.instance_name) = lower( pkg_Common.getInstanceName())
  ;

  rec curData%rowtype;

  -- Число удаленных записей
  nDeleted integer := 0;

  -- Число измененных записей
  nMerged integer := 0;

begin
  open curData;
  fetch curData into rec;
  if curData%NOTFOUND then
    delete from cmn_database_config t
    where default_flag = 0;
    nDeleted := nDeleted + SQL%ROWCOUNT;
  else

    -- Удаляем не относящиеся к БД записи
    delete from
      cmn_database_config t
    where
      lower( t.instance_name) <> lower( pkg_Common.GetInstanceName)
      and default_flag = 0
    ;
    nDeleted := nDeleted + SQL%ROWCOUNT;
  end if;
  -- Сливаем изменения по записи для БД
  merge into
    cmn_database_config d
  using
    (
    select
      'ProdDefaultDBConfig' as instance_name
      , 1 as is_production
      , 0 as test_notify_flag
      , null as sender_domain
      , null as smtp_server
      , null as notify_email
      , null as ip_address_production
      , 1 as default_flag
    from dual
    union all
    select
      'TestDefaultDBConfig' as instance_name
      , 0 as is_production
      , 0 as test_notify_flag
      , null as sender_domain
      , null as smtp_server
      , null as notify_email
      , null as ip_address_production
      , 1 as default_flag
    from dual
    union all
    select
      lower( rec.instance_name) as instance_name
      , rec.is_production as is_production
      , rec.test_notify_flag as test_notify_flag
      , rec.sender_domain as sender_domain
      , rec.smtp_server as smtp_server
      , rec.notify_email as notify_email
      , rec.ip_address_production as ip_address_production
      , rec.default_flag as default_flag
    from
      dual
    where
      lower( rec.instance_name) = lower( pkg_Common.getInstanceName())
    minus
    select
      lower( t.instance_name)
      , t.is_production
      , t.test_notify_flag
      , t.sender_domain
      , t.smtp_server
      , t.notify_email
      , t.ip_address_production
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
    , test_notify_flag
    , sender_domain
    , smtp_server
    , notify_email
    , ip_address_production
    , default_flag
  )
  values
  (
    s.instance_name
    , s.is_production
    , s.test_notify_flag
    , s.sender_domain
    , s.smtp_server
    , s.notify_email
    , s.ip_address_production
    , s.default_flag
  )
  when matched then update set
    d.is_production                 = s.is_production
    , d.test_notify_flag            = s.test_notify_flag
    , d.sender_domain               = s.sender_domain
    , d.smtp_server                 = s.smtp_server
    , d.notify_email                = s.notify_email
    , d.ip_address_production       = s.ip_address_production
    , d.default_flag                = s.default_flag
  ;
  nMerged := nMerged + SQL%ROWCOUNT;
  if nMerged = 0 then
    update
      cmn_database_config t
    set
      t.instance_name = rec.instance_name
    where
      lower( t.instance_name) = lower( rec.instance_name)
      and t.instance_name <> rec.instance_name
      and default_flag = 0
    ;
    nMerged := nMerged + SQL%ROWCOUNT;
  end if;
  close curData;
  commit;
  dbms_output.put_line(
    'deleted: ' || to_char( nDeleted)
    || ', merged: ' || to_char( nMerged)
  );
end;
/
