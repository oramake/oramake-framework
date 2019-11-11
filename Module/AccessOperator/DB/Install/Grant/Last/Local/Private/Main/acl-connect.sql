-- script: Install/Grant/Last/acl-grant.sql
-- ������ ACL-����� ��� ������������� HOST ��� ������ URL, �� ������� ��������
-- web-������
--
-- ����������:
--   - ������ ���������� ��������� �� ����� sys;

define toUserName = &1


declare
  aclId raw(16);
  aclName varchar2(4000) := '&aclName';
  url varchar2(4000) := '&url';

  -- ������ ��� �������� �������� �����
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

  -- ����� ���
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

    -- �������� ������� ������������ ����
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
      -- �������� ������ ����
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

    -- ���������� ���� �� ������ � ����� ��� URL
    dbms_network_acl_admin.assign_acl(
      acl    => aclName
      , host => url
    );
  -- ���� ���� - ������ ������ �����
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