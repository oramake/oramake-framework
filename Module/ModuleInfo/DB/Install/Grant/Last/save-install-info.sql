-- script: Install/Grant/Last/save-install-info.sql
-- Выдает права на просмотр и сохранение информации об установках модулей.
--
-- Параметры:
-- toUserName                 - имя пользователя, которому выдаются права
--

declare

  toUserName varchar2(30) := '&1';

  -- Список объектов для выдачи прав
  type ObjectListT is table of varchar2(30);

  objectList ObjectListT := ObjectListT(
    'pkg_ModuleInfo'
    , 'pkg_ModuleInstall'
    , 'v_mod_app_install_result'
    , 'v_mod_app_install_version'
    , 'v_mod_install_action'
    , 'v_mod_install_file'
    , 'v_mod_install_module'
    , 'v_mod_install_object'
    , 'v_mod_install_result'
    , 'v_mod_install_version'
    , 'v_mod_module'
    , 'v_mod_source_file'
  );

  -- Признак выдачи прав для всех пользователей
  isToPublic boolean := upper( toUserName) = 'PUBLIC';

  -- Индекс текущего объекта в списке
  i pls_integer := objectList.first();



  /*
    Выполняет SQL с DDL-командой.
  */
  procedure execSql(
    sqlText varchar2
  )
  is
  begin
    execute immediate sqlText;
  exception when others then
    raise_application_error(
      pkg_ModuleInfoInternal.ErrorStackInfo_Error
      , 'Ошибка при выполнеии SQL:' || chr(10) || sqlText
      , true
    );
  end execSql;



begin
  while i is not null loop
    begin
      if objectList( i) like 'pkg_%' then
        execSql(
          'grant execute on ' || objectList( i) || ' to ' || toUserName
        );
      else
        execSql(
          'grant select on ' || objectList( i) || ' to ' || toUserName
        );
      end if;
      if isToPublic then
        execSql(
          'create or replace public synonym ' || objectList( i)
          || ' for ' || objectList( i)
        );
      else
        execSql(
          'create or replace synonym ' || toUserName || '.' || objectList( i)
          || ' for ' || objectList( i)
        );
      end if;
      dbms_output.put_line(
        'privs granted: ' || objectList( i)
      );
    exception when others then
      raise_application_error(
        pkg_ModuleInfoInternal.ErrorStackInfo_Error
        , 'Ошибка при выдаче прав на объект "' || objectList( i) || '".'
        , true
      );
    end;
    i := objectList.next( i);
  end loop;
end;
/
