create or replace package body pkg_MailHandler is
/* package body: pkg_MailHandler::body */

/* iconst: Module_Name
  Название модуля, к которому относится пакет.
*/
Module_Name constant varchar2(30) := pkg_Mail.Module_Name;

/* iconst: CheckCommand_Timeout
  Таймаут между проверками наличия команд
  обработчика отправки сообщений
*/
CheckCommand_Timeout constant interval day to second := interval '1' second;

/* iconst: CheckNewRequest_Timeout
  Таймаут между проверками наличия
  новых запросов обработчика отправки сообщений
*/
CheckNewRequest_Timeout constant interval day to second := interval '6' second;

/* iconst: SendMessage_TimeLimit
  Лимит времени для отправки сообщений
  ( используется при проверке ошибок)
*/
SendMessage_TimeLimit constant interval day to second := INTERVAL '3' MINUTE;

/* ivar: logger
  Интерфейсный объект к модулю Logging
*/
  logger lg_logger_t := lg_logger_t.GetLogger(
    moduleName => pkg_Mail.Module_Name
    , objectName => 'pkg_MailHanlder'
  );

/* itype: TColSmtpServer
  Тип коллекции для адресов smtp-серверов
*/
  type TColSmtpServer is table of ml_message.smtp_server%type;

/* func: ParseSmtpServerList
  Разбирает строку со списком адресов
  smtp-серверов.

  smtpServerList              - список имён ( или ip-адресов) SMTP-серверов
                                через ",". Пустая строка приравнивается
                                к pkg_Common.GetSmtpServer.

  Возврат:
    - коллекция адресов
*/
function ParseSmtpServerList(
  smtpServerList varchar2
)
return TColSmtpServer
is
                                       -- Результирующая коллекция
  colSmtpServer TColSmtpServer := TColSmtpServer();
                                       -- Указатели на символы в строке
  i integer := 1;
  j integer;
                                       -- Признак окончания разбора
  finished boolean := false;
                                       -- Длина строки списка
                                       -- имён smtp-серверов
  lengthSmtpList integer := coalesce( length( smtpServerList),0);

begin
  i := 1;
  for safeLoop in 1..lengthSmtpList+2
  loop
    j := coalesce( instr( smtpServerList, ',', i, 1),0);
    if j = 0 then
      j := lengthSmtpList + 1;
      finished := true;
      logger.Trace( 'finished');
    end if;
    logger.Trace( 'i=' || to_char( i));
    logger.Trace( 'j=' || to_char( j));
                                     -- Получаем следующий элемент
    colSmtpServer.extend;
    colSmtpServer( colSmtpServer.last)
      := coalesce(
           replace(
             substr( smtpServerList
                     , i
                     , j-i
                   )
             , ' '
           )
           , pkg_Common.GetSmtpServer
         );
    logger.Debug( 'add smtp: '
      || '"' || colSmtpServer( colSmtpServer.last) || '"'
    );
    exit when
      finished;
    i := j + 1;
  end loop;
  return
    colSmtpServer;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack(
        'Ошибка разбора строки списка адресов smtp('
        || 'smtpServerList="' || smtpServerList || '"'
        || ')'
      )
    , true
  );
end ParseSmtpServerList;

