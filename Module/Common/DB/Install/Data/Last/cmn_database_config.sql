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
    , null as smtp_server
    , null as notify_email
    , null as ip_address_production
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
    delete from cmn_database_config t;
    nDeleted := nDeleted + SQL%ROWCOUNT;
  else

    -- Удаляем не относящиеся к БД записи
    delete from
      cmn_database_config t
    where
      lower( t.instance_name) <> lower( pkg_Common.GetInstanceName)
    ;
    nDeleted := nDeleted + SQL%ROWCOUNT;

    -- Сливаем изменения по записи для БД
    merge into
      cmn_database_config d
    using
      (
      select
        lower( rec.instance_name) as instance_name
        , rec.is_production as is_production
        , rec.smtp_server as smtp_server
        , rec.notify_email as notify_email
        , rec.ip_address_production as ip_address_production
      from
        dual
      minus
      select
        lower( t.instance_name)
        , t.is_production
        , t.smtp_server
        , t.notify_email
        , t.ip_address_production
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
      , smtp_server
      , notify_email
      , ip_address_production
    )
    values
    (
      s.instance_name
      , s.is_production
      , s.smtp_server
      , s.notify_email
      , s.ip_address_production
    )
    when matched then update set
      d.is_production                 = s.is_production
      , d.smtp_server                 = s.smtp_server
      , d.notify_email                = s.notify_email
      , d.ip_address_production       = s.ip_address_production
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
      ;
      nMerged := nMerged + SQL%ROWCOUNT;
    end if;
  end if;
  close curData;
  commit;
  dbms_output.put_line(
    'deleted: ' || to_char( nDeleted)
    || ', merged: ' || to_char( nMerged)
  );
end;
/
