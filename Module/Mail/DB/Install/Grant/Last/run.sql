-- script: Install/Grant/Last/run.sql
-- Выдает права на использование модуля.
--
-- Параметры:
-- toUserName                 - имя пользователя, которому выдаются права
--                              ( "public" для выдачи прав всем пользователям)
--
-- Замечания:
--   - для успешного выполнения скрипта для "public" требуются права на
--    создание публичных синонимов;
--



declare

  toUserName varchar2(30) := '&1';

  -- Список прав на объекты в формате "<object_name>[:<privs_list>]", где
  -- object_name        - имя объекта, на который выдаются права
  -- privs_list         - список прав ( через запятую), по умолчанию
  --                      "execute" для объектов в именем "pkg_%" и
  --                      "select" для остальных объектов
  --
  type PrivsListT is table of varchar2(1000);

  privsList PrivsListT := PrivsListT(
    'pkg_Mail'
  );

  -- Признак выдачи прав для всех пользователей
  isToPublic boolean := upper( toUserName) = 'PUBLIC';

  -- Индекс текущего объекта в списке
  i pls_integer := privsList.first();

  -- Имя объекта
  objectName varchar2(30);

  -- Права, выдаваемые на объект
  objectPrivs varchar2(1000);



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
  dbms_output.put_line(
    'granted to ' || toUserName || ':'
  );
  while i is not null loop
    begin
      objectName :=
        trim( substr( privsList( i), 1, instr( privsList( i) || ':', ':') - 1))
      ;
      objectPrivs := coalesce(
        trim( substr( privsList( i), instr( privsList( i) || ':', ':') + 1))
        , case when objectName like 'pkg_%' then
            'execute'
          else
            'select'
          end
      );
      execSql(
        'grant ' || objectPrivs || ' on ' || objectName || ' to ' || toUserName
      );
      if isToPublic then
        execSql(
          'create or replace public synonym ' || objectName
          || ' for ' || objectName
        );
      else
        execSql(
          'create or replace synonym ' || toUserName || '.' || objectName
          || ' for ' || objectName
        );
      end if;
      dbms_output.put_line(
        rpad( objectName, 30) || ' : ' || objectPrivs
      );
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , 'Ошибка при выдаче прав "' || privsList( i) || '" ('
          || ' objectName="' || objectName || '"'
          || ' , objectPrivs="' || objectPrivs || '"'
          || ').'
        , true
      );
    end;
    i := privsList.next( i);
  end loop;
end;
/
