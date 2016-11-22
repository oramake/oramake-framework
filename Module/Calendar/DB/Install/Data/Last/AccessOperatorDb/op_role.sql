-- script: Install/Data/Last/AccessOperatorDb/op_role.sql
-- —оздает роли, используемые модулем.
--

declare

  -- „исло изменений
  nChanged integer := 0;



  /*
    ƒобавление или обновление роли.
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
    roleShortName => 'CdrUser'
    , roleName    =>
        'ѕользователь модул€ Calendar'
    , roleNameEn  =>
        'Calendar user'
    , description =>
        'ƒает права на просмотр данных по справочнику отклонений рабочих/выходных дней'
  );
  mergeRole(
    roleShortName => 'CdrAdministrator'
    , roleName    =>
        'јдминистратор модул€ Calendar'
    , roleNameEn  =>
        'Calendar administrator'
    , description =>
        'ƒает права на просмотр, редактирование, добавление и удаление данных по справочнику отклонений рабочих/выходных дней'
  );
  commit;
end;
/