/* func: NotifyError
  Информирует об ошибках ( по e-mail) и возвращает число найденных ошибок.

  Параметры:
  sendLimit                   - лимит времени, в течении которого должна быть
                                произведена попытка отправки сообщения ( при
                                передаче null будет использовано значение по
                                умолчанию)
  smtpServerList              - список имён ( или ip-адресов) SMTP-серверов
                                через ",". Пустая строка приравнивается
                                к pkg_Common.GetSmtpServer.

  Возврат:
    - количество ошибок
*/
function NotifyError(
  sendLimit interval day to second := null
  , smtpServerList varchar2 := null
)
return integer
is

                                        --Дата проверки
  checkTime timestamp with time zone := systimestamp;

                                        --Число ошибок
  nError integer := 0;
                                        --Текст сообщения
  msg varchar2( 30000);
                                        -- Коллекция smtp-серверов
  colSmtpServer TColSmtpServer;

  procedure ProcessSmtpServer(
    smtpServer varchar2
  )
  is
  -- Добавление сообщений по ошибкам
  -- по данному smtp
                                        --Используемый smtp-сервер
    usedSmtpServer varchar2( 512 ) :=
      coalesce( smtpServer, pkg_Common.GetSmtpServer );
                                        -- Создан ли заголовок
                                        -- для smtp-сервера
    headerCreated boolean := false;

    cursor curError( minSendTime timestamp with time zone) is
      select
        1 as show_order
        , ms.error_code
        , coalesce(
            ms.error_message
            , 'Длительно не отправляемые сообщения'
          )
          as error_message
        , count(*) as cnt
        , min( ms.date_ins) as min_date_ins
        , max( ms.date_ins) as max_date_ins
        , min( ms.process_date) as min_error_date
        , max( ms.process_date) as max_error_date
        , min( ms.send_date) as min_send_date
        , max( ms.send_date) as max_send_date
        , min( ms.message_id) as min_message_id
        , max( ms.message_id) as max_message_id
      from
        ml_message ms
      where
        ms.message_state_code = pkg_Mail.WaitSend_MessageStateCode
                                         -- Поле smtp_server должно совпадать с
                                         -- smtpServer, либо, в случае SMTP-сервера
                                         -- по-умолчанию, иметь значение null.
        and
        ( ms.smtp_server = usedSmtpServer
          or usedSmtpServer = pkg_Common.GetSmtpServer
          and ms.smtp_server is null
        )
        and (
          ms.error_code is not null
          or ms.send_date < minSendTime
          )
      group by
        ms.error_code
        , ms.error_message
      order by
        show_order
        , error_code nulls first
        , error_message
    ;
  -- ProcessSmtpServer
  begin
    pkg_TaskHandler.SetAction( 'ProcessSmtpServer('
      || smtpServer
      || ')'
    );
    for rec in curError(
      checkTime - coalesce( sendLimit, SendMessage_TimeLimit)
    )
    loop
                                        --Формируем текст сообщения
      if not headerCreated then
        msg := substr( msg
          || chr(10)
          || chr(10)
          || '* SMTP Server: ' || to_char( usedSmtpServer )
          || chr(10)
          , 1
          , 30000
        );
        headerCreated := true;
      end if;
      nError := nError + rec.cnt;
      msg := substr( msg
        || chr( 10) || '* '
        || case when rec.error_code is null then
            rec.error_message
          else
            'Ошибка обработки с кодом ORA' || to_char( rec.error_code, '00000')
          end
          || ' - ' || to_char( rec.cnt) || ' шт.'
          || chr( 10)
        || case when rec.error_code is not null
              and rec.error_message is not null
              then
            chr( 10)
            || rec.error_message
            || chr( 10)
          end
        || chr( 10)
          || 'date_ins:   '
            || to_char( rec.min_date_ins, 'dd.mm.yy hh24:mi:ss')
            || case when rec.min_date_ins <> rec.max_date_ins then
                ' - '
                || to_char( rec.max_date_ins, 'dd.mm.yy hh24:mi:ss')
              end
            || chr( 10)
          || case when rec.min_error_date is not null then
             'error_date: '
            || to_char( rec.min_error_date, 'dd.mm.yy hh24:mi:ss')
            || case when rec.min_error_date <> rec.max_error_date then
                ' - '
                || to_char( rec.max_error_date, 'dd.mm.yy hh24:mi:ss')
              end
            || chr( 10)
            end
          || case when rec.min_send_date is not null then
             'send_date:  '
            || to_char( rec.min_send_date, 'dd.mm.yy hh24:mi:ss')
            || case when rec.min_send_date <> rec.max_send_date then
                ' - '
                || to_char( rec.max_send_date, 'dd.mm.yy hh24:mi:ss')
              end
            || chr( 10)
            end
          ||
             'message_id: '
            || to_char( rec.min_message_id)
            || case when rec.min_message_id <> rec.max_message_id then
                ' - '
                || to_char( rec.max_message_id)
              end
            || chr( 10)
        , 1, 30000)
      ;
    end loop;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          'Ошибка добавления сообщений об ошибках ('
          || 'smtpServer="' || smtpServer || '"'
          || ')'
        )
      , true
    );
  end ProcessSmtpServer;
