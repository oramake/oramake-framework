-- script: Install/Grant/Last/acl-grant.sql
-- Выдает ACL-права для использования HOST или адреса URL, на котором работает
-- web-сервис
--
-- Примечание:
--   - скрипт необходимо запустить от имени sys;

define toUserName = &1


declare
  aclId raw(16);
  aclName varchar2(4000) := '&aclName';
  url varchar2(4000) := '&url';

  -- Курсор для проверки привязки хоста
  cursor curAclHost
  is
    select
      t.aclId
    from
      dba_network_acls t
    where
      upper( t.host) = upper( url)
  ;

  cursor curAclPrivs
  is
    select p.aclId
      from dba_network_acl_privileges p
     where p.acl = '/sys/acls/' || aclName
  ;

begin
  open curAclHost;
  fetch curAclHost into aclId;
  if curAclHost%isopen then
    close curAclHost;
  end if;

  -- Хоста нет
  if aclId is null then
    open curAclPrivs;
    fetch curAclPrivs into aclId;
    if curAclPrivs%isopen then
      close curAclPrivs;
    end if;

    pkg_Common.outputMessage(
      'aclName="' || aclName || '"'
      || ', url="' || url || '"'
    );

    -- проверка наличия существующих прав
    if aclId is not null then
      dbms_network_acl_admin.add_privilege(
        acl         => aclName
        , principal => upper( '&toUserName')
        , is_grant  => true
        , privilege => 'connect'
      );
      dbms_network_acl_admin.add_privilege(
        acl         => aclName
        , principal => upper( '&toUserName')
        , is_grant  => true
        , privilege => 'resolve'
      );
    else
      -- создание группы прав
      dbms_network_acl_admin.create_acl(
        acl           => aclName
        , description => 'Grants for acl="' || aclName || '"'
        , principal   => upper( '&toUserName')
        , is_grant    => true
        , privilege   => 'connect'
      );
      dbms_network_acl_admin.add_privilege(
        acl         => aclName
        , principal => upper( '&toUserName')
        , is_grant  => true
        , privilege => 'connect'
      );
      dbms_network_acl_admin.add_privilege(
        acl         => aclName
        , principal => upper( '&toUserName')
        , is_grant  => true
        , privilege => 'resolve'
      );
    end if;

    -- присвоение прав на доступ к хосту или URL
    dbms_network_acl_admin.assign_acl(
      acl    => aclName
      , host => url
    );
  -- Хост есть - только выдаем права
  else
    dbms_network_acl_admin.add_privilege(
      acl         => aclName
      , principal => upper( '&toUserName')
      , is_grant  => true
      , privilege => 'connect'
    );
    dbms_network_acl_admin.add_privilege(
      acl         => aclName
      , principal => upper( '&toUserName')
      , is_grant  => true
      , privilege => 'resolve'
    );
  end if;
end;
/

commit
/


undefine toUserName