-- script: Install/Data/Last/opt_option.sql
-- Создает настроечные параметры модуля.
--
-- Параметры:
-- productionDbName           - имя промышленной БД, к которой относится
--                              выполняемая установка ( значение параметра
--                              установки <PRODUCTION_DB_NAME>)
--
-- Замечания:
--  - значение для параметра <pkg_OptionMain.LocalRoleSuffix_OptionSName>
--    определяется согласно настройкам, заданным скриптом
--    <Install/Data/Last/Custom/set-optDbRoleSuffixList.sql>,
--    и значению productionDbName;
--

define productionDbName = "&1"



prompt get local roles config...

@Install/Data/Last/Custom/set-optDbRoleSuffixList.sql



prompt refresh options...

declare

  productionDbName varchar2(30) := '&productionDbName';

  opt opt_option_list_t := opt_option_list_t(
    moduleSvnRoot => pkg_OptionMain.Module_SvnRoot
  );



  /*
    Создает/обновляет значение параметра LocalRoleSuffix.
  */
  procedure mergeLocalRoleSuffix
  is

    newValue varchar2(100);
    oldValue varchar2(100);



    /*
      Определяет новое значение параметра.
    */
    procedure getNewValue
    is

      prodDbName varchar2(100);
      roleSuffix varchar2(100);

    begin
      loop
        fetch :optDbRoleSuffixList into prodDbName, roleSuffix;
        exit when :optDbRoleSuffixList%notfound;
        if upper( trim( prodDbName)) = trim( upper( productionDbName)) then
          newValue := roleSuffix;
          exit;
        end if;
      end loop;
      close :optDbRoleSuffixList;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , 'Ошибка при определении значения параметра согласно настройкам.'
        , true
      );
    end getNewValue;



  -- mergeLocalRoleSuffix
  begin
    dbms_output.put_line(
      'productionDbName: "' || productionDbName || '"'
    );
    getNewValue();

    if opt.existsOption( pkg_OptionMain.LocalRoleSuffix_OptionSName) = 0 then
      opt.addString(
        optionShortName       => pkg_OptionMain.LocalRoleSuffix_OptionSName
        , optionName          =>
            'Суффикс для ролей, с помощью которых выдаются права на все параметры, созданные в локально установленном модуле Option'
        , accessLevelCode     => opt_option_list_t.getReadAccessLevelCode()
        , optionDescription   =>
'При проверке прав доступа учитываются роли:

OptAdminAllOption<LocalRoleSuffix>    - полные права
OptShowAllOption<LocalRoleSuffix>     - просмотр данных

где <LocalRoleSuffix> это значение данного параметра.

Права даются на все параметры, создаваемые в модуле Option, в котором задан
данный параметр. При этом подразумевается, что в различных БД данный
параметр имеет различное значение, которое задается при установке модуля
Option.

Пример:
в БД DbNameP параметр имеет значение "DbName", в результате права на
все параметры, созданные в БД DbNameP, можно выдать с помощью
ролей "OptAdminAllOptionDbName" и "OptShowAllOptionDbName".
'
        , stringValue         => newValue
      );
      dbms_output.put_line(
        '"' || pkg_OptionMain.LocalRoleSuffix_OptionSName || '"'
        || ' option created with value: "' || newValue || '"'
      );
    else
      oldValue := opt.getString( pkg_OptionMain.LocalRoleSuffix_OptionSName);
      if coalesce(
              oldValue != newValue
              , coalesce( oldValue, newValue) is not null
            )
          then
        opt.setString(
          optionShortName => pkg_OptionMain.LocalRoleSuffix_OptionSName
          , stringValue   => newValue
        );
        dbms_output.put_line(
          '"' || pkg_OptionMain.LocalRoleSuffix_OptionSName || '"'
          || ' option value changed: "' || newValue || '"'
        );
      end if;
    end if;
  end mergeLocalRoleSuffix;



-- main
begin
  if productionDbName is null then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Не удалось определить имя промышленной БД, к которой относится'
        || ' установка ('
        || ' можно указать с помощью параметра установки PRODUCTION_DB_NAME'
        || ').'
    );
  end if;

  mergeLocalRoleSuffix();

  commit;
end;
/

undefine productionDbName
