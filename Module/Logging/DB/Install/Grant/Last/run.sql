-- script: Install/Grant/Last/run.sql
-- Выдает права на использование модуля.
--
-- Параметры:
-- toUserName                  - имя пользователя, которому выдаются права
--
-- Замечания:
--  - скрипт запускается под пользователем, которому принадлежат объекты модуля;
--

declare

  toUserName varchar2(30) := '&1';

  -- Список объектов для выдачи прав
  type ObjectListT is table of varchar2(30);

  objectList ObjectListT := ObjectListT(
    'pkg_Logging'
    , 'pkg_LoggingErrorStack'
    , 'lg_logger_t'
    , 'lg_destination'
    , 'lg_level'
    , 'v_lg_current_log'
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
      pkg_Error.ErrorStackInfo
      , 'Ошибка при выполнеии SQL:' || chr(10) || sqlText
      , true
    );
  end execSql;



begin
  while i is not null loop
    begin
      if objectList( i) like 'pkg\_%' escape '\'
            or objectList( i) like '%\_t' escape '\'
          then
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
        pkg_Error.ErrorStackInfo
        , 'Ошибка при выдаче прав на объект "' || objectList( i) || '".'
        , true
      );
    end;
    i := objectList.next( i);
  end loop;
end;
/