--NotifyError
begin
  colSmtpServer := ParseSmtpServerList(
    smtpServerList => smtpServerList
  );
                                        -- Формируем сообщение
  for i in 1..colSmtpServer.count loop
    ProcessSmtpServer(
      smtpServer => colSmtpServer(i)
    );
  end loop;
                                        -- Отправляем письмо по ошибкам
  if msg is not null then
    pkg_Common.SendMail(
      mailSender => pkg_Common.GetMailAddressSource( Module_Name)
      , mailRecipient => pkg_Common.GetMailAddressDestination
      , subject => Module_Name || ': error notification'
      , message =>
          rpad( 'Дата проверки: ', 35) || to_char( checkTime, 'dd.mm.yy hh24:mi:ss')
          || chr( 10)
          || rpad( 'Планируемая отправка не ранее:', 35) ||
                to_char( checkTime - coalesce( sendLimit, SendMessage_TimeLimit)
                         , 'dd.mm.yy hh24:mi:ss' )
          || chr( 10)
          || msg
    );
  end if;
  return nError;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( 'Ошибка при проверке ошибок обработки сообщений.' )
    , true
  );
end NotifyError;
/* func: ClearExpiredMessage
  Удаляет сообщения с истекшим сроком жизни и возвращает число удаленных
  сообщений.

  Параметры:
  checkDate                   - дата проверки ( по умолчанию текущая дата)

  Замечание:
  если сообщение входит в цепочку ( по source_message_id), то оно будет удалено
  только вместе со всей цепочкой ( т.е. когда у всех сообщений в цепочке
  истечет срок жизни).
  Вложенные сообщения удаляются при истечении срока жизни сообщения основного
  сообщения.
*/
function ClearExpiredMessage(
  checkDate date := null
)
return integer
is
                                        --Удаляемые сообщения
  cursor curExpiredMessage( checkDate date) is
    select
      d.message_id
    from
      (
      select
        ms.message_id
        , (
          select
            level
          from
            ml_message t
          where
            ----Выделяем корневое сообщение
            t.source_message_id is null
            ----Проверям всю цепочку от корня
            and not exists
              (
              select
                null
              from
                ml_message t2
              where
                t2.expire_date is null
                or t2.expire_date > checkDate
              start with
                t2.message_id = t.message_id
              connect by
                prior t2.message_id = t2.source_message_id
              )
          start with
            t.message_id = ms.message_id
          connect by
            prior t.source_message_id = t.message_id
          )
          as del_thread_level
      from
        ml_message ms
      where
        ms.expire_date <= checkDate
        and ms.parent_message_id is null
      ) d
    where
      d.del_thread_level is not null
    order by
      d.del_thread_level desc
      , d.message_id
  ;
                                        --Число удаленных сообщений
  nDeleted integer := 0;


--ClearExpiredMessage
begin
  savepoint pkg_MailHandler_DeleteExpMsg;
  for rec in curExpiredMessage( coalesce( checkDate, sysdate)) loop
    begin
      delete from
        ml_attachment atc
      where
        atc.message_id in
          (
          select
            ms.message_id
          from
            ml_message ms
          start with
            ms.parent_message_id is null
            and ms.message_id = rec.message_id
          connect by
            prior ms.message_id = ms.parent_message_id
          )
      ;
      delete from
        ml_message t
      where
        t.message_id in
          (
          select
            ms.message_id
          from
            ml_message ms
          start with
            ms.parent_message_id is null
            and ms.message_id = rec.message_id
          connect by
            prior ms.message_id = ms.parent_message_id
          )
      ;
      nDeleted := nDeleted + 1;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , 'Ошибка при удалении сообщения ('
          || ' message_id=' || to_char( rec.message_id)
          || ').'
        , true
      );
    end;
  end loop;
  return nDeleted;
