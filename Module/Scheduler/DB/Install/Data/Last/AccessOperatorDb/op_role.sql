-- script: Install/Data/Last/AccessOperatorDb/op_role.sql
-- Создает роли, используемые модулем (общие для всех БД).
--

prompt get local roles config...




prompt refresh roles...

declare


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

-- main
begin
  mergeRole(
    roleShortName => 'AllBatchAdmin'
    , roleName    =>
        'Администратор всех пакетных заданий во всех БД'
    , roleNameEn  =>
        'All batch admininstrator'
    , description =>
        'Пользователь с данной ролью имеет полные права на пакетные задания во всех БД'
  );
  mergeRole(
    roleShortName => 'SchShowBatch'
    , roleName    =>
        'Scheduler: доступ к форме «Пакетное задание»'
    , roleNameEn  =>
        'Scheduler: Access to batch form'
    , description =>
        'Пользователь с данной ролью имеет доступ к форме «Пакетное задание»'
  );
  mergeRole(
    roleShortName => 'SchShowBatchOption'
    , roleName    =>
        'Scheduler: доступ к закладке «Параметры» формы «Пакетное задание»'
    , roleNameEn  =>
        'Scheduler: Access to batch option form'
    , description =>
        'Пользователь с данной ролью имеет доступ к закладке «Параметры» формы «Пакетное задание»'
  );
  mergeRole(
    roleShortName => 'SchShowSchedule'
    , roleName    =>
        'Scheduler: доступ к закладке «Расписание» формы «Пакетное задание»'
    , roleNameEn  =>
        'Scheduler: Access to schedule form'
    , description =>
        'Пользователь с данной ролью имеет доступ к закладке «Расписание» формы «Пакетное задание»'
  );
  mergeRole(
    roleShortName => 'SchShowLog'
    , roleName    =>
        'Scheduler: доступ к закладке «Лог» формы «Пакетное задание»'
    , roleNameEn  =>
        'Scheduler: Access to log form'
    , description =>
        'Пользователь с данной ролью имеет доступ к закладке «Лог» формы «Пакетное задание»'
  );
  mergeRole(
    roleShortName => 'SchShowBatchRole'
    , roleName    =>
        'Scheduler: доступ к закладке «Батч - Роль» формы «Пакетное задание»'
    , roleNameEn  =>
        'Scheduler: Access to batch-role form'
    , description =>
        'Пользователь с данной ролью имеет доступ к закладке «Батч - Роль» формы «Пакетное задание»'
  );
  mergeRole(
    roleShortName => 'SchShowModuleRolePrivilege'
    , roleName    =>
        'Scheduler: доступ к форме «Права на пакетные задания модулей»'
    , roleNameEn  =>
        'Scheduler: Access to batch type -  role form'
    , description =>
        'Пользователь с данной ролью имеет доступ к форме «Права на пакетные задания модулей»'
  );

  dbms_output.put_line(
    'roles changed: ' || nChanged
  );
  commit;
end;
/
