-- script: Install/Data/Last/AccessOperatorDb/op_role.sql
-- Создает роли, используемые модулем.
--

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
    roleShortName     => 'OptShowOption'
    , roleName    =>
        'Параметр: Доступ к форме «Параметр»'
    , roleNameEn  =>
        'Option: Access to options form'
    , description =>
        'Пользователь с данной ролью имеет доступ к форме «Параметр»'
  );

  mergeRole(
    roleShortName     => 'GlobalOptionAdmin'
    , roleName    =>
        'Параметр: Администрирование всех параметров'
    , roleNameEn  =>
        'Option: All option admininstrator'
    , description =>
        'Пользователь с данной ролью имеет права на администрирование параметров модулей во всех БД'
  );

  mergeRole(
    roleShortName     => 'OptShowAllOption'
    , roleName    =>
        'Параметр: Просмотр всех параметров'
    , roleNameEn  =>
        'Option: Show all option'
    , description =>
        'Пользователь с данной ролью имеет право на просмотр параметров модулей во всех БД'
  );

  dbms_output.put_line(
    'roles changed: ' || nChanged
  );
  commit;
end;
/
