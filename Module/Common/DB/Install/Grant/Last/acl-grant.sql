-- script: acl-grant
-- Создаёт acl-список и добавляет в него smtp-сервер для отправки
-- писем с помощью <pkg_Common>, если доступен пакет dbms_network_acl_admin
--
-- Параметры:
--		&1 - имя схемы, где установлен pkg_Common
--
define userName = &1

declare
  sqlTextBase varchar2( 32767) :=
  '
  begin
    $(procedureCall)
      acl => ''pkg_Common.acl.xml''
      , principal => upper(''' || '&userName' || ''')
      , is_grant => TRUE
      , privilege => ''connect''
    );
  end;
  ';
  sqlTextCreate varchar2( 32767) :=
    replace(
        sqlTextBase
        , '$(procedureCall)'
        ,
        '
          dbms_network_acl_admin.create_acl(
            description => ''Common ACL'',
        '
      );
  sqlTextGrant varchar2( 32767) :=
    replace(
        sqlTextBase
        , '$(procedureCall)'
        ,
        '
          dbms_network_acl_admin.add_privilege(
        '
      );
  sqlTextAssign varchar2( 32767) :=
  '
  begin
    dbms_network_acl_admin.unassign_acl(
      acl => ''pkg_Common.acl.xml''
    );
    dbms_network_acl_admin.assign_acl(
      acl => ''pkg_Common.acl.xml''
      , host =>  pkg_Common.getSmtpServer()
    );
  end;
  ';
  isAclAvailable boolean;
  countAcl integer;
begin
  begin
    execute immediate
     'begin if 1=0 then ' || sqlTextCreate || ' end if;end;';
    isAclAvailable := true;
  exception when others then
    if sqlcode = -6550 then
      pkg_Common.outputMessage( 'dbms_network_acl_admin is not available');
      isAclAvailable := false;
    else
      raise;
    end if;
  end;
  if isAclAvailable then
    execute immediate
    '
    select
      count(1)
    from
      dba_network_acls
    where
      acl = ''/sys/acls/pkg_Common.acl.xml''
    '
    into
      countAcl;
    if countAcl = 0 then
      execute immediate sqlTextCreate;
      execute immediate sqlTextAssign;
    else
      execute immediate sqlTextAssign;
      execute immediate sqlTextGrant;
    end if;
  end if;
end;
/
commit
/
undefine userName



