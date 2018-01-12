-- script: ModuleConfig/Scheduler/op_role.sql
-- Создает роли для каждой БД, используемые модулем.
--
-- Замечания:
--  - при создании ролей используются настройки, задаваемые скриптом
--    <ModuleConfig/Scheduler/set-schDbRoleSuffixList.sql>;
--

prompt get local roles config...

@@set-schDbRoleSuffixList.sql


prompt refresh roles...

declare

  cursor localRoleCur(
        localRoleSuffix varchar2
      )
      is
    select
      pr.column_value as privilege_name
      , pr.column_value || 'AllBatch' || localRoleSuffix
        as role_short_name
      , 'Батч: '
        || case pr.column_value
              when 'Admin'    then 'Администрирование'
              when 'Execute'  then 'Запуск'
              when 'Show'     then 'Просмотр'
           end
        || ' всех батчей ' || localRoleSuffix
        as role_name
      , 'Batch: '
        || case pr.column_value
              when 'Admin'    then 'Administration of'
              when 'Execute'  then 'Execute'
              when 'Show'     then 'View'
           end
        || ' all batches ' || localRoleSuffix
        as role_name_en
      , 'Доступ к '
        || case pr.column_value
              when 'Admin'    then 'администрированию'
              when 'Execute'  then 'запуску'
              when 'Show'     then 'просмотру'
           end
        || ' всех батчей в ' || localRoleSuffix
        as description
    from
      table( cmn_string_table_t(
        'Admin'
        , 'Execute'
        , 'Show'
      )) pr
    order by
      1
  ;

  -- Число изменений
  nChanged integer := 0;



  /*
    Добавление или обновление роли.
  */
  procedure mergeRole(
    roleShortName varchar2
    , roleName varchar2
    , roleNameEn varchar2
    , description varchar2
  )
  is

    changedFlag integer;

  begin
    changedFlag := pkg_AccessOperator.mergeRole(
      roleShortName   => roleShortName
      , roleName      => roleName
      , roleNameEn    => roleNameEn
      , description   => description
    );
    if changedFlag = 1 then
      dbms_output.put_line(
        'changed role: ' || roleShortName
      );
      nChanged := nChanged + 1;
    else
      dbms_output.put_line(
        'checked role: ' || roleShortName
      );
    end if;
  end mergeRole;



  /*
    Обновляет локальные роли.
  */
  procedure refreshLocalRole
  is

    prodDbName varchar2(100);
    roleSuffix varchar2(100);

    nRow pls_integer := 0;

  begin
    dbms_output.put_line(
      'local roles:'
    );
    loop
      fetch :schDbRoleSuffixList into prodDbName, roleSuffix;
      exit when :schDbRoleSuffixList%notfound;
      nRow := nRow + 1;
      prodDbName := trim( prodDbName);
      roleSuffix := trim( roleSuffix);
      if roleSuffix is null then
        raise_application_error(
          pkg_Error.IllegalArgument
          , 'Не задан local_role_suffix ('
            || ' nRow=' || nRow
            || ', production_db_name="' || prodDbName || '"'
            || ').'
        );
      end if;
      for rec in localRoleCur(
            localRoleSuffix   => roleSuffix
          )
          loop
        mergeRole(
          roleShortName => rec.role_short_name
          , roleName    => rec.role_name
          , roleNameEn  => rec.role_name_en
          , description => rec.description
        );
      end loop;
    end loop;
    close :schDbRoleSuffixList;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Ошибка при обновлении локальных ролей.'
      , true
    );
  end refreshLocalRole;



-- main
begin

  refreshLocalRole();

  dbms_output.put_line(
    'roles changed: ' || nChanged
  );
  commit;
end;
/
