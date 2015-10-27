create or replace package body pkg_ProcessMonitor is

/* package body: pkg_ProcessMonitor::body */



/* group: Переменные */

/* ivar: logger
  Интерфейсный объект к модулю Logging
*/
  logger lg_logger_t := lg_logger_t.getLogger(
    moduleName => pkg_ProcessMonitorBase.Module_Name
    , objectName => 'pkg_ProcessMonitor'
  );



/* group: Константы */

/* iconst: TkProf_Parameters
  Параметры командной строки для tkprof
*/
TkProf_Parameters constant varchar2(1000) := 'print=100 sort=exeela aggregate=YES SYS=YES';

/* iconst: Trace_File_Mask
  Маска имени файла трассировки
*/
Trace_File_Mask  constant varchar2(1000) := '$(sysdate)_$(baseFileName).txt';

/* iconst: Tkprof_File_Mask
  Маска имени файла отчёта tkprof
*/
Tkprof_File_Mask constant varchar2(1000) := '$(sysdate)_$(baseFileName)_tkprof.txt';

/* iconst: Oracle_OsProcessName
  Имя процесса Oracle операционной системы.
*/
Oracle_OsProcessName constant varchar2(100) := 'ORACLE.EXE';



/* group: Типы */

/* itype: TfileName
  Тип для имени файла
*/
  subtype TfileName is varchar2(1000);

/* itype: TfileName
  Тип для пути к файлу
*/
  subtype TFilePath is varchar2(1000);



/* group: Функции */



/* group: Трассировка */

/* proc: hoursToString
  Перевод значения времени в часах в строку.

  Возврат:
  - строка в виде "? часов ?? минут"
*/
function hoursToString( hour number)
return varchar2
is
begin
  return
    trunc( hour) || ' часов(a) '
    || trunc( ( hour - trunc( hour)) * 60 )
    || ' минут';
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        ''
      )
    , true
  );
end hoursToString;

