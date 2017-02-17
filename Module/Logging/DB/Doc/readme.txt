title: Описание

Обеспечивает логирование работы прикладных модулей.


Group: Логирование стека ошибок

Для логирования стека рекомендуется
передавать в процедуру raise_application_error в качестве второго параметра
результат функции <lg_logger_t.errorStack>, передавая ей необходимое сообщение.
При работе с удалённой БД, следует использовать <lg_logger_t.remoteErrorStack>, указывая
в качестве второго параметра имя линка.
Для получения информации о стеке следует использовать функцию <lg_logger_t.getErrorStack>
или <pkg_Logging.GetErrorStack>. При вызове информация о предыдущем стеке очищается.
В случае, если после ряда вызовов <lg_logger_t.errorStack>, информация о стеке не была
получена и возникло новое исключение, стек предыдущего исключения сбрасывается
( информация логируется с уровнем <pkg_Logging.Debug_LevelCode> ).

Использование функции <lg_logger_t.getErrorStack> аналогично использованию стандартной plsql-функции SQLERRM,
при условии если соблюдается правило вызова raise_application_error, то есть используется
<lg_logger_t.errorStack>. Длина сообщения может достигать 32767 символов.

В случае, если исключение не было погашено на сервере, информация о стеке логируется с уровнем
<pkg_Logging.Error_LevelCode> ( используется триггер on servererror <lg_after_server_error>).

Примеры логирования стека ошибок:

- Генерация сообщения об ошибке длины, ограниченной лишь длиной varchar2

(start code)
declare
  lg lg_logger_t := lg_logger_t.getLogger(
    moduleName => 'Test'
    , objectName => 'TestBlock'
  );

  procedure internal
  is
  begin
    raise_application_error(
      pkg_Error.ProcessError
      , lg.errorStack( 'Произошла ошибка' || lpad( '!', 10000, '_'))
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , lg.errorStack( 'Ошибка "Internal_"' || lpad( '!', 10000, '_'))
      , true
    );
  end internal;

begin
  internal();
exception when others then
  pkg_Common.outputMessage(
    lg.getErrorStack()
  );
end;
/

declare
  lg lg_logger_t := lg_logger_t.getLogger(
    moduleName => 'Test'
    , objectName => 'TestBlock'
  );

  procedure internal
  is
  begin
    raise_application_error(
      pkg_Error.ProcessError
      , lg.errorStack( 'Произошла ошибка' || lpad( '!', 1000, '_'))
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , lg.errorStack( 'Ошибка "Internal_"' || lpad( '!', 1000, '_'))
      , true
    );
  end internal;

  procedure internal2
  is
    errorMessage varchar2( 32267);
  begin
    begin
      internal();
    exception when others then
      errorMessage := lg.getErrorStack();
    end;

    -- Нужны промежуточные результаты стека в errorMessage
    raise_application_error(
      pkg_Error.ProcessError
      , lg.errorStack(
          'Произошла ошибка обработки' || lpad( '!', 100, '_')
          || '"' || errorMessage || '"'
        )
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , lg.errorStack( 'Ошибка "Internal_2"' || lpad( '!', 1000, '_'))
      , true
    );
  end internal2;

begin
  internal2();
exception when others then
  pkg_Common.outputMessage(
    lg.getErrorStack()
  );
end;
/
(end)

- Генерация стека с использованием линка

(code)
declare
  lg lg_logger_t := lg_logger_t.getLogger(
    moduleName => 'Test'
    , objectName => 'TestBlock'
  );
  dblink varchar2( 30) := '&dblink';

  procedure internal
  is
    a integer;
  begin
    execute immediate
'begin drop_me_tmp100@' || dblink || ';end;'
    ;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , lg.remoteErrorStack( 'Ошибка "Internal_"' || lpad( '!', 10000, '_'), dblink)
      , true
    );
  end internal;

begin
  internal();
exception when others then
  pkg_Common.outputMessage(
    lg.getErrorStack()
  );
end;
(end)



