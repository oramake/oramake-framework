-- script: Install/Grant/Last/acl-host.sql
-- Для указанного HOST выдаёт привилении "connect" и "resolve" заданному
-- пользователю.
--
-- Параметры:
-- &1                         - имя пользователя для выдачи прав
--
define userName = &1

declare
  Host_Name varchar2(100)       := 'localhost';
  Default_AclName varchar2(100) := 'Common.host.acl.xml';
  Acl_Description varchar2(100) := 'Oracle/Module/Common: Oracle Host';
  userName varchar2(30)         := '&userName';

  aclName dba_network_acls.acl%type;

  /*
    Добавление привилегии для ACL.
  */
  procedure addPrivilege(
    aclName     varchar2
    , userName  varchar2
    , privilege varchar2
  )
  is
    privExists integer;
  begin
    select
      count(1)
    into
      privExists
    from
      dba_network_acl_privileges nap
    where
      acl = aclName
      and principal = upper( userName)
      and nap.privilege = addPrivilege.privilege
      and is_grant = 'true'
    ;
    if privExists = 0 then
      dbms_network_acl_admin.add_privilege(
        acl                     => aclName
        , principal             => upper( userName)
        , is_grant              => true
        , privilege             => addPrivilege.privilege
      );
      dbms_output.put_line( 'privilege added');
    else
      dbms_output.put_line( 'privilege exists');
    end if;
  end addPrivilege;

begin
  select
    max( acl)
  into
    aclName
  from
    dba_network_acls
  where
    host = Host_Name
  ;
  if aclName is null then
    aclName := 'Common.host.acl.xml';
    dbms_network_acl_admin.create_acl(
      acl                     => aclName
      , principal             => upper( userName)
      , is_grant              => true
      , privilege             => 'connect'
      , description           => Acl_Description
    );
    dbms_output.put_line( 'acl created');
  else
    dbms_output.put_line( 'acl exists');
  end if;
  dbms_network_acl_admin.assign_acl(
    acl                       => aclName
    , host                    => Host_Name
  );
  addPrivilege(
    aclName         => aclName
    , userName      => userName
    , privilege     => 'connect'
  );
  addPrivilege(
    aclName         => aclName
    , userName      => userName
    , privilege     => 'resolve'
  );
end;
/
commit
/
undefine userName