exception when others then
  rollback to pkg_MailHandler_DeleteExpMsg;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack(
      'Ошибка при удалении сообщений с истекшим сроком жизни ('
      || ' checkDate=' || to_date( checkDate, 'dd.mm.yyyy hh24:mi:ss')
      || ').' )
    , true
  );
end ClearExpiredMessage;

/* func: ClearFetchRequest
  Удаляет запросы извлечения из ящика
  с датой создания до определённой
  даты

  Параметры:
  beforeDate                  - дата, до которой удалять запросы
*/
procedure ClearFetchRequest(
  beforeDate date
)
is
--ClearFetchRequest
begin
  delete from
    ml_fetch_request
  where
    date_ins <= beforeDate;
  logger.Debug('Удалено записей: ' || to_char( SQL%RowCount));
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack(
      'Ошибка при удалении запросов на извлечение ('
      || ' beforeDate=' || to_date( beforeDate, 'dd.mm.yyyy hh24:mi:ss')
      || ').' )
    , true
  );
end ClearFetchRequest;

/* func: SendMessageJava
  Отсылает ожидающие отправки сообщения.
*/
function SendMessageJava(
  smtpServer varchar2
  , maxMessageCount number
)
return number
is
language java name '
Mail.sendMessage(
  java.lang.String
  , java.math.BigDecimal
)
return java.math.BigDecimal
';
/* func: SendMessage
  Отправляет ожидающие отправки сообщения и возвращает число отправленных
  сообщений.

  Параметры:
  smtpServer                  - имя ( или ip-адрес) SMTP-сервера
                                Значение null приравнивается к pkg_Common.GetSmtpServer.
  maxMessageCount             - ограничение по количеству отправляемых сообщений
                                за один запуск процедуры. В случае передачи
                                null, ограничение не используется.

  Замечание:
  В вызываемой процедуре <SendMessageJava> происходит фиксация транзакции
  после каждого отправляемого Email-сообщения.
*/
function SendMessage(
  smtpServer varchar2 := null
  , maxMessageCount integer := null
)
return integer
is

                                        --Автономная транзакция, т.к.
                                        --обращаемся к внешним сервисам
  pragma autonomous_transaction;
                                        --Число отправленных сообщений
  nSend integer := 0;

--SendMessage
begin
  nSend := SendMessageJava(
     coalesce( smtpServer, pkg_Common.GetSmtpServer )
    , maxMessageCount - nSend
  );
  return nSend;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( 'Ошибка при отправке ожидающих отправки сообщений ('
      || ' smtpServer="' || smtpServer || '"'
      || ').' )
    , true
  );