/* proc: sqlTraceOn(registeredSessionId)
   Включение трассировки для зарегистированной сессии.

   Параметры:
   registeredSessionId        - id зарегистрированной сессии ( ссылка на
                                <prm_registered_session>)
   isFinalTraceSending        - нужно ли отправлять письмо
                                о трассировке по завершению сессии
                                По-умолчанию не отправлять.
   recipient                  - получатель(и) сообщения
                                при отправке писем о трассировке.
                                По-умолчанию стандартный ящик для БД
                                (  функция pkg_Common.getMailAddressSource()).
   subject                    - тема письма при отправке писем.
                                По-умолчанию - нет.
   sqlTraceLevel              -  уровень трассировки. По умолчанию - 12
                                (см. описание уровней трассировки в <sqlTraceOn>)
*/
procedure sqlTraceOn(
  registeredSessionId integer
  , isFinalTraceSending integer := null
  , recipient varchar2 := null
  , subject varchar2 := null
  , sqlTraceLevel integer := null
)
is
  -- Использованный уровень трассировки
  usedSqlTraceLevel integer := coalesce( sqlTraceLevel, 12);
  -- Параметры сессии
  sid integer;
  serial# integer;
  -- Идентификатор процесса
  spid number(10);
  -- Установленный уровень трассировки
  sqlTraceLevelSet integer;
  -- Добавлено ли действие отправки трассировки по завершению сесии
  isFinalTraceSendingSet integer;

  procedure getRegisteredParameter
  is
  -- Получение параметров зарегистрированной сессии
  begin
    select
      (
      select
        count(1)
      from
        prm_session_action a
      where
        a.registered_session_id = registeredSessionId
        and a.session_action_code =
          pkg_ProcessMonitorBase.SendTrace_SessionActionCode
        -- Действие по завершению
        and a.planned_time is null
      ) as is_final_trace_sending_set
      , r.sql_trace_level_set
      , r.sid
      , r.serial#
    into
      isFinalTraceSendingSet
      , sqlTraceLevelSet
      , sid
      , serial#
    from
      v_prm_registered_session r
    where
      r.registered_session_id = registeredSessionId
    ;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка получения параметров зарегистрированной сессии'
        )
      , true
    );
  end getRegisteredParameter;

  /* setSqlTrace
    Установка трассировки для Oracle-сессии
  */
  procedure setSqlTrace
  is
    -- Параметры текущей сессии
    currentSid integer;
    currentSerial# integer;
  begin
    currentSid := pkg_Common.getSessionSid();
    currentSerial# := pkg_Common.getSessionSerial();
    select
      p.spid as spid
    into
      spid
    from
      v$session vs
    inner join
      v$process p
    on
      p.addr=vs.paddr
    where
      vs.sid = SqlTraceOn.sid
    ;
    logger.debug( 'setSqlTrace: sid=' || to_char( sid));
    if sid = currentSid and serial# = currentSerial# then
      logger.debug( 'alter session clause');
      execute immediate 'alter session set'
        || ' events ''10046 trace name context forever, level '
        || to_char( usedSqlTraceLevel) || '''';
    else
      sys.dbms_system.set_ev(
        sid
        , serial#
        , 10046
        , usedSqlTraceLevel
        , ''
      );
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка установки Oracle-трассировки'
        )
      , true
    );
  end setSqlTrace;

begin
  getRegisteredParameter;
  -- Если требуется установить трассировку
  if sqlTraceLevelSet is null
    or usedSqlTraceLevel <> sqlTraceLevelSet
  then
    setSqlTrace;
    update
      v_prm_registered_session
    set
      sql_trace_level_set = sqlTraceLevel
      , spid = sqlTraceOn.spid
      , sql_trace_date = coalesce( sql_trace_date, sysdate)
    where
      registered_session_id = registeredSessionId;
  end if;
  -- Установка или удаление действия
  if isFinalTraceSending = 1 and isFinalTraceSendingSet = 0 then
    -- действие по завершению cессии
    pkg_ProcessMonitorUtility.addAction(
      registeredSessionId => registeredSessionId
      , dateTime => null
      , actionCode => pkg_ProcessMonitorBase.SendTrace_SessionActionCode
      , emailRecipient => recipient
      , emailSubject => subject
    );
  -- Если нужно удалить действие
  elsif isFinalTraceSending = 0 and isFinalTraceSendingSet = 1 then
    pkg_ProcessMonitorUtility.deleteAction(
      registeredSessionId => registeredSessionId
      , dateTime => null
      , actionCode => pkg_ProcessMonitorBase.SendTrace_SessionActionCode
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка установки трассировки ( '
        || 'registeredSessionId=' || to_char( registeredSessionId)
        || ')'
      )
    , true
  );
end sqlTraceOn;

/* proc: sqlTraceOn
   Включение трассировки

   Параметры:
   sid                        - sid сессии ( по-умолчанию берётся текущая сессия)
   serial#                    - serial# сессии ( по-умолчанию берётся текущая сессия)
   isFinalTraceSending        - нужно ли отправлять письмо о трассировке по
                                завершению сессии. По умолчанию-нет.
   recipient                  - получатель(и) сообщения при отправке писем о
                                трассировке. По умолчанию-стандартный ящик для БД
                                ( модуль Common).
   subject                    - тема письма при отправке писем. По умолчанию-нет.
   sqlTraceLevel              - уровень трассировки. По-умолчанию 12.

   sqlTraceLevel может принимать следующие значения:

   sqlTraceLevel=1            - включает стандартные средства SQL_TRACE.
                                Результат не отличается от установки
                                SQL_TRACE=true.
   sqlTraceLevel=4            - включает стандартные средства SQL_TRACE и
                                добавляет в трассировочный файл значения
                                связываемых переменных.
   sqlTraceLevel=8            - включает стандартные средства SQL_TRACE и
                                добавляет в трассировочный файл информацию о
                                событиях ожидания на уровне запросов.
   sqlTraceLevel=12           - включает стандартные средства SQL_TRACE и
                                добавляет как значения связываемых переменных,
                                так и информацию об ожидании событий.
*/
procedure sqlTraceOn(
  sid integer := null
  , serial# integer := null
  , isFinalTraceSending integer := null
  , recipient varchar2 := null
  , subject varchar2 := null
  , sqlTraceLevel integer := null
)
is
  pragma autonomous_transaction;
  -- id зарегистрированной сессии
  registeredSessionId integer;
begin
  registeredSessionId := pkg_ProcessMonitorUtility.getRegisteredSession(
    sid => coalesce( sid, pkg_Common.getSessionSid)
    , serial# => coalesce( serial#, pkg_Common.getSessionSerial)
  );
  logger.debug( 'registeredSessionId=' || to_char( registeredSessionId));
  sqlTraceOn(
    registeredSessionId => registeredSessionId
    , isFinalTraceSending => isFinalTraceSending
    , recipient => recipient
    , subject => subject
    , sqlTraceLevel => sqlTraceLevel
  );
  commit;
exception when others then
  rollback;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка установки трассировки ('
        || 'sid=' || to_char( sid)
        || ', serial#=' || to_char( serial#)
        || ', isFinalTraceSending=' || to_char(isFinalTraceSending)
        || ', recipient="' || recipient || '"'
        || ', sqlTraceLevel=' || to_char( sqlTraceLevel)
        || ')'
      )
    , true
  );
end sqlTraceOn;

/* func: copyTrace(registeredSessionId)
  Копирование файлов трассировки

  Параметры:
  registeredSessionId         - id зарегистрированной сессии ( ссылка на
                                <prm_registered_session>)
  traceCopyPath               - директория для копирования файлов трассировки
                                ( по-умолчанию берётся результат
                                  <pkg_ProcessMonitorUtility.getDefaultTraceCopyPath>)
  isSourceDeleted             - удалять ли исходный файл трассировки (
                                по-умолчанию не удалять).

  Возврат:
  - информация о копировании в виде текста;
*/
function copyTrace(
  registeredSessionId integer
  , traceCopyPath varchar2
  , isSourceDeleted integer := null
)
return varchar2
is
  -- Имя файла трассировки
  fileName TFileName;
  -- Маска для поиска трассировочных файлов
  traceFileMask TFileName;
  -- Директория с trace-файлами
  traceDirectory TFilePath;
  -- Имя копии файла трассировки
  outputFileName TFileName;
  -- Имя отчёта файла трассировки
  tkprofFileName TFileName;
  -- Путь для копирования файлов трассировки
  usedTraceCopyPath TFilePath :=
    coalesce( traceCopyPath, pkg_ProcessMonitorUtility.getDefaultTraceCopyPath);
  -- Параметры сессии
  usedSid number;
  usedSpid number;
  usedSerial# number;
  -- Результирующее сообщение
  resultMessage varchar2( 32767);

  procedure getFilePath
  is
  -- Определение имени и пути файла трассировки
    -- Неиспользуемые параметры get_parameter_value
    l_type number;
    l_intval number;
    -- Дата включения трассировки
    sqlTraceDate date;
    -- Имя базы
    dbName varchar2(100);
    -- Поиск для получения имени файла
    cursor curFile( sqlTraceDate date) is
      select
        file_name
      from
        tmp_file_name t
      where
        -- Запас одна минута
        t.last_modification >= sqlTraceDate-1/24/60;
    -- Курсор для получения параметров сессии
    cursor curProcess is
select
  sid
  , serial#
  , spid
  , sql_trace_date
into
  usedSid
  , usedSerial#
  , usedSpid
  , sqlTraceDate
from
  v_prm_registered_session r
where
  r.registered_session_id = registeredSessionId;

  begin
    -- Получаем имя директории
    l_type := dbms_utility.get_parameter_value(
      'user_dump_dest'
      , l_intval
      , traceDirectory
    );
    logger.debug('l_type=' || to_char( l_type));
    logger.debug('l_intval=' || to_char( l_intval));
    -- Получаем параметры сессии
    open curProcess;
    loop
      fetch
        curProcess
      into
        usedSid
        , usedSerial#
        , usedSpid
        , sqlTraceDate;
      exit when curProcess%notfound;
    end loop;
    if curProcess%rowcount > 1 then
      raise_application_error(
        pkg_Error.ProcessError
        , logger.errorStack(
            'Количество найденных процессов больше 1'
          )
      );
    end if;
    close curProcess;
    logger.debug('usedSid=' || to_char( usedSid));
    logger.debug('usedSerial#=' || to_char( usedSerial#));
    logger.debug('usedSpid=' || to_char( usedSpid));
    logger.debug('sqlTraceDate='
      || '{' || to_char( sqlTraceDate, 'yyyy.mm.dd hh24:mi:ss') || '}'
    );

    if usedSid is not null then
      -- Получаем имя базы
      select
        value
      into
        dbName
      from
        v$parameter
      where
        name = 'instance_name'
      ;
      -- Получаем имя файла
      delete tmp_file_name;
      traceFileMask := dbName || '\_%\_' || to_char(usedSpid) || '.trc';
      pkg_File.fileList(
        fromPath => traceDirectory
        , fileMask => traceFileMask
      );
      open curFile( sqlTraceDate => sqlTraceDate);
      loop
        fetch
          curFile
        into
          fileName;
        exit when curFile%notfound;
      end loop;
      if curFile%rowcount > 1 then
        raise_application_error(
          pkg_Error.ProcessError
          , logger.errorStack(
              'Неверное количество найденных файлов('
              || 'count=' || to_char( curFile%rowcount)
              || ', traceFileMask="' || traceFileMask || '"'
              || ', traceDirectory="' || traceDirectory || '"'
              || ')'
            )
        );
      end if;
      close curFile;
    end if;
    logger.debug( 'fileName="' || fileName || '"');
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка получения имени файла трассировки'
        )
      , true
    );
  end getFilePath;

  procedure createFile
  is
  -- Создание tkprof-отчёта и копирование
  -- файла трассировки

    -- Имя файла без расширения
    baseFileName varchar2(1000) :=
      case when
        instr( fileName, '.') > 0
      then
        substr( fileName, 1, instr(fileName, '.', -1, 1)-1 )
      else
        fileName
      end;

    function getFileByMask(
      mask varchar2
    )
    return varchar2
    is
    -- Получение имени файла по маске,
    -- в которой могут участвовать макросы
    --   - $(baseFileName)
    --   - $(sysdate)
    begin
      return
        replace(
        replace(
          mask
          , '$(baseFileName)'
          , baseFileName
        )
          , '$(sysdate)'
          , to_char( sysdate, 'YYYYMMDD_HH24MISS')
        );
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            'Ошибка получаения имени файла по маске('
            || 'mask="' || mask || '"'
            || ')'
          )
        , true
      );
    end getFileByMask;

  begin
    outputFileName := getFileByMask( Trace_File_Mask);
    tkprofFileName := getFileByMask( Tkprof_File_Mask);
    logger.debug( 'outputFileName="' || outputFileName || '"');
    logger.debug( 'tkprofFileName="' || tkprofFileName || '"');
    pkg_File.fileCopy(
      fromPath => pkg_File.getFilePath(
        traceDirectory
        , fileName
      )
      , toPath => pkg_File.getFilePath(
        usedTraceCopyPath
        , outputFileName
      )
      , overwrite => 1
    );
    pkg_File.execCommand(
      'tkprof.exe '
      || pkg_File.getFilePath( traceDirectory, fileName)
      || ' ' || pkg_File.getFilePath( usedTraceCopyPath, tkprofFileName)
      || ' ' || Tkprof_Parameters
    );
    if isSourceDeleted = 1 then
      pkg_File.fileDelete(
        fromPath => pkg_File.getFilePath(
          traceDirectory
          , fileName
        )
      );
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка создания файлов'
        )
      , true
    );
  end createFile;

begin
  getFilePath;
  -- Если файл трассировки найден
  if fileName is null then
    resultMessage := 'Файл трассировки не найден ( '
      || 'sid=' || to_char( usedSid)
      || ', serial#=' || to_char( usedSerial#)
      || ', traceFileMask="' || traceFileMask || '"'
      || ', traceDirectory="' || traceDirectory || '"'
      || ')'
    ;
  else
    createFile;
    resultMessage :=
      'Файл трассировки '
      || '( sid=' || to_char( usedSid)
      || ', serial#='|| to_char( usedSerial#) || ')'
      || ' скопирован в ' || chr(10) || chr(10)
      || pkg_File.getFilePath( usedTraceCopyPath, outputFileName) || chr(10)||chr(10)
      || 'Файл tkprof создан в ' || chr(10) || chr(10)
      || pkg_File.getFilePath( usedTraceCopyPath, tkprofFileName)
      || case when isSourceDeleted = 1 then
          chr(10) || chr(10)
          || 'Исходный файл трассировки "' || fileName || '" удалён'
         end
    ;
  end if;
  commit;
  return resultMessage;
exception when others then
  rollback;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка копирования файлов трассировки ( '
        || 'registeredSessionId=' || to_char( registeredSessionId)
        || ', traceCopyPath="'|| traceCopyPath || '"'
        || ', isSourceDeleted=' || to_char( isSourceDeleted)
        || ')'
      )
    , true
  );
end copyTrace;

/* func: copyTrace
  Копирование файлов трассировки

  Параметры:
  traceCopyPath               - директория для копирования файлов трассировки
                                ( по-умолчанию берётся результат
                                  <pkg_ProcessMonitorUtility.getDefaultTraceCopyPath>)
  isSourceDeleted             - удалять ли исходный файл трассировки (
                                по-умолчанию не удалять).
  sid                         - sid сессии ( по-умолчанию берётся текущая сессия)
  serial#                     - serial# сессии ( по-умолчанию берётся текущая сессия)

  Возврат:
    - информация о копировании в виде текста
*/
function copyTrace(
  traceCopyPath varchar2
  , isSourceDeleted integer := null
  , sid integer := null
  , serial# integer := null
)
return varchar2
is
  pragma autonomous_transaction;
  -- id зарегистрированной сессии
  registeredSessionId integer;
begin
  registeredSessionId := pkg_ProcessMonitorUtility.getRegisteredSession(
    sid => coalesce( sid, pkg_Common.getSessionSid)
    , serial# => coalesce( serial#, pkg_Common.getSessionSerial)
  );
  logger.debug( 'registeredSessionId=' || to_char( registeredSessionId));
  return
    copyTrace(
      registeredSessionId => registeredSessionId
      , traceCopyPath => traceCopyPath
      , isSourceDeleted => isSourceDeleted
    );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка копирования файлов трассировки( '
        || 'traceCopyPath="'|| traceCopyPath || '"'
        || ', isSourceDeleted=' || to_char( isSourceDeleted)
        || ', sid=' || to_char( sid)
        || ', serial#=' || to_char( serial#)
        || ')'
      )
    , true
  );
end copyTrace;

/* proc: sendTrace
  Отправка ссылки на копию файлов трассировки

  Параметры:
  sid                         - sid сессии ( по-умолчанию берётся текущая
                                сессия)
  serial#                     - serial# сессии ( по-умолчанию берётся текущая
                                сессия)
  recipient                   - получатель(и) сообщения при отправке писем о
                                трассировке.  По-умолчанию стандартный ящик
                                для БД ( функция
                                pkg_Common.getMailAddressSource()).
  subject                     - тема письма при отправке писем.  По-умолчанию
                                указываются параметры сессии.
  isSourceDeleted             - удалять ли исходный файл трассировки (
                                по-умолчанию не удалять).
  traceCopyPath               - директория для копирования файлов трассировки
                                ( по-умолчанию берётся результат
                                  <pkg_ProcessMonitorUtility.getDefaultTraceCopyPath>)
  sqlTraceOff                 - отключать ли трассировку перед отправкой
                                письма (1-да).  По-умолчанию не отключать.
*/
procedure sendTrace(
  sid integer := null
  , serial# integer := null
  , recipient varchar2 := null
  , subject varchar2 := null
  , isSourceDeleted integer := null
  , traceCopyPath varchar2 := null
  , sqlTraceOff integer := null
)
is
  pragma autonomous_transaction;
  -- Текст сообщения о трассировке
  messageText varchar2( 32767);
  -- Параметры сессии
  vSid integer := coalesce( sid, pkg_Common.getSessionSid);
  vSerial# integer := coalesce( serial#, pkg_Common.getSessionSerial);
begin
  if sendTrace.sqlTraceOff = 1 then
    pkg_ProcessMonitor.sqlTraceOff(
      sid => sid
      , serial# => serial#
    );
  end if;
  messageText :=
    copyTrace(
      traceCopyPath => traceCopyPath
      , isSourceDeleted => isSourceDeleted
      , sid => vSid
      , serial# => vSerial#
    );
  pkg_Common.sendMail(
    mailSender => pkg_Common.getMailAddressSource(
      pkg_ProcessMonitorBase.Module_Name
    )
    , mailRecipient =>
      coalesce(
        recipient
        , pkg_Common.getMailAddressDestination
      )
    , subject =>
        coalesce(
          subject
          , 'Трассировка '
             || '(' || to_char( vSid) || ', ' || to_char( vSerial#) || ')'
         )
    , message => messageText
  );
  commit;
exception when others then
  rollback;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка отправки сообщения о трассировке ( '
        || 'sid=' || to_char( sid)
        || ', serial#=' || to_char( serial#)
        || ', recipient="'|| recipient || '"'
        || ', subject="'|| recipient || '"'
        || ', traceCopyPath="'|| traceCopyPath || '"'
        || ', isSourceDeleted=' || to_char( isSourceDeleted)
        || ')'
      )
    , true
  );
end sendTrace;

/* proc: sqlTraceOff
  Выключение трассировки

  Параметры:
  sid                         - sid сессии ( по-умолчанию текущая сессиия)
  serial#                     - serial# сессии ( по-умолчанию текущая сессиия)
*/
procedure sqlTraceOff(
  sid integer := null
  , serial# integer := null
)
is
  -- Использованные параметры сессии
  usedSid integer;
  usedSerial# integer;
begin
  if sid is null then
    usedSid := pkg_Common.getSessionSid;
    usedSerial# := pkg_Common.getSessionSerial;
  else
    usedSid := sid;
    usedSerial# := serial#;
  end if;
  update
    v_prm_registered_session
  set
    sql_trace_level_set = null
  where
    sid = usedSid
    and serial# = usedSerial#
  ;
  sys.dbms_system.set_ev( sid, serial#, 10046, 0, '');
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка выключения трассировки ( '
        || 'sid=' || to_char( sid)
        || ', serial#=' || to_char( serial#)
        || ')'
      )
    , true
  );
end sqlTraceOff;

/* proc: batchTraceOn
  Включение трассировки для сессии батча

  Параметры:
  sid                         - sid сессии ( по-умолчанию берётся текущая сессия)
  serial#                     - serial# сессии ( по-умолчанию берётся текущая сессия)
  isFinalTraceSending         - нужно ли отправлять письмо о трассировке по
                                завершению сессии
  sqlTraceLevel               - уровень трассировки (см. описание уровней
                                трассировки в <sqlTraceOn>)
  batchShortName              - наименование батча
*/
procedure batchTraceOn(
  sid integer
  , serial# integer
  , isFinalTraceSending integer
  , sqlTraceLevel integer
  , batchShortName varchar2
)
is
begin
  sqlTraceOn(
    sid => sid
    , serial# => serial#
    , sqlTraceLevel => sqlTraceLevel
    , isFinalTraceSending => isFinalTraceSending
    , subject => batchShortName || ': Трассировка'
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка установки трассировки для сессии батча'
      )
    , true
  );
end batchTraceOn;



/* group: Слежение за процессами */

/* proc: batchBegin
  Процедура, вызываемая в начале работы батча.

  Параметры:
  sqlTraceLevel               - уровень трассировки (см. описание уровней
                                трассировки в <sqlTraceOn>)
*/
procedure batchBegin(
  sqlTraceLevel integer := null
)
is
  -- Короткое наименование батча
  batchShortName v_sch_batch.batch_short_name%type;
  -- Параметры сессии
  sid integer :=  pkg_Common.getSessionSid;
  serial# integer :=  pkg_Common.getSessionSerial;
  -- Параметры настройки батча
  isFinalTraceSending integer;
  traceTimeHour integer;
  usedSqlTraceLevel integer;
begin
  -- Получение некоторых настроек
  select
    max( is_final_trace_sending)
    , max( trace_time_hour)
    , coalesce(
        sqlTraceLevel
        , max( sql_trace_level)
      )
    , max( batch_short_name)
  into
    isFinalTraceSending
    , traceTimeHour
    , usedSqlTraceLevel
    , batchShortName
  from
    prm_batch_config c
  where
    batch_short_name =
    (
    select
      batch_short_name
    from
      v_sch_batch
    where
      sid = batchBegin.sid
      and serial# = batchBegin.serial#
    );
  if traceTimeHour <= 0 or sqlTraceLevel is not null then
    batchTraceOn(
      sid => sid
      , serial# => serial#
      , sqlTraceLevel => sqlTraceLevel
      , isFinalTraceSending => isFinalTraceSending
      , batchShortName => batchShortName
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка процедуры начала работы батча'
      )
    , true
  );
end batchBegin;

/* proc: batchEnd
  Процедура, вызываемая в конце работы батча.
*/
procedure batchEnd
is
begin
  checkSendTrace(
    isBatchEnd => 1
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка процедуры окончания работы батча'
      )
    , true
  );
end batchEnd;

/* proc: checkTrace
  Установка трассировки для зарегистрированных сессий.
*/
procedure checkTrace
is
  pragma autonomous_transaction;
begin
  pkg_TaskHandler.initTask(
    moduleName =>  pkg_ProcessMonitorBase.Module_Name
    , processName => 'checkTrace'
  );
  for recAction in
  (
  select
    sid
    , serial#
    , v.registered_session_id
    , v.session_action_code
    , v.planned_time
  from
    v_prm_execution_action v
  where
    session_action_code =
      pkg_ProcessMonitorBase.Trace_SessionActionCode
  order by
    planned_time
  nulls last
  )
  loop
    sqlTraceOn(
      registeredSessionId => recAction.registered_session_id
    );
    pkg_ProcessMonitorUtility.completeAction(
      registeredSessionId => recAction.registered_session_id
      , dateTime => recAction.planned_time
      , actionCode => recAction.session_action_code
    );
    logger.info(
      'Включена трассировка для сессии ('
       || 'sid='|| to_char( recAction.sid)
       || ', serial#=' || to_char( recAction.serial#)
       || ')'
    );
  end loop;
  pkg_ProcessMonitorUtility.clearRegisteredSession;
  pkg_TaskHandler.cleanTask;
  commit;
exception when others then
  pkg_TaskHandler.cleanTask;
  rollback;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка включения трассировки зарегистрированных сессий'
      )
    , true
  );
end checkTrace;

/* proc: checkOraKill
  Выполнение oraKill для зарегистрированных сессий.
*/
procedure checkOraKill
is
  pragma autonomous_transaction;
  -- Текст сообщения
  messageText varchar2( 32767);
begin
  pkg_TaskHandler.InitTask(
    moduleName =>  pkg_ProcessMonitorBase.Module_Name
    , processName => 'checkOraKill'
  );
  for recAction in
  (
  select
    v.registered_session_id
    , v.planned_time
    , sid
    , serial#
    , email_recipient
    , email_subject
  from
    v_prm_execution_action v
  where
    session_action_code =
      pkg_ProcessMonitorBase.OraKill_SessionActionCode
  order by
    planned_time
  nulls last
  )
  loop
    pkg_ProcessMonitorUtility.oraKill(
      sid => recAction.sid
      , serial# => recAction.serial#
    );
    messageText :=
      'Выполнен orakill для сессии ( '
       || 'sid='|| to_char( recAction.sid)
       || ', serial#=' || to_char( recAction.serial#)
       || ')';
    pkg_Common.sendMail(
      mailSender => pkg_Common.getMailAddressSource(
        pkg_ProcessMonitorBase.Module_Name
      )
      , mailRecipient =>
          coalesce(
            recAction.email_recipient
            , pkg_Common.getMailAddressDestination
          )
      , subject =>
          coalesce( recAction.email_subject, 'orakill('
             || to_char(recAction.sid) || ',' || to_char( recAction.serial#)
             || ')'
          )
      , message => messageText
    );
    logger.info( messageText);
    pkg_ProcessMonitorUtility.completeAction(
      registeredSessionId => recAction.registered_session_id
      , dateTime => recAction.planned_time
      , actionCode => pkg_ProcessMonitorBase.OraKill_SessionActionCode
    );
  end loop;
  pkg_ProcessMonitorUtility.clearRegisteredSession;
  pkg_TaskHandler.cleanTask;
  commit;
exception when others then
  pkg_TaskHandler.cleanTask;
  rollback;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка выполнения oraKill зарегистрированных сессий'
      )
    , true
  );
end checkOraKill;

/* proc: checkSendTrace
  Отправка ссылок на копии файлов трассировки для зарегистрированных сессий.

  Параметры:
  isBatchEnd                  - нужно ли выполнить отправку для батча текущей
                                сессии (1-да) По-умолчанию нет.
*/
procedure checkSendTrace(
  isBatchEnd integer := null
)
is
  pragma autonomous_transaction;
  -- Параметр сессии
  currentSid integer := pkg_Common.getSessionSid;
  currentSerial# integer := pkg_Common.getSessionSerial;
  -- Id зарегистрированной сессии для текущей
  registeredSessionId integer :=
    case when
      isBatchEnd = 1
    then
      pkg_ProcessMonitorUtility.getRegisteredSession(
        sid => currentSid
        , serial# => currentSerial#
      )
    end;
begin
  pkg_TaskHandler.InitTask(
    moduleName =>  pkg_ProcessMonitorBase.Module_Name
    , processName => 'checkSendTrace'
  );
  for recAction in
  (
  select
    sid as sid
    , serial# as serial#
    , v.registered_session_id as registered_session_id
    , v.session_action_code as session_action_code
    , v.email_recipient as email_recipient
    , v.email_subject as email_subject
    , v.planned_time as planned_time
  from
    v_prm_execution_action v
  where
    session_action_code =
      pkg_ProcessMonitorBase.SendTrace_SessionActionCode
    and coalesce( isBatchEnd, 0) = 0
  union all
  select
    currentSid as id
    , currentSerial# as serial#
    , registeredSessionId as registered_session_id
    , a.session_action_code as session_action_code
    , a.email_recipient as email_recipient
    , a.email_subject as email_subject
    , a.planned_time as planned_time
  from

    prm_session_action a
  where
    session_action_code =
      pkg_ProcessMonitorBase.SendTrace_SessionActionCode
    and coalesce( isBatchEnd, 0) = 1
    and a.registered_session_id = registeredSessionId
  order by
    planned_time
  nulls last
  )
  loop
    sendTrace(
      sid => recAction.sid
      , serial# => recAction.serial#
      , recipient => recAction.email_recipient
      , subject => recAction.email_subject
      , isSourceDeleted =>
          case when recAction.planned_time is null then 1 end
    );
    pkg_ProcessMonitorUtility.completeAction(
      registeredSessionId => recAction.registered_session_id
      , dateTime => recAction.planned_time
      , actionCode => recAction.session_action_code
    );
    logger.info(
      'Отправлена информация о трассировке для сессии ('
       || 'sid='|| to_char( recAction.sid)
       || ', serial#=' || to_char( recAction.serial#)
       || ')'
    );
  end loop;
  pkg_ProcessMonitorUtility.clearRegisteredSession;
  pkg_TaskHandler.cleanTask;
  commit;
exception when others then
  pkg_TaskHandler.cleanTask;
  rollback;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка отправки писем по трассировочным файлам'
      )
    , true
  );
end checkSendTrace;

/* proc: checkBatchExecution
  Отслеживание работы батчей

  Параметры:
  warningTimePercent          - порог предупреждения ( в процентах)
  warningTimeHour             - порог предупреждения ( в часах)
  minWarningTimeHour          - минимальный порог предупреждения ( в часах)
  abortTimeHour               - порог прерывания ( в часах)
  orakillWaitTimeHour         - порог прерывания через orakill ( в часах).
                                Порог времени отсчитывается с начала
                                прерывания сессии.
*/
procedure checkBatchExecution(
  warningTimePercent integer
  , warningTimeHour integer
  , minWarningTimeHour integer
  , abortTimeHour integer
  , orakillWaitTimeHour integer
  , traceCopyPath varchar2 := null
)
is
  pragma autonomous_transaction;
  -- Параметры сообщения
  messageText varchar2( 32767);
  -- Длительно ли выполняется задание
  isLong boolean;
  -- Прервано ли выполнение задания
  isAborted boolean;
  -- Выполнена ли трассировка
  isTrace boolean;

  cursor curLongBatch is
select
  l.*
from
  (
  select
    d.*
      -- Если заданы настройки все параметры берутся из настроек
    , greatest(
        -- Минимальный из определяемых интервалов для предупреждения
        least(
          coalesce(
            max_execution_hour *
              case when c.batch_short_name is not null then
                c.warning_time_percent
              else
                warningTimePercent
              end
            / 100
            , execution_hour + 1
          )
          ,
          coalesce(
            case when c.batch_short_name is not null then
              c.warning_time_hour
            else
              warningTimeHour
            end
            , execution_hour + 1
          )
        )
          -- Не должен быть больше minWarningTimeHour, если нет настроек батча
        , coalesce(
            case when c.batch_short_name is null then
              minWarningTimeHour
            end
            , 0
          )
      ) as warning_time_hour
    , case when c.batch_short_name is not null then
        c.abort_time_hour
      else
        abortTimeHour
      end as abort_time_hour
    , case when c.batch_short_name is not null then
        c.orakill_wait_hour
      else
        orakillWaitTimeHour
      end as orakill_wait_time_hour
    , c.trace_time_hour as trace_time_hour
    , c.sql_trace_level as sql_trace_level
    , c.is_final_trace_sending as is_final_trace_sending
  from
    (
    select
      b.batch_id
      , b.batch_short_name
      , b.batch_name_rus
      , b.sid
      , b.serial#
      , ( b.duration_second / 3600) as execution_hour
      , (
        select
          max(
          (
          select
            lg.date_ins
          from
            sch_log lg
          where
            lg.parent_log_id = rl.log_id
            and lg.message_type_code = 'BFINISH'
          )
          - rl.date_ins
          ) * 24
        from
          v_sch_batch_root_log rl
        where
          rl.batch_id = b.batch_id
        )
        as max_execution_hour
      , (
        select
          count(1)
        from
          sch_schedule sd
        where
          sd.batch_id = b.batch_id
          and not exists
            (
            select
              null
            from
              sch_interval iv
            where
              iv.schedule_id = sd.schedule_id
            )
        ) as is_real_time
    from
      v_sch_batch b
    where
      b.sid is not null
      -- Не текущая сессия
      and not (
        b.sid = ( select pkg_Common.getSessionSid from dual)
        and b.serial# = ( select pkg_Common.getSessionSerial from dual)
      )
    ) d
  left join
    prm_batch_config c
  on
    c.batch_short_name = d.batch_short_name
  ) l
where
  is_real_time = 0
  and
  (
    -- l.warning_time_hour учитывает warning_time_percent
    l.execution_hour > l.warning_time_hour
    or l.execution_hour > l.abort_time_hour
  )
  or l.execution_hour > l.trace_time_hour
  ;

  procedure addMessage(
    addedMessage varchar2
  )
  is
  -- Добавление текста к сообщению
  --
  -- Параметры:
  --   addedMessage          - добавляемый текст
  begin
    if messageText is not null then
      messageText := messageText || chr(10);
    end if;
    messageText := messageText || addedMessage;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка добавления сообщения'
        )
      , true
    );
  end addMessage;

  procedure abortBatch(
    rec curLongBatch%rowtype
  )
  is
  -- Прерывание пакета
  begin
    pkg_ProcessMonitorUtility.abortBatch(
      batchID => rec.batch_id
      , sid => rec.sid
      , serial# => rec.serial#
    );
    addMessage(
      'Прервано выполнение пакета "'
      || rec.batch_name_rus || '" [' || rec.batch_short_name || ']'
      || ' ( sid=' || rec.sid || ', serial#=' || rec.serial# || ').'
    );
  exception when others then
    addMessage(
      'Ошибка при прерывании длительно выполнявшегося пакета ('
      || ' batch_id=' || rec.batch_id || ').'
      || chr(10) || logger.getErrorStack
    );
  end abortBatch;

  procedure checkExecution(
    rec curLongBatch%rowtype
  )
  is
  begin
    if rec.execution_hour > rec.abort_time_hour then
      isAborted := true;
      abortBatch( rec => rec);
      if rec.orakill_wait_time_hour is not null then
        pkg_ProcessMonitorUtility.addAction(
          registeredSessionId =>
            pkg_ProcessMonitorUtility.getRegisteredSession(
              sid => rec.sid
              , serial# => rec.serial#
            )
          , dateTime => sysdate + rec.orakill_wait_time_hour / 24
          , actionCode => pkg_ProcessMonitorBase.OraKill_SessionActionCode
          , emailRecipient => pkg_Common.getMailAddressDestination
          , emailSubject => rec.batch_short_name || ': Orakill'
        );
        addMessage(
          'В случае существования сессии после '
          ||  '{' || to_char(
                       sysdate + rec.orakill_wait_time_hour / 24
                       , 'dd.mm.yyyy hh24:mi:ss'
                     ) || '} '
          || 'будет выполнен orakill'
        );
      end if;
    elsif rec.execution_hour > rec.warning_time_hour then
      isLong := true;
      addMessage(
        'Пакет "'
        || rec.batch_name_rus || '" [' || rec.batch_short_name || ']'
        || ' выполняется длительное время'
        || ' ( ' || hoursToString( rec.execution_hour) || ')'
      );
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка проверки работы батча ( '
          || ' rec.batch_short_name="' || rec.batch_short_name || '"'
          || ')'
        )
      , true
    );
  end checkExecution;

  procedure trace(
    rec curLongBatch%rowtype
  )
  is
  -- Включение трассировки для батча
  -- и добавления сообщения о копии файлов трассировки
  begin
    batchTraceOn(
      sid => rec.sid
      , serial# => rec.serial#
      , isFinalTraceSending => rec.is_final_trace_sending
      , sqlTraceLevel => rec.sql_trace_level
      , batchShortName => rec.batch_short_name
    );
    addMessage(
      chr(10) ||
      copyTrace(
        traceCopyPath =>
          coalesce(
            traceCopyPath
            , pkg_ProcessMonitorUtility.getDefaultTraceCopyPath
          )
        , sid => rec.sid
        , serial# => rec.serial#
      )
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка обработки параметров трассировки батча ('
          || 'batch_short_name="' || rec.batch_short_name || '"'
          || ')'
        )
      , true
    );
  end trace;

  procedure sendMessage(
    rec curLongBatch%rowtype
  )
  is
  -- Отправка email-сообщения

    -- Тема письма
    subject varchar2( 400);
  begin
    subject :=
      rec.batch_short_name ||
        case when
          isAborted
        then
          ': Прерывание'
        when
          isLong
        then
          ': Предупреждение'
        when
          isTrace
        then
          ': Трассировка'
        end;
    pkg_Common.sendMail(
      mailSender => pkg_Common.getMailAddressSource(
        pkg_ProcessMonitorBase.Module_Name
      )
      , mailRecipient => pkg_Common.getMailAddressDestination
      , subject => subject
      , message => messageText
    );
    logger.debug( 'Письмо отправлено ( '
      || 'subject="' || subject || '"'
      || ', message="' || messageText || '"'
      || ')'
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка отправки email ('
          || 'batch_short_name="' || rec.batch_short_name || '"'
          || ')'
        )
      , true
    );
  end sendMessage;

begin
  pkg_TaskHandler.InitTask(
    moduleName =>  pkg_ProcessMonitorBase.Module_Name
    , processName => 'checkBatchExecution'
  );
  logger.debug( 'minWarningTimeHour=' || to_char( minWarningTimeHour));
  for rec in curLongBatch loop
    logger.debug(
      'Проверка батча ( '
      || ' batch_short_name="' || rec.batch_short_name || '"'
      || ' , sid=' || to_char( rec.sid)
      || ' , serial#=' || to_char( rec.serial#)
      || ' , execution_hour=' || to_char( rec.execution_hour)
      || ' , warning_time_hour=' || to_char( rec.warning_time_hour)
      || ' , abort_time_hour=' || to_char( rec.abort_time_hour)
      || ' , trace_time_hour=' || to_char( rec.trace_time_hour)
      || ')'
    );
    messageText := '';
    isLong := false;
    isAborted := false;
    checkExecution( rec => rec);
    isTrace := false;
    if rec.execution_hour >= rec.trace_time_hour then
      trace( rec => rec);
      isTrace := true;
    end if;
    sendMessage( rec => rec);
  end loop;
  pkg_TaskHandler.cleanTask;
  commit;
exception when others then
  pkg_TaskHandler.cleanTask;
  rollback;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка отслеживания работы батчей ( '
        || 'warningTimePercent=' || to_char( warningTimePercent)
        || ', warningTimeHour=' || to_char( warningTimeHour)
        || ', abortTimeHour=' || to_char( abortTimeHour)
        || ', orakillWaitTimeHour=' || to_char( orakillWaitTimeHour)
        || ', traceCopyPath=' || to_char( traceCopyPath)
        || ')'
      )
    , true
  );
end checkBatchExecution;

/* func: getOsMemory
  Получение объёма памяти ( в байтах) затрачиваемого процессом Oracle.

  Замечание:
  - предполагается, что имя серсиса, соответствующего процессу содержит в себе
    имя oracle instance;
*/
function getOsMemory
return number
is

  -- PID процесса Oracle
  oracleOsPid integer;

  /*
    Получение результата объёма памяти из строки вида "18 012 K".
  */
  function getMemorySize( sizeString varchar2)
  return number
  is
  begin
    return
      to_number(
        regexp_replace(
          replace(
            sizeString
            -- Разделитель разрядов ( неразрывный пробел)
            , chr(160)
            , ''
          )
          , '[,| |K]', ''
        )
      ) * 1024
    ;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка получения объёма памяти из строки "' || sizeString || '"'
        )
      , true
    );
  end getMemorySize;

  /*
    Получаем PID процесса Oracle, соответствующего БД.
  */
  function getServicePid
  return integer
  is
    commandOutput clob;
    -- Итератор для парсинга CSV
    csvIterator tpr_csv_iterator_t;
    -- PID процесса Oracle
    oracleOsPid integer;
  -- getServicePid
  begin
    dbms_lob.createTemporary( commandOutput, true);
    -- Находим PID нужного серсиcа
    pkg_File.execCommand(
      command => 'tasklist /FI "imagename eq ' || Oracle_OsProcessName || '" /FO csv /svc'
      , output => commandOutput
    );
    logger.trace( 'commandOutput="' || commandOutput);
    if commandOutput is not null then
      csvIterator := tpr_csv_iterator_t(
        textData => commandOutput
        , headerRecordNumber => 1
        , fieldSeparator => ','
      );
      while csvIterator.next() loop
        if upper( csvIterator.getString(3))
          like '%' || upper( pkg_Common.getInstanceName()) || '%'
        then
          oracleOsPid := csvIterator.getNumber(2);
          exit;
        end if;
      end loop;
      if oracleOsPid is null then
        raise_application_error(
          pkg_Error.IllegalArgument
          , 'Не найдена строка информации по сервису'
        );
      end if;
    else
      raise_application_error(
        pkg_Error.IllegalArgument
        , 'Команда не вернула результат'
      );
    end if;
    return
      oracleOsPid;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка '
        )
      , true
    );
  end getServicePid;

  /*
    Получаем значение памяти объёма процесса.
  */
  function getProcessMemory(
    oracleOsPid integer
  )
  return number
  is
    -- Вывод команды ОС
    commandOutput clob;
    -- Итератор для парсинга CSV
    csvIterator tpr_csv_iterator_t;
    -- Объём памяти процесса
    processMemory number;

  -- getProcessMemory
  begin
    dbms_lob.createTemporary( commandOutput, true);
    pkg_File.execCommand(
      command => 'tasklist /FI "imagename eq ' || Oracle_OsProcessName || '" /FO csv'
      , output => commandOutput
    );
    logger.trace( 'commandOutput="' || commandOutput);
    -- Находим объём памяти по PID
    if commandOutput is not null then
      csvIterator := tpr_csv_iterator_t(
        textData => commandOutput
        , headerRecordNumber => 1
        , fieldSeparator => ','
      );
      while csvIterator.next() loop
        if csvIterator.getNumber(2) = oracleOsPid then
          logger.debug( 'process found: memory');
          processMemory := getMemorySize( csvIterator.getString(5));
          exit;
        end if;
      end loop;
      if processMemory is null then
        raise_application_error(
          pkg_Error.IllegalArgument
          , 'Не найдена строка информации по PID'
        );
      end if;
    else
      raise_application_error(
        pkg_Error.IllegalArgument
        , 'Команда не вернула результат'
      );
    end if;
    return
      processMemory;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка получения объёма памяти по PID процесса ОС ('
          || ' oracleOsPid=' || to_char( oracleOsPid)
          || ')'
        )
      , true
    );
  end getProcessMemory;

-- getOracleOsProcessMemory
begin
  oracleOsPid := getServicePid();
  return
    getProcessMemory( oracleOsPid => oracleOsPid)
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка получения количества памяти процесса операционной системы'
      )
    , true
  );
end getOsMemory;

/* proc: checkMemory
  Проверка превышения заданных порогов использовануемой оперативной памяти.

  Параметры:
  osMemoryThreshold           - объём памяти процесса операционной системы в
                                байтах, при котором выдаётся предупреждение
  pgaMemoryThreshold          - объём памяти PGA процессов Oracle, при котором
                                выдаётся предупреждение
  emailRecipient              - получатель(и) предупреждения

  Примечания:
  - должен быть задан хотя бы один порог ( osMemoryThreshold или
    pgaMemoryThreshold);
*/
procedure checkMemory(
  osMemoryThreshold number := null
  , pgaMemoryThreshold number := null
  , emailRecipient varchar2 := null
)
is

  -- Сообщение для предупреждения
  messageText clob := null;

  -- Получатели предупреждения
  usedEmailRecipient varchar2(1000) :=
    coalesce( emailRecipient, pkg_Common.getMailAddressDestination);

  /*
    Получение отформатированной строки размера памяти в байтах.
  */
  function formatMemorySize(
    memorySize number
  )
  return varchar2
  is
  begin
    return
      to_char(
        memorySize
        , 'FM999G999G999G999G999'
        , 'NLS_NUMERIC_CHARACTERS=''. '''
      );
  end formatMemorySize;

  /*
    Проверка параметров.
  */
  procedure checkParameter
  is
  begin
    if osMemoryThreshold is null and pgaMemoryThreshold is null then
      raise_application_error(
        pkg_Error.IllegalArgument
        , 'Должен быть задан хотя бы один параметр: osMemoryThreshold или'
          || ' pgaMemoryThreshold'
      );
    end if;
  end checkParameter;

  /*
    Проверка памяти, затрачиваемой операционной системой.
  */
  procedure checkOsMemory
  is
    -- Память, затрачивамая процессов операционной системы ( Oracle.exe)
    currentOsMemory number;
  begin
    currentOsMemory := getOsMemory();
    if currentOsMemory > osMemoryThreshold then
      messageText := messageText ||
