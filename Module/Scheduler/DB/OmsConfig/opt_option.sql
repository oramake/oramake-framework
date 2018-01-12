-- ModuleConfig/Scheduler/opt_option.sql
-- —оздает настроечные параметры модул€ Scheduler, специфичные дл€ Ѕƒ или
-- пользовател€ и Ѕƒ.
--
-- ѕараметры:
-- productionDbName           - им€ промышленной Ѕƒ, к которой относитс€
--                              выполн€ема€ установка ( значение параметра
--                              установки <PRODUCTION_DB_NAME>)
--
-- «амечани€:
--  - значение дл€ параметра <pkg_SchedulerMain.LocalRoleSuffix_OptSName>
--    определ€етс€ согласно настройкам, заданным скриптом
--    <ModuleConfig/Scheduler/set-schDbRoleSuffixList.sql>;
--    по значению productionDbName с учетом текущей схемы, при этом
--    если параметру уже было присвоено значение, отличное от null, то оно не
--    измен€етс€;
--

define productionDbName = "&1"



prompt get local roles config...

@@set-schDbRoleSuffixList.sql



prompt refresh options...

declare

  productionDbName varchar2(30) := '&productionDbName';

  opt opt_option_list_t := opt_option_list_t(
    moduleSvnRoot => pkg_SchedulerMain.Module_SvnRoot
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
        fetch :schDbRoleSuffixList into prodDbName, roleSuffix;
        exit when :schDbRoleSuffixList%notfound;
        if upper( trim( prodDbName)) = findSchema then
          newValue := roleSuffix;
          -- выходим, т.к. найдено наиболее точное совпадение
          exit;
        elsif upper( trim( prodDbName)) = findDbName then
          newValue := roleSuffix;
        end if;
      end loop;
      close :schDbRoleSuffixList;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , 'ќшибка при определении значени€ параметра согласно настройкам.'
        , true
      );
    end getNewValue;



  -- setLocalRoleSuffix
  begin
    if productionDbName is null then
      raise_application_error(
        pkg_Error.IllegalArgument
        , 'Ќе удалось определить им€ промышленной Ѕƒ, к которой относитс€'
          || ' установка ('
          || ' можно указать с помощью параметра установки PRODUCTION_DB_NAME'
          || ').'
      );
    end if;
    dbms_output.put_line(
      'productionDbName: "' || productionDbName || '"'
    );
    getNewValue();

    if opt.existsOption( pkg_SchedulerMain.LocalRoleSuffix_OptSName) = 0 then
      opt.addString(
        optionShortName       => pkg_SchedulerMain.LocalRoleSuffix_OptSName
        , optionName          =>
            '—уффикс дл€ ролей, с помощью которых выдаютс€ права на все пакетные задани€, созданные в локально установленном модуле Scheduler'
        , accessLevelCode     => opt_option_list_t.getReadAccessLevelCode()
        , optionDescription   =>
'ѕри проверке прав доступа учитываютс€ роли:

AdminAllBatch<LocalRoleSuffix>    - полные права
ExecuteAllBatch<LocalRoleSuffix>  - выполнение пакетных заданий
ShowAllBatch<LocalRoleSuffix>     - просмотр данных

где <LocalRoleSuffix> это значение данного параметра.

ѕрава даютс€ на все пакетные задани€, создаваемые в модуле Scheduler, в котором задан данный параметр. ѕри этом подразумеваетс€, что дл€ различных установок модул€ параметр может иметь различное значение, которое задаетс€ при установке модул€ Scheduler.

ѕример:
дл€ установок в Ѕƒ ProdDb параметр имеет значение "Prod", в результате права на все пакетные задани€, созданные в Ѕƒ ProdDb, можно выдать с помощью ролей "AdminAllBatchProd", "ExecuteAllBatchProd", "ShowAllBatchProd".
'
        , stringValue         => newValue
      );
      dbms_output.put_line(
        '"' || pkg_SchedulerMain.LocalRoleSuffix_OptSName || '"'
        || ' option created with value: "' || newValue || '"'
      );
    elsif newValue is not null then
      opt.setString(
        optionShortName => pkg_SchedulerMain.LocalRoleSuffix_OptSName
        , stringValue   => newValue
      );
      dbms_output.put_line(
        '"' || pkg_SchedulerMain.LocalRoleSuffix_OptSName || '"'
        || ' option set value: "' || newValue || '"'
      );
    end if;
  end setLocalRoleSuffix;



-- main
begin

  --  ”станавливает значение параметра LocalRoleSuffix, если оно не было
  --  задано ранее отличным от null.
  if opt.getString(
          pkg_SchedulerMain.LocalRoleSuffix_OptSName
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