end SendMessage;
/* func: SendHandler
  Обработчик отправки писем.

  Параметры:
  smtpServerList              - список имён ( или ip-адресов) SMTP-серверов
                                через ",".
                                Значение null приравнивается к pkg_Common.GetSmtpServer.
  maxMessageCount             - ограничение по количеству отправляемых сообщений
                                за один запуск процедуры. В случае передачи
                                null, ограничение не используется.

  Замечание:
  В вызываемой процедуре <body::SendMessage> происходит фиксация транзакции.
*/
procedure SendHandler(
  smtpServerList varchar2 := null
  , maxMessageCount integer := null
)
is

                                        --Флаг завершения работы
  isFinish boolean := false;
                                        --SID и serial# сессии обработчика
  handlerSid number;
  handlerSerial number;
                                        --Проверка поступления команды
                                        --Интервал в секундах
  checkCommandTimeout number;
                                        --Время последней проверки команд
  lastCommandCheck number;
                                        --Время последней проверки
  lastRequestCheck number;
                                        --Интервал проверки в секундах
  checkRequestTimeout number;

                                        --Имя текущей команды
  command varchar2(50) := null;
                                        --Признак необходимости обработки
                                        --запросов
  isProcessRequest boolean := false;
                                        --Количество отправленных
                                        --сообщений
  sentMessageCount integer := 0;
                                        --Коллекция имён smtp-серверов
  colSmtpServer TColSmtpServer;

  procedure Initialize is
  --Выполняем подготовительные действия

  --Initialize
  begin
                                        --Инициализируем обработчик
    pkg_TaskHandler.InitHandler(
      moduleName                  => Module_Name
      , processName               => 'SendHandler'
         || '('
         || coalesce(
              case
                when length( smtpServerList ) > 25 then
                  substr( smtpServerList, 1, 15 ) || '...' ||
                  substr( smtpServerList, -7 )
                else
                  smtpServerList
              end
              , 'null' )
         || ')'
    );
                                        --Определяем таймауты
    checkCommandTimeout :=
      pkg_TaskHandler.ToSecond( CheckCommand_Timeout);
    checkRequestTimeout :=
      pkg_TaskHandler.ToSecond( CheckNewRequest_Timeout);
                                        --Сохраняем идентификаторы сессии
    handlerSid          := pkg_Common.GetSessionSid;
    handlerSerial       := pkg_Common.GetSessionSerial;
                                        -- Разбираем список адресов
    colSmtpServer := ParseSmtpServerList(
      smtpServerList => smtpServerList
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          'Ошибка инициализации обработчика'
        )
      , true
    );
  end Initialize;

  procedure Clean is
  --Выполняет очистку перед завершением работы

  --Clean
  begin
                                        --Устанавливаем информацию о состоянии
    pkg_TaskHandler.SetAction( 'clean');
    pkg_TaskHandler.CleanHandler;
  end Clean;

  function CheckNewRequest
  return boolean
  is
  --Проверка поступления новых запросов.

    isFound integer;

  --CheckNewRequest
  begin
    logger.Trace( 'check new request');
                                        -- Проверяем сообщения по указанным
                                        -- smtp-серверам
    for i in 1..colSmtpServer.count loop
      select
        count(*)
      into
        isFound
      from
        ml_message ms
      where
        ms.message_state_code = pkg_Mail.WaitSend_MessageStateCode
                                         -- Поле smtp_server должно совпадать с
                                         -- smtpServer, либо, в случае SMTP-сервера
                                         -- по-умолчанию, иметь значение null.
        and
        ( ms.smtp_server = colSmtpServer(i)
          or colSmtpServer(i) = pkg_Common.GetSmtpServer
          and ms.smtp_server is null
        )
        and ms.send_date <= systimestamp
        and rownum <= 1
      ;
      if isFound > 0 then
        return true;
      end if;
    end loop;
    return false;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
           'Ошибка при проверке поступления новых запросов для обработки.'
        )
      , true
    );
  end CheckNewRequest;

  procedure WaitEvent
  is
  --Ожидает наступление какого-либо события.

                                        --Текущее время
    currentTime number;
                                        --Время ожидания (в 100-x секунды)
    waitTimeout number;

  --WaitEvent
  begin
                                        --Устанавливаем информацию о состоянии
    logger.Trace( 'start wait event');
    pkg_TaskHandler.SetAction( 'idle');
    loop
                                        --Определяем таймаут ожидания
      currentTime := pkg_TaskHandler.GetTime();
      waitTimeout :=
        checkRequestTimeout
          - pkg_TaskHandler.TimeDiff( currentTime, lastRequestCheck);
                                        --Проверка поступления команды
      if waitTimeout > 0
          or pkg_TaskHandler.NextTime( lastCommandCheck, checkCommandTimeout)
          then
        logger.Trace( 'get command: waitTimeout=' || waitTimeout);
        if pkg_TaskHandler.GetCommand( command, waitTimeout) then
          lastCommandCheck := null;
          exit;
        else
          lastCommandCheck := pkg_TaskHandler.GetTime();
        end if;
      end if;
                                        --Проверка изменений в таблице запросов
      if pkg_TaskHandler.NextTime( lastRequestCheck, checkRequestTimeout) then
        if CheckNewRequest then
          isProcessRequest := true;
          lastRequestCheck := null;
          exit;
        end if;
      end if;
    end loop;
  end WaitEvent;

  procedure ProcessRequest
  is
  --Обработка запроса.
                                        --Число отправленных сообщений
    nSend integer;

  --ProcessRequest
  begin
    logger.Trace( 'process request');
                                       -- Устанавливаем информацию о состоянии
    pkg_TaskHandler.SetAction( 'send mail');
                                       -- Выполняем отправку сообщений
                                       -- c ограничением по количеству записей
                                       -- для каждого smtp-сервера
    for i in 1..colSmtpServer.count loop
      nSend := SendMessage(
        smtpServer => colSmtpServer(i)
        , maxMessageCount => maxMessageCount - sentMessageCount
      );
      logger.Trace( 'sent count: ' || nSend);
      sentMessageCount := sentMessageCount + nSend;
                                       -- Если отправили максимально допустимое
                                       -- количество сообщений, то выходим
                                       -- из цикла SendHandler
      if sentMessageCount >= maxMessageCount then
        isFinish := true;
        exit;
      end if;
    end loop;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(  'Ошибка при отправке сообщений.' )
      , true
    );
  end ProcessRequest;

  procedure ProcessCommand
  is
  --Выполняет команду, полученную через управляющий пайп.

  --ProcessCommand
  begin
    logger.Trace( 'process command: ' || command);
    pkg_TaskHandler.SetAction( 'process command', command);
                                    --Обрабатываем команду
    case command
      when pkg_TaskHandler.Stop_Command then
        isFinish := true;
      else
        raise_application_error(
          pkg_Error.IllegalArgument
          , 'Получена неизвестная управляющая команда "' || command || '".'
        );
    end case;
  end ProcessCommand;

  procedure ProcessEvent
  is
  --Обрабатывает событие.

  --ProcessEvent
  begin
    case
                                        --Обрабатываем команду
      when command is not null then
        ProcessCommand;
        command := null;
                                        --Обработка запроса
      when isProcessRequest then
        ProcessRequest;
        isProcessRequest := false;
      else
        raise_application_error(
          pkg_Error.ProcessError
          , 'Получено неизвестное событие внутри цикла обработки.'
        );
    end case;
  end ProcessEvent;

