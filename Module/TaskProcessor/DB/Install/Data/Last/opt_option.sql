declare

  opt opt_option_list_t := opt_option_list_t(
    moduleName => pkg_TaskProcessorBase.Module_Name
  );

begin
  opt.addNumber(
    optionShortName => pkg_TaskProcessorBase.MaxOpTpTaskExec_OptionSName
    , optionName    =>
        'Максимальное число одновременно выполняемых заданий одного типа от одного оператора ( по умолчанию без ограничений)'
    , numberValue   => null
  );
  commit;
end;
/
