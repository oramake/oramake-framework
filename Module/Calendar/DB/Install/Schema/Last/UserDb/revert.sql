-- script: Install/Schema/Last/UserDb/revert.sql
-- Отменяет установку модуля, удаляя созданные объекты схемы в
-- пользовательской БД.
--

-- Удаление публичного задания
-- ( если оно используется, то будет ошибка)
begin
  delete
    sch_job jb
  where
    jb.module_id = pkg_ModuleInfo.getModuleId(
      svnRoot => 'Oracle/Module/Calendar'
    )
  ;
  dbms_output.put_line(
    'job deleted: ' || sql%rowcount
  );
  commit;
end;
/

-- Удаление параметров модуля
begin
  opt_option_list_t( moduleSvnRoot => 'Oracle/Module/Calendar').deleteAll();
end;
/

-- Пакеты
drop package pkg_Calendar
/