--SendHandler
begin
  Initialize;                           --Выполняем подготовительные действия
  loop
    WaitEvent;                          --Ждем событие
    ProcessEvent;                       --Обрабатываем событие
    exit when isFinish;                 --Выходим, если установлен флаг
  end loop;
  Clean;                                --Выполняем очистку перед выходом
exception when others then
  Clean;                                --Выполняем очистку перед выходом
  raise;
end SendHandler;

/* func: ProcessFetchRequest
  Обработка текущих запросов на извлечение из ящиков

  Параметры:
    batchShortName                     - обработка запросов только от
                                         определённого прикладного батча
    fetchRequestId                     - параметр для обработки
                                         определённого запроса

  Возврат:
    - количество обработанных запросов
*/
function ProcessFetchRequest(
  batchShortName varchar2 := null
  , fetchRequestId integer := null
)
return integer
is

  cursor curLockFetchRequest(
    fetchRequestId integer
    , batchShortName varchar2
    , maxRequestCount integer
  )
  is
                                       -- Для использования
                                       -- доступа по первичному ключу
    select /*+ordered*/
      r.fetch_request_id as fetch_request_id
      , r.url as url
      , r.password as password
      , r.recipient_address as recipient_address
      , r.is_got_message_deleted as is_got_message_deleted
    from
      ml_fetch_request r
    where
      fetch_request_id in
      (
      select
        fetch_request_id
      from
      (
      select
        fetch_request_id
      from
        v_ml_fetch_request_wait w
      where
                                       -- Если соотв. параметр не задан
                                       -- то условие не применяется
        ( fetchRequestId is null
          or w.fetch_request_id = fetchRequestId
        )
        and
        ( batchShortName is null
          or batchShortName = batch_short_name
        )
                                       -- Записи ещё не захвачены другим
                                       -- сеансом
        and
        (
          handler_sid is null
          or not exists
          (
          select
            null
          from
            v$session ss
          where
            ss.sid = w.handler_sid
            and ss.serial# = w.handler_serial#
          )
        )
                                     -- Упорядочиваем записи
                                     -- при заливке в массив
      order by
        w.priority_order desc nulls last
        , w.fetch_request_id
      )
    where
      rownum <= maxRequestCount
    )
    for update of
      r.request_state_code
      , r.handler_sid
      , r.handler_serial#
      , r.handler_reserved_time
      , r.processed_time
      , r.result_message_count
    nowait;
                                       -- Атрибуты сеанса обработки
  handlerSid number := pkg_Common.GetSessionSid;
  handlerSerial# number := pkg_Common.GetSessionSerial;
                                       -- Извлечённая запись
  recRequest curLockFetchRequest%rowtype;
                                       -- Удалось ли извлечь запись
  gotRequest boolean;
                                       -- Результаты обработки запроса
  fetchedCount integer;
  errorMessage varchar2( 4000);
  errorCode integer;
  requestStateCode ml_fetch_request.request_state_code%type;
                                       -- Количество обработанных записей
  nProcessed integer := 0;
                                       -- Количество ошибок
  nError integer := 0;

  procedure ReserveRequest
  is

    procedure GetRequest
    is
    -- Открытие курсора и получения массива
    begin
      gotRequest := false;
      open
        curLockFetchRequest(
          fetchRequestId => fetchRequestId
          , batchShortName => batchShortName
          , maxRequestCount => 1
        );
                                       -- Извлекаем данные из курсора
      fetch
        curLockFetchRequest
      into
        recRequest;
      gotRequest := curLockFetchRequest%FOUND;

      close curLockFetchRequest;
    exception when others then
      if curLockFetchRequest%ISOPEN then
        close curLockFetchRequest;
      end if;
                                       -- Если не удаётся зарезервировать
      if SQLCODE = pkg_Error.ResourceBusyNowait then
        logger.Debug( 'Could not lock request: resource busy');
      else
        logger.Error( 'Could not lock request: ' || SQLERRM);
      end if;
    end GetRequest;

  begin
    pkg_TaskHandler.SetAction( 'reserve' );
                                       -- Получаем id записей
    GetRequest;
                                       -- Запрос получен
    if gotRequest then
                                       -- Присваиваем записям атрибуеты сеанса
      update
        ml_fetch_request r
      set
        r.handler_sid = handlerSid
        , r.handler_serial# = handlerSerial#
        , r.handler_reserved_time = systimestamp
        , r.handler_batch_short_name = pkg_MailInternal.GetBatchShortName
      where
        r.fetch_request_id = recRequest.fetch_request_id;
      logger.Debug('Зарезервирована запись'
        || '( fetch_request_id='
        || to_char( recRequest.fetch_request_id) || ')'
      );
    end if;
    pkg_TaskHandler.SetAction( '' );
  exception when others then
    pkg_TaskHandler.SetAction( '' );
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack( 'Ошибка резервирования записей' )
      , true
    );
  end ReserveRequest;

  procedure ProcessRequest
  -- Процедура обработки захваченной
  -- записи
  is
  -- ProcessRequest
  begin
    pkg_TaskHandler.SetAction( 'process fetch' );
    logger.Debug('fetch start: (fetch_request_id='
      || to_char( recRequest.fetch_request_id) || ')'
    );
    fetchedCount := pkg_Mail.FetchMessageImmediate(
      url => recRequest.url
      , password => recRequest.password
      , recipientAddress => recRequest.recipient_address
      , isGotMessageDeleted => recRequest.is_got_message_deleted
      , fetchRequestId => recRequest.fetch_request_id
      , errorMessage => errorMessage
      , errorCode => errorCode
    );
    logger.Debug('fetch finish: (fetch_request_id='
      || to_char( recRequest.fetch_request_id) || ')'
    );
                                       -- Увеличиваем счётчики
    if errorMessage is not null then
      nError := nError + 1;
      requestStateCode := pkg_MailInternal.Error_RequestStateCode;
    else
      nProcessed := nProcessed + 1;
      requestStateCode := pkg_MailInternal.Processed_RequestStateCode;
    end if;
    pkg_TaskHandler.SetAction( '' );
  exception when others then
    pkg_TaskHandler.SetAction( '' );
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          'Ошибка обработки записи request_id:'
          || '( fetch_request_id='
          || to_char( recRequest.fetch_request_id) || ')'
        )
      , true
    );
  end ProcessRequest;

  procedure UpdateRequest
  is
  -- Обновление информации о загрузке
  begin
    pkg_TaskHandler.SetAction( 'update request' );
    update
      ml_fetch_request r
    set
      request_state_code = requestStateCode
      , error_code = errorCode
      , error_message = errorMessage
      , processed_time  = systimestamp
      , result_message_count = fetchedCount
    where
      fetch_request_id = recRequest.fetch_request_id
    ;
    logger.Debug('Установлен статус обработки: "'
      || requestStateCode || '"');
    pkg_TaskHandler.SetAction( '' );
  exception when others then
    pkg_TaskHandler.SetAction( '' );
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack( 'Ошибка обновления состояния запросов' )
      , true
    );
  end UpdateRequest;

