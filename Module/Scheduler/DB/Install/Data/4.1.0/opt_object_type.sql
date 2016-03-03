begin
  dbms_output.put_line(
    'changed: '
    || opt_option_list_t(
        moduleSvnRoot => pkg_SchedulerMain.Module_SvnRoot
      ).mergeObjectType(
        objectTypeShortName => pkg_SchedulerMain.Batch_OptionObjTypeSName
        , objectTypeName    => 'Пакетное задание'
      )
  );
  commit;
end;
/
