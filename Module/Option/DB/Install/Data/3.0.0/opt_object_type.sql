begin
  dbms_output.put_line(
    'changed: '
    || opt_option_list_t(
        moduleSvnRoot => pkg_OptionMain.Module_SvnRoot
      ).mergeObjectType(
        objectTypeShortName => opt_option_list_t.getPlsqlObjectTypeSName()
        , objectTypeName    => 'PL/SQL объект'
      )
  );
  commit;
end;
/
