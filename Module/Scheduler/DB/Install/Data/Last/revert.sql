-- Удаление параметров модуля
begin
  opt_option_list_t(
    moduleSvnRoot => 'Oracle/Module/Scheduler'
  ).deleteAll();
end;
/
