declare

  optionList opt_option_list_t := opt_option_list_t(
    moduleName => pkg_Calendar.Module_Name
  );

begin
  optionList.addOptionString(
    moduleOptionName => pkg_Calendar.SourceDbLink_OptionName
    , optionName => 'Линк к основной БД'
    , defaultStringValue =>
        case when
          pkg_Common.isProduction() = 1
        then
          'ProdDb'
        else
          'TestDb'
        end
  );
end;
/
