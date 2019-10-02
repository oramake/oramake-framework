-- script: ModuleConfig/Option/opt_option.sql
-- —оздает настроечные параметры модул€.
--
-- ѕараметры:
-- productionDbName           - им€ промышленной Ѕƒ, к которой относитс€
--                              выполн€ема€ установка ( значение параметра
--                              установки <PRODUCTION_DB_NAME>)
--
-- «амечани€:
--  - значение дл€ параметра <pkg_OptionMain.LocalRoleSuffix_OptionSName>
--    определ€етс€ согласно настройкам, заданным скриптом
--    <ModuleConfig/Option/set-optDbRoleSuffixList.sql>,
--    по значению productionDbName с учетом текущей схемы, при этом
--    если параметру уже было присвоено значение, отличное от null, то оно не
--    измен€етс€;
--

define productionDbName = "&1"



prompt get local roles config...

@@set-optDbRoleSuffixList.sql



prompt refresh options...

declare

  productionDbName varchar2(30) := '&productionDbName';

  opt opt_option_list_t := opt_option_list_t(
    moduleSvnRoot => pkg_OptionMain.Module_SvnRoot
  );



  /*
    ”станавливает значение параметра LocalRoleSuffix согласно настройкам.
  */
  procedure setLocalRoleSuffix
  is

    newValue varchar2(100);



    /*
      ќпредел€ет новое значение параметра.
    */
    procedure getNewValue
    is

      findDbName varchar2(100);
      findSchema varchar2(100);

      prodDbName varchar2(100);
      roleSuffix varchar2(100);

    begin
      findDbName := upper( trim( productionDbName));
      findSchema :=
        upper( sys_context( 'USERENV', 'CURRENT_SCHEMA'))
        || '@' || findDbName
      ;
      loop
        fetch :optDbRoleSuffixList into prodDbName, roleSuffix;
        exit when :optDbRoleSuffixList%notfound;
        if upper( trim( prodDbName)) = findSchema then
          newValue := roleSuffix;
          -- выходим, т.к. найдено наиболее точное совпадение
          exit;
        elsif upper( trim( prodDbName)) = findDbName then
          newValue := roleSuffix;
        end if;
      end loop;
      close :optDbRoleSuffixList;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , 'ќшибка при определении значени€ параметра согласно настройкам.'
        , true
      );
    end getNewValue;



  -- setLocalRoleSuffix
  begin
    dbms_output.put_line(
      'productionDbName: "' || productionDbName || '"'
    );
    if productionDbName is not null then
      getNewValue();
    end if;

    if opt.existsOption( pkg_OptionMain.LocalRoleSuffix_OptionSName) = 0 then
      opt.addString(
        optionShortName       => pkg_OptionMain.LocalRoleSuffix_OptionSName
        , optionName          =>
            '—уффикс дл€ ролей, с помощью которых выдаютс€ права на все параметры, созданные в локально установленном модуле Option'
        , accessLevelCode     => opt_option_list_t.getReadAccessLevelCode()
        , optionDescription   =>
'ѕри проверке прав доступа учитываютс€ роли:

OptAdminAllOption<LocalRoleSuffix>    - полные права
OptShowAllOption<LocalRoleSuffix>     - просмотр данных

где <LocalRoleSuffix> это значение данного параметра.

ѕрава даютс€ на все параметры, создаваемые в модуле Option, в котором задан
данный параметр. ѕри этом подразумеваетс€, что в различных Ѕƒ данный
параметр имеет различное значение, которое задаетс€ при установке модул€
Option.

ѕример:
в Ѕƒ DbNameP параметр имеет значение "DbName", в результате права на
все параметры, созданные в Ѕƒ DbNameP, можно выдать с помощью
ролей "OptAdminAllOptionDbName" и "OptShowAllOptionDbName".
'
        , stringValue         => newValue
      );
      dbms_output.put_line(
        '"' || pkg_OptionMain.LocalRoleSuffix_OptionSName || '"'
        || ' option created with value: "' || newValue || '"'
      );
    elsif newValue is not null then
      opt.setString(
        optionShortName => pkg_OptionMain.LocalRoleSuffix_OptionSName
        , stringValue   => newValue
      );
      dbms_output.put_line(
        '"' || pkg_OptionMain.LocalRoleSuffix_OptionSName || '"'
        || ' option set value: "' || newValue || '"'
      );
    end if;
  end setLocalRoleSuffix;



-- main
begin

  --  ”станавливает значение параметра LocalRoleSuffix, если оно не было
  --  задано ранее отличным от null.
  if opt.getString(
          pkg_OptionMain.LocalRoleSuffix_OptionSName
          , raiseNotFoundFlag => 0
        )
        is null
      then
    setLocalRoleSuffix();
  end if;

  commit;
end;
/

undefine productionDbName
