declare

  opt opt_option_list_t := opt_option_list_t(
    moduleName => pkg_Mail.Module_Name
  );

  cursor dataCur is
    select
      t.option_short_name
    from
      table( opt.getOptionValue()) t
    where
      t.option_short_name in (
        'FaxSenderSmtpServer'
        , 'MassDistributionSmtpServer'
      )
    order by
      1
  ;

begin
  for rec in dataCur loop
    dbms_output.put_line(
      'delete option: ' || rec.option_short_name
    );
    opt.deleteOption( optionShortName => rec.option_short_name);
  end loop;
  commit;
end;
/
