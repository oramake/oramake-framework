define tableName = "&1"
define newTableName = "&2"


declare
  newTableName varchar2(30) := upper( '&newTableName');
  tableName varchar2(30) := upper( '&tableName');

  cursor curTable
  is
    select
      *
    from
      user_tables t
    where
      t.table_name = tableName
  ;

  /*
    Удаление триггеров.
  */
  procedure dropTrigger
  is
    cursor curTrigger
    is
      select
        *
      from
        user_triggers t
      where
        t.table_name = tableName
    ;

  -- dropTrigger
  begin
    for rec in curTrigger loop
      pkg_Common.outputMessage(
        'drop trigger ' || rec.trigger_name
      );
      execute immediate
        'drop trigger ' || rec.trigger_name
      ;
    end loop;
  end dropTrigger;

-- main
begin
  for rec in curTable loop
    -- Удаляем триггеры
    dropTrigger();
	-- Переименовываем таблицу
    pkg_Common.outputMessage(
      'rename table ' || rec.table_name || ' to ' || newTableName
    );
    execute immediate
      'alter table ' || rec.table_name || ' rename to ' || newTableName
    ;
  end loop;
end;
/


undefine tableName
undefine newTableName