begin
  loop
                                       -- Резервируем запись для обработки,
                                       -- записав информацию о потоке
    ReserveRequest;
    commit;
    exit when not gotRequest;
                                       -- Обрабатываем запись
    ProcessRequest;
                                       -- Обновляем запись
    UpdateRequest;
    commit;
  end loop;
  if nProcessed > 0 or nError > 0 then
    logger.Debug(
      'Обработано: '
      || to_char( nProcessed)
      || '; Ошибок: ' || to_char( nError)
    );
  end if;
  commit;
  return nProcessed + nError;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack(
        'Ошибка обработки запросов извлечения из ящиков.'
      )
    , true
  );
end ProcessFetchRequest;

/* proc: FetchHandler
  Обработчик запросов на извлечение из ящиков

  Параметры:
    checkRequestInterval               - интервал для проверки наличия запросов
                                         для обработки
    maxRequestCount                    - максимальное количество
                                         обрабатываемых запросов за запуск
    batchShortName                     - параметр для обработки запросов только от
                                         определённого прикладного батча
*/
procedure FetchHandler(
  checkRequestInterval interval day to second
  , maxRequestCount integer := null
  , batchShortName varchar2 := null
)
is
                                       -- Количество запросов
                                       -- для которых выполнена попытка обработки
  nCount integer := 0;
                                       -- Результат вызова ProcessFetchRequest
  nLastCount integer;
                                       -- Интервал между проверками
                                       -- наличия запросов
  checkRequestTimeout number
    := pkg_TaskHandler.ToSecond( checkRequestInterval );
