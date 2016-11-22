declare

  optionList opt_option_list_t := opt_option_list_t(
    moduleName => pkg_Calendar.Module_Name
  );

begin
  optionList.addString(
    optionShortName => pkg_Calendar.SourceDbLink_OptionName
    , optionName => 'Линк к основной БД'
    , prodStringValue => 'ProdDb'
    , testStringValue => 'TestDb'
  );
end;
/