'Превышение порога памяти процесса операционной системы.
Объём памяти ' || Oracle_OsProcessName || ': ' || formatMemorySize( currentOsMemory) || ' байт
Порог: ' || formatMemorySize( osMemoryThreshold) || ' байт'
      ;
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка проверки памяти, затрачиваемой операционной системой'
        )
      , true
    );
  end checkOsMemory;

  /*
    Проверка памяти PGA процессов Oracle.
  */
  procedure checkPga
  is
    headerFlag boolean := false;
  begin
    logger.debug( 'checkPga');
    for sessionMemory in (
      select
        *
      from
        v_prm_session_memory
      where
        pga_memory > pgaMemoryThreshold
      order by
        pga_memory desc
    )
    loop
      if not headerFlag then
        messageText := messageText || chr(13) || chr(10) || '
Превышение порога памяти ( PGA) внутренними процессами Oracle: '
|| formatMemorySize( pgaMemoryThreshold) || ' байт'
        ;
        headerFlag := true;
      end if;
      messageText := messageText || chr(13) || chr(10) || '
Sid: ' || to_char( sessionMemory.sid) || '
Serial#: ' || to_char( sessionMemory.serial#) || '
Объём PGA: ' || formatMemorySize( sessionMemory.pga_memory) || ' байт'
        ||
        case when
         sessionMemory.batch_short_name is not null then
