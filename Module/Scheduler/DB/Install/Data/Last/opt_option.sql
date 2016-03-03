-- script: Install/Data/Last/opt_option.sql
-- Создает настроечные параметры модуля.
--
-- Параметры:
-- productionDbName           - имя промышленной БД, к которой относится
--                              выполняемая установка ( значение параметра
--                              установки <PRODUCTION_DB_NAME>)
--

define productionDbName = "&1"

declare

  productionDbName varchar2(30) := '&productionDbName';

  opt opt_option_list_t := opt_option_list_t(
    moduleSvnRoot => pkg_SchedulerMain.Module_SvnRoot
  );



  /*
    Добавляет опцию LocalRoleSuffix, если она не существует.
  */
  procedure addLocalRoleSuffix
  is

    localRoleSuffix varchar2(30);

  begin
    if opt.existsOption( pkg_SchedulerMain.LocalRoleSuffix_OptionSName) = 0 then
      dbms_output.put_line(
        'productionDbName: "' || productionDbName || '"'
      );
      localRoleSuffix :=
        case when productionDbName like '%___P' then
          substr( productionDbName, 1, length( productionDbName) - 1)
        else
          productionDbName
        end
      ;
      opt.addString(
        optionShortName       => pkg_SchedulerMain.LocalRoleSuffix_OptionSName
        , optionName          =>
            'Суффикс для ролей, с помощью которых выдаются права на все пакетные задания, созданные в локально установленном модуле Scheduler'
        , accessLevelCode     => opt_option_list_t.getReadAccessLevelCode()
        , optionDescription   =>
'При проверке прав доступа учитываются роли:

AdminAllBatch<LocalRoleSuffix>    - полные права
ExecuteAllBatch<LocalRoleSuffix>  - выполнение пакетных заданий
ShowAllBatch<LocalRoleSuffix>     - просмотр данных

где <LocalRoleSuffix> это значение опции.

Права даются на все пакетные задания, создаваемые в модуле Scheduler, в
котором используется значение опции. При этом подразумевается, что в
различных БД данная опция имеет различное значение, которое задается при
установке модуля Scheduler.

Пример:
в БД DbNameP опция имеет значение "DbName", в результате права на
все пакетные задания, созданные в БД DbNameP, можно выдать с помощью
ролей "AdminAllBatchDbName", "ExecuteAllBatchDbName",
"ShowAllBatchDbName".
'
        , stringValue         => localRoleSuffix
      );
      dbms_output.put_line(
        '"' || pkg_SchedulerMain.LocalRoleSuffix_OptionSName || '"'
        || ' option created with value: "' || localRoleSuffix || '"'
      );
    end if;
  end addLocalRoleSuffix;



-- main
begin
  if productionDbName is null then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Не указано имя промышленной БД, к которой относится установка'
        || ' ( productionDbName).'
    );
  end if;
  addLocalRoleSuffix();

  commit;
end;
/

undefine productionDbName
