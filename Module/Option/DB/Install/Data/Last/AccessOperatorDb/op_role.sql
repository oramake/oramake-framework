declare

  cursor localRoleCur is
    select
      db.column_value as db_name
      , pr.column_value as privilege_name
      , 'Opt' || pr.column_value || 'AllOption' || db.column_value
        as short_name
      , 'Параметр: '
        || case pr.column_value
              when 'Admin'    then 'Администрирование'
              when 'Show'     then 'Просмотр'
           end
        || ' всех параметров ' || db.column_value
        as role_name
      , 'Option: '
        || case pr.column_value
              when 'Admin'    then 'Administration of'
              when 'Show'     then 'View'
           end
        || ' all options ' || db.column_value
        as role_name_en
      , 'Доступ к '
        || case pr.column_value
              when 'Admin'    then 'администрированию'
              when 'Show'     then 'просмотру'
           end
        || ' всех параметров модулей в ' || db.column_value
        as description
    from
      table( cmn_string_table_t(
          -- все промышленные БД, в которые устанавливается модуль
          'DbName1'
          , 'DbName2'
          , 'DbName3'
        )) db
      cross join table( cmn_string_table_t(
          'Admin'
          , 'Show'
        )) pr
    order by
      1, 2
  ;

  -- Число добавленный ролей
  nCreated integer := 0;

  -- Число ранее созданных ролей
  nExists integer := 0;



  /*
    Добавляет роль в случае ее отсутствия.
  */
  procedure addRole(
    shortName varchar2
    , roleName varchar2
    , roleNameEn varchar2
    , description varchar2
    , oldShortName varchar2 := null
  )
  is

    cursor roleCur is
      select
        t.*
      from
        op_role t
      where
        t.short_name in ( oldShortName, shortName)
      order by
        nullif( t.short_name, oldShortName) nulls first
    ;

    rec roleCur%rowtype;

  begin
    open roleCur;
    fetch roleCur into rec;
    close roleCur;
    if rec.role_id is null then
      rec.role_id := pkg_AccessOperator.createRole(
        shortName     => shortName
        , roleName    => roleName
        , roleNameEn  => roleNameEn
        , description => description
        , operatorId  => pkg_Operator.getCurrentUserId()
      );
      dbms_output.put_line(
        'role created: ' || shortName || ' ( role_id=' || rec.role_id || ')'
      );
      nCreated := nCreated + 1;
    else
      if coalesce( rec.short_name != shortName
              , coalesce( rec.short_name, shortName) is not null)
          or coalesce( rec.role_name != roleName
              , coalesce( rec.role_name, roleName) is not null)
          or coalesce( rec.role_name_en != roleNameEn
              , coalesce( rec.role_name_en, roleNameEn) is not null)
          or coalesce( rec.description != description
              , coalesce( rec.description, description) is not null)
          then
        pkg_AccessOperator.updateRole(
          roleId        => rec.role_id
          , shortName   => shortName
          , roleName    => roleName
          , roleNameEn  => roleNameEn
          , description => description
          , operatorId  => pkg_Operator.getCurrentUserId()
        );
        dbms_output.put_line(
          'role updated: ' || shortName || ' ( role_id=' || rec.role_id || ')'
        );
      end if;
      nExists := nExists + 1;
    end if;
  end addRole;



-- main
begin
  addRole(
    shortName     => 'OptShowOption'
    , roleName    =>
        'Параметр: Доступ к форме «Параметр»'
    , roleNameEn  =>
        'Option: Access to options form'
    , description =>
        'Пользователь с данной ролью имеет доступ к форме «Параметр»'
  );

  addRole(
    shortName     => 'GlobalOptionAdmin'
    , roleName    =>
        'Параметр: Администрирование всех параметров'
    , roleNameEn  =>
        'Option: All option admininstrator'
    , description =>
        'Пользователь с данной ролью имеет права на администрирование параметров модулей во всех БД'
  );

  addRole(
    shortName     => 'OptShowAllOption'
    , roleName    =>
        'Параметр: Просмотр всех параметров'
    , roleNameEn  =>
        'Option: Show all option'
    , description =>
        'Пользователь с данной ролью имеет право на просмотр параметров модулей во всех БД'
  );

  for rec in localRoleCur loop
    addRole(
      shortName     => rec.short_name
      , roleName    => rec.role_name
      , roleNameEn  => rec.role_name_en
      , description => rec.description
    );
  end loop;

  dbms_output.put_line(
    'roles created: ' || nCreated
    || ' ( already exists: ' || nExists || ')'
  );
  commit;
end;
/
