-- Скрипт копирования пользователя Oracle
--
-- CopyUsername - имя копируемого пользователя
-- NewUsername - имя нового пользователя

declare
  copyUsername varchar2(30) := '&CopyUsername';
  newUsername varchar2(30) := '&NewUsername';



  /*
    Копирование пользователя
  */
  procedure copyUser
  is
    defaultTablespace dba_users.default_tablespace%type;
    temporaryTablespace dba_users.temporary_tablespace%type;
    userProfile dba_users.profile%type;

  -- copyUser
  begin
    select
      u.default_tablespace
      , u.temporary_tablespace
      , u.profile
    into
      defaultTablespace
      , temporaryTablespace
      , userProfile
    from
      dba_users u
    where
      u.username = upper( copyUsername)
    ;
    execute immediate
      'create user ' || newUsername
      || ' identified by ' || lower( newUsername)
      || ' default tablespace ' || defaultTablespace
      || ' temporary tablespace ' || temporaryTablespace
      || ' profile ' || userProfile
    ;
  exception
    when no_data_found then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , 'Пользователя "' || copyUsername || '"  не существует'
        , true
      );
  end copyUser;

  /*
    Копирование квот пользователя
  */
  procedure copyUserQotas
  is
    cursor curQuotas
    is
      select
        q.tablespace_name
      from
        dba_ts_quotas q
      where
        q.username = upper( copyUsername)
    ;

  -- copyUserQotas
  begin
    for rec in curQuotas loop
      execute immediate
        'alter user ' || newUsername || ' quota unlimited on ' || rec.tablespace_name
      ;
    end loop;
  end copyUserQotas;

  /*
    Копирование системных привилегий
  */
  procedure copyUserSystemPrivs
  is
    cursor curSysPrivs
    is
      select
        p.privilege
      from
        dba_sys_privs p
      where
        p.grantee = upper( copyUsername)
    ;

  -- copyUserSystemPrivs
  begin
    for rec in curSysPrivs loop
      execute immediate
        'grant ' || rec.privilege || ' to ' || newUsername
      ;
    end loop;
  end copyUserSystemPrivs;

  /*
    Копирование объектных привилегий
  */
  procedure copyUserObjectsPrivs
  is
    cursor curObjectsPrivs
    is
      select
        p.owner
        , p.table_name as object_name
        , p.privilege
      from
        dba_tab_privs p
      where
        p.grantee = upper( copyUsername)
    ;

  -- copyUserObjectsPrivs
  begin
    for rec in curObjectsPrivs loop
      execute immediate
        'grant ' || rec.privilege || ' on ' || rec.owner || '.' || rec.object_name || ' to ' || newUsername
      ;
    end loop;
  end copyUserObjectsPrivs;

-- main
begin
  pkg_Common.outputMessage( 'create user ' || newUsername || ' as copy ' || copyUsername);
  -- Копируем пользователя
  copyUser();
  -- Копируем квоты пользователя
  copyUserQotas();
  -- Копируем системные привилегии
  copyUserSystemPrivs();
  -- Копируем объектные привилегии
  copyUserObjectsPrivs();
end;
/