'
Батч: "' || sessionMemory.batch_short_name || '"'
        else
'
username: ' || sessionMemory.username || '
osuser: ' || sessionMemory.osuser || '
terminal: ' || sessionMemory.terminal || '
program: ' || sessionMemory.program
        end
        || '
logon_time: ' || to_char( sessionMemory.logon_time, 'dd.mm.yyyy hh24:mi:ss')
      ;
    end loop;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка проверки памяти PGA процессов Oracle'
        )
      , true
    );
  end checkPga;

-- checkMemory
begin
  checkParameter();
  if osMemoryThreshold is not null then
    checkOsMemory();
  end if;
  if pgaMemoryThreshold is not null then
    checkPga();
  end if;
  if messageText is not null then
    pkg_Common.sendMail(
      mailSender => pkg_Common.getMailAddressSource(
        pkg_ProcessMonitorBase.Module_Name
      )
      , mailRecipient => usedEmailRecipient
      , subject => 'Превышение порога памяти'
      , message => messageText
    );
    logger.info(
      'Отправлено предупреждение по адресу(ам): "' || usedEmailRecipient || '"'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка проверки превышения использования процессами заданного порога'
        || 'оперативной памяти'
      )
    , true
  );
end checkMemory;



/* group: Настройки батча */

/* proc: setBatchConfig
  Установка настроек для батча

  Параметры:
  batchShortName              - короткое наименование батча
  warningTimePercent          - порог предупреждения о длительном выполнении
                                ( в процентах)
  warningTimeHour             - порог предупреждения о длительном выполнении
                                ( в часах)
  abortTimeHour               - порог прерывания ( в часах)
  orakillWaitTimeHour         - порог ожидания для выполнения oraKill для сессии
                                в состоянии KILLED
  traceTimeHour               - порог установки и отправки файла трассировки
  isFinalTraceSending         - отправка ссылки на файл трассировки при завершении
                                пакетного задания
  sqlTraceLevel               - уровень трассировки
                                (см. описание уровней трассировки в <sqlTraceOn>)
*/
procedure setBatchConfig(
  batchShortName varchar2
  , warningTimePercent integer
  , warningTimeHour integer
  , abortTimeHour integer
  , orakillWaitTimeHour integer
  , traceTimeHour integer
  , sqlTraceLevel integer
  , isFinalTraceSending integer
)
is
begin
  update
    prm_batch_config
  set
    warning_time_percent = warningTimePercent
    , warning_time_hour = warningTimeHour
    , abort_time_hour = abortTimeHour
    , orakill_wait_hour = orakillWaitTimeHour
    , trace_time_hour = traceTimeHour
    , sql_trace_level = sqlTraceLevel
    , is_final_trace_sending = isFinalTraceSending
  where
    batch_short_name = batchShortName;
  if sql%rowcount = 0 then
    insert into prm_batch_config(
      batch_short_name
      , warning_time_percent
      , warning_time_hour
      , abort_time_hour
      , orakill_wait_hour
      , trace_time_hour
      , sql_trace_level
      , is_final_trace_sending
      , operator_id
    )
    values(
      batchShortName
      , warningTimePercent
      , warningTimeHour
      , abortTimeHour
      , orakillWaitTimeHour
      , traceTimeHour
      , sqlTraceLevel
      , isFinalTraceSending
      , pkg_Operator.getCurrentUserId
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка установки настроек батча ( '
        || 'batchShortName="' || batchShortName || '"'
        || ')'
      )
    , true
  );
end setBatchConfig;

/* proc: deleteBatchConfig
  Удаление настроек для батча

  Параметры:
  batchShortName              - короткое наименование батча
*/
procedure deleteBatchConfig(
  batchShortName varchar2
)
is
begin
  delete from
    prm_batch_config
  where
    batch_short_name = batchShortName
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка удаления настроек батча ( '
        || 'batchShortName="' || batchShortName || '"'
        || ')'
      )
    , true
  );
end deleteBatchConfig;

end pkg_ProcessMonitor;
/
