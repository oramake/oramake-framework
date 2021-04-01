title: Описание



group: Введение

Модуль Logging обеспечивает логирование работы прикладных модулей. Базовые
концепции аналогичны используемым в проекте Apache Log4j 1.x
(<http://logging.apache.org/log4j/1.2/manual.html>).

Для логирования используется логер (объект типа <lg_logger_t>). Логеру
назначается имя, на основе которого строится иерархия логеров. Логер считается
предком другого логера, если его имя (с добавлением точки) является префиксом
имени другого логера. Например, логер с именем "com.foo" является предком
логера с именем "com.foo.Bar". В вершине иерархии находится корневой логер,
который считается предком всех остальных логеров и возвращается функцией
<lg_logger_t.getRootLogger()>. Обычно для логирования используется логер,
получаемый вызовом функции <lg_logger_t.getLogger()> с указанием имени модуля
и имени объекта в модуле. Например в пакете pkg_TestModule модуля TestModule
используется логер

(code)

/* ivar: logger
  Логер пакета.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => Module_Name
  , objectName  => 'pkg_TestModule'
);

(end)

(значение ранее объявленной константы Module_Name равно 'TestModule',
возвращается логер с именем 'TestModule.pkg_TestModule')

Логеру может быть назначен уровень логирования с помощью функции
<lg_logger_t.setLevel()>. Допустимые коды уровней возвращаются функциями
<lg_logger_t::Уровни логирования>, также можно использовать константы пакета
pkg_Logging (<pkg_Logging::Уровни логирования>). Если логеру не назначен
уровень логирования, то он наследует его от ближайшего предка с назначенным
уровнем логирования. Для очистки назначенного логеру уровня логирования
используется вызов функции <lg_logger_t.setLevel> со значением NULL. Корневой
логер всегда имеет назначенный уровень логирования, по умолчанию это "INFO" в
промышленной БД и "DEBUG" в тестовой БД.

Для добавления сообщения в лог используется методы типа lg_logger_t
(<lg_logger_t::Логирование сообщений>). При этом сообщению назначается уровень
логирования, соответствующий используемому методу (например, "DEBUG" при
использовании <lg_logger_t.debug()>) либо указанный явно в случае использования
<lg_logger_t.log()>. Сообщение выводится в лог, если уровень сообщения больше
или равен уровню логера. Например, если текущий уровень логера "INFO"
(назначенный или унаследованный), то сообщения уровней "DEBUG", "TRACE" и
ниже будут им игнорироваться (не будут выводиться в лог). Проверить состояние
вывода сообщений указанного уровня можно с помощью функции
<lg_logger_t.isEnabledFor()> либо ее вариантов, связанных с конкретным уровнем
логирования, например <lg_logger_t.isDebugEnabled()>. Для сообщений, связанных
с изменением контекста выполнения, используются дополнительные правила
(см. <Контекст выполнения>).

В качестве лога, в который выводятся сообщения, используется таблица <lg_log>.
Дополнительно в тестовых БД логируемые сообщения выводятся также через пакет
dbms_output. С помощью функции <pkg_Logging.setDestination> можно выбрать
единственное назначение для вывода сообщений (используя константы
<pkg_Logging.Назначения вывода>).

Пример установки уровня и назначения логирования приведен в скрипте
<Test/Example/set-level-destination.sql>:
(code)
...
declare

  procedure f1( step integer)
  is

    logger lg_logger_t := lg_logger_t.getLogger(
      moduleName    => 'TestModule'
      , objectName  => 'f1'
    );

  begin
    logger.debug( 'f1(' || step || '): start...');

    logger.info( 'f1(' || step || '): working...');

    logger.trace( 'f1(' || step || '): finished');
  end f1;

begin

  -- Отключение вывода отладочных сообщений (включено в тестовых БД по
  -- умолчанию)
  lg_logger_t.getRootLogger().setLevel( lg_logger_t.getInfoLevelCode());
  f1( 1);

  -- Включение вывода отладочных сообщений для модуля TestModule
  lg_logger_t.getLogger('TestModule')
    .setLevel( lg_logger_t.getDebugLevelCode())
  ;
  f1( 2);

  -- Включение вывода трассировочных сообщений для модуля TestModule
  lg_logger_t.getLogger('TestModule')
    .setLevel( lg_logger_t.getTraceLevelCode())
  ;
  -- Вывод всех сообщений только через dbms_output
  pkg_Logging.setDestination( pkg_Logging.DbmsOutput_DestinationCode);
  f1( 3);

  -- Восстанавливаем назначение вывода по умолчанию
  pkg_Logging.setDestination( null);
end;
...
(end)



group: Контекст выполнения

Для сообщений лога есть возможность указывать контекст выполнения. С помощью
контекста выполнения можно затем эффективно отбирать записи лога, связанные
с обработкой определенного объекта либо с определенным состоянием. Контекст
выполнения может быть вложенным или невложенным. Для вложенных контекстов
подсчитывается уровень вложенности (значения context_level и
context_type_level таблицы <lg_log>), при закрытии вложенного контекста
незакрытые вложенные контексты большего уровня (открытые позже) закрываются
автоматически. Вложенный контекст закрывается с учетом связанного с ним
значения (context_value_id), невложенный без учета значения. В проекте Apache
Log4j аналогичные концепции называются "Nested Diagnostic Context" ("NDC") и
"Mapped Diagnostic Context" ("MDC"), подробнее в
<https://wiki.apache.org/logging-log4j/NDCvsMDC>.

Для использования контекста выполнения нужно добавить тип контекста с помощью
функции <lg_logger_t.mergeContextType()> (значение nestedFlag определяет,
будет ли контекст вложенным или нет). Если контекст выполнения будет
использоваться локально (например, в скрипте установки определенной версии
модуля), можно добавлять его в этом же скрипте как временный (указав параметр
temporaryFlag равный 1). В этом случае тип контекста будет удален
автоматически по истечении определенного времени. Для открытия контекста при
добавлении сообщения в лог (например, функцией <lg_logger_t.log()>) нужно
указать тип контекста (с помощью contextTypeShortName и, возможно,
contextTypeModuleId), значение контекста (contextValueId) и 1 во флаге
открытия (openContextFlag). Для закрытия вложенного контекста указываются те
же значения типа и значения контекста и 0 во флаге открытия, при закрытии
невложенного контеста значение контекста (contextValueId) можно не указывать.
Если указан тип и значение контекста, но не указан флаг открытия, то
считается, что к контексту относится только данное сообщение (контекст
открывается и закрывается этим сообщением). Контекст выполнения действует в
рамках текущей сессии БД, сообщения по закрытию контекста могут быть
сформированы и добавлены в лог автоматически (например, в случае закрытия
родительского вложенного контекста или повторного открытия невложенного
контекста того же типа). Для обеспечения адекватного отражения в логе
желательно при использовании вложенного контекста закрывать его явно, в т.ч. в
случае ошибки при выполнеии. Пример использования приведен в скрипте
<Test/Example/nested-context.sql>.

Для сообщений, связанных с изменением контекста, используются дополнительные
правила для вывода в лог:
- при выводе в лог любого сообщения обеспечивается предварительный вывод
  сообщений по открытию действующих контекстов выполнения (независимо текущего
  уровня логирования);
- если было выведено сообщение по открытию контекста выполнения, то будет
  выведено и сообщение по закрытию этого контекста выполнения (независимо от
  его уровня логирования);

Эти правила обеспечивают наличие в логе информации по действующему контексту
выполнения для всех выводимых в лог сообщений.

Для поиска случаев использования определенного контекста в логе используется
представление <v_lg_context_change> (скрипт <Show/context-change.sql>).
Для просмотра контекстов выполнения, открытых на момент формирования указанной
записи лога, можно использовать скрипт <Show/context.sql>. Для получения ветки
лога, связанной с конкретным контекстом выполнения, можно использовать скрипт
<Show/branch.sql>.



group: Логирование стека ошибок

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