begin
  pkg_MailInternal.InitHandler(
    processName  => 'FetchHandler'
  );
  logger.Debug( 'HandleRequest: checkRequestTimeout='
    || to_char( checkRequestTimeout)
  );
  loop
                                       -- Наступило время проверять запрос
    if pkg_MailInternal.NextRequestTime(
      checkRequestTimeout => checkRequestTimeout
    )
    then
                                       -- Проверяем команду,
                                       -- если наступило время
      if pkg_MailInternal.WaitForCommand(
           command => pkg_TaskHandler.Stop_Command
        )
      then
        exit;
      end if;
                                       -- Обработка при существовании
                                       -- запросов в состоянии ожидания
      nLastCount :=
         ProcessFetchRequest(
            batchShortName => batchShortName
         );
                                       -- Если запросы были обработаны
      if nLastCount > 0 then
        nCount := nCount + nLastCount;
                                       -- Если достигнут лимит, выходим
                                       -- из процедуры обработчика
        if nCount >= maxRequestCount then
          exit;
        end if;
        pkg_MailInternal.InitRequestCheckTime;
      end if;
    else
                                       -- Время проверки запроса не поступило
                                       -- Тогда проверяем команду
                                       -- с учётом интервала ожидания запроса
      if pkg_MailInternal.WaitForCommand(
        command => pkg_TaskHandler.Stop_Command
        , checkRequestTimeOut => checkRequestTimeout
      )
      then
        exit;
      end if;
    end if;
  end loop;
  pkg_TaskHandler.CleanHandler;
exception when others then
  pkg_TaskHandler.CleanHandler;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack(
        'Ошибка обработчика запросов извлечения из ящиков.'
      )
    , true
  );
end FetchHandler;


end pkg_MailHandler;
/
