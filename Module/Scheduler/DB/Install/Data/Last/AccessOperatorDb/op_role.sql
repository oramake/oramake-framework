declare

  cursor localRoleCur is
    select
      db.column_value as db_name
      , pr.column_value as privilege_name
      , pr.column_value || 'AllBatch' || db.column_value
        as short_name
      , 'Батч: '
        || case pr.column_value
              when 'Admin'    then 'Администрирование'
              when 'Execute'  then 'Запуск'
              when 'Show'     then 'Просмотр'
           end
        || ' всех батчей ' || db.column_value
        as role_name
      , 'Batch: '
        || case pr.column_value
              when 'Admin'    then 'Administration of'
              when 'Execute'  then 'Execute'
              when 'Show'     then 'View'
           end
        || ' all batches ' || db.column_value
        as role_name_en
      , 'Доступ к '
        || case pr.column_value
              when 'Admin'    then 'администрированию'
              when 'Execute'  then 'запуску'
              when 'Show'     then 'просмотру'
           end
        || ' всех батчей ' || db.column_value
        || '. Для АМ'
        as description
    from
      table( cmn_string_table_t(
          'DbName1'
          , 'DbName2'
          , 'DbName3'
        )) db
      cross join table( cmn_string_table_t(
          'Admin'
          , 'Execute'
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
    shortName     => 'AllBatchAdmin'
    , roleName    =>
        'Администратор всех пакетных заданий во всех БД'
    , roleNameEn  =>
        'All batch admininstrator'
    , description =>
        'Пользователь с данной ролью имеет полные права на пакетные задания во всех БД'
  );
  addRole(
    shortName     => 'SchShowBatch'
    , roleName    =>
        'Scheduler: доступ к форме «Пакетное задание»'
    , roleNameEn  =>
        'Scheduler: Access to batch form'
    , description =>
        'Пользователь с данной ролью имеет доступ к форме «Пакетное задание»'
  );
  addRole(
    shortName     => 'SchShowBatchOption'
    , roleName    =>
        'Scheduler: доступ к закладке «Параметры» формы «Пакетное задание»'
    , roleNameEn  =>
        'Scheduler: Access to batch option form'
    , description =>
        'Пользователь с данной ролью имеет доступ к закладке «Параметры» формы «Пакетное задание»'
  );
  addRole(
    shortName     => 'SchShowSchedule'
    , roleName    =>
        'Scheduler: доступ к закладке «Расписание» формы «Пакетное задание»'
    , roleNameEn  =>
        'Scheduler: Access to schedule form'
    , description =>
        'Пользователь с данной ролью имеет доступ к закладке «Расписание» формы «Пакетное задание»'
  );
  addRole(
    shortName     => 'SchShowLog'
    , roleName    =>
        'Scheduler: доступ к закладке «Лог» формы «Пакетное задание»'
    , roleNameEn  =>
        'Scheduler: Access to log form'
    , description =>
        'Пользователь с данной ролью имеет доступ к закладке «Лог» формы «Пакетное задание»'
  );
  addRole(
    shortName     => 'SchShowBatchRole'
    , roleName    =>
        'Scheduler: доступ к закладке «Батч - Роль» формы «Пакетное задание»'
    , roleNameEn  =>
        'Scheduler: Access to batch-role form'
    , description =>
        'Пользователь с данной ролью имеет доступ к закладке «Батч - Роль» формы «Пакетное задание»'
  );
  addRole(
    shortName     => 'SchShowModuleRolePrivilege'
    , roleName    =>
        'Scheduler: доступ к форме «Права на пакетные задания модулей»'
    , roleNameEn  =>
        'Scheduler: Access to batch type -  role form'
    , description =>
        'Пользователь с данной ролью имеет доступ к форме «Права на пакетные задания модулей»'
    , oldShortName => 'SchShowBatchTypeRole'
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
