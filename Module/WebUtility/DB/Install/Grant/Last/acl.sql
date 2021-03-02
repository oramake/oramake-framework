-- script: Install/Grant/Last/acl.sql
-- Обновляет привилегие (ACL) на доступ к заданному host по протоколу http.
--
-- Параметры:
-- toUserName                 - имя пользователя, которому выдаются права
--
-- Замечания:
--  - скрипт запускается под привилегированным пользователем;
--

define toUserName = &1
@oms-default acl "WebUtility.acl.xml"
@oms-default host ""


declare

  -- Пользователь, которому выдаются права
  toUserName varchar2(30) := upper( trim( '&toUserName'));

  -- Сохранено имя, первоначально использованное в БД
  Acl_Name constant varchar2(50) := '&acl'; 

  -- Хост, на который выдаются права
  host constant varchar2(1024) := '&host';

  Acl_Privilege constant varchar2(50) := 'connect';

  aclHost dba_network_acls.host%type;
  isGranted integer;

  i pls_integer;

begin
  -- Check and create ACL
  select
    max( na.host)
  into aclHost
  from
    dba_network_acls na
  where
    na.acl like '%/' || Acl_Name
  ;
  if aclHost is null then
    dbms_network_acl_admin.create_acl(
      acl             => Acl_Name
      , description   =>
          'WebUtility module ACL ( SVN root: Oracle/Module/WebUtility)'
      , principal     => toUserName
      , is_grant      => true
      , privilege     => Acl_Privilege
    );
    dbms_output.put_line(
      'ACL created: ' || Acl_Name
    );
  end if;

  dbms_network_acl_admin.assign_acl(
    acl             => Acl_Name
    , host          => host
  );
  dbms_output.put_line(
    'host assigned with ACL "' || Acl_Name || '": ' || host
  );

  dbms_output.put_line('Grant to user "' || toUserName || '".');  

  -- Grant ACL to user
  isGranted := dbms_network_acl_admin.check_privilege(
    acl               => Acl_Name
    , user            => toUserName
    , privilege       => Acl_Privilege
  );
  if nullif( 1, isGranted) is not null then
    dbms_network_acl_admin.add_privilege(
      acl             => Acl_Name
      , principal     => toUserName
      , is_grant      => true
      , privilege     => Acl_Privilege
    );
    dbms_output.put_line(
      'ACL "' || Acl_Name || '" granted to user: ' || toUserName
    );
  end if;
end;
/
