create or replace package body pkg_Common is
/* package body: pkg_Common::body */



/* group: Константы */

/* iconst: Default_SmtpServer
  SMTP-сервер для отправки писем по умолчанию.
*/
Default_SmtpServer constant varchar2(30) := '';

/* iconst: Default_NotifyEmail
  Почтовый адрес по умолчанию для отправки писем с нотификацией из промышленных
  БД.
*/
Default_NotifyEmail constant varchar2(100) := '';

/* iconst: Default_NotifyEmail_Test
  Почтовый адрес по умолчанию для отправки писем с нотификацией из тестовых БД.
*/
Default_NotifyEmail_Test constant varchar2(100) := '';

/* iconst: MailSender_Domain
  Домен отправителя, указываемый при соединении с SMTP-сервером.
*/
MailSender_Domain constant varchar2(30) := '';

/* iconst: UpdateLongops_Timeout
  Периодичность обновления информации о выполнении длительной операции.
*/
UpdateLongops_Timeout constant interval day to second := INTERVAL '5' SECOND;



/* group: Переменные */

/* ivar: currentSessionSid
  SID текущей сессий.
*/
currentSessionSid number;

/* ivar: currentSessionSerial
  serial# текущей сессий.
*/
currentSessionSerial number;

/* ivar: databaseConfig
  Используемые в текущей сессии настройки БД.
*/
databaseConfig cmn_database_config%rowtype;

/* ivar: rindexSessionLongops
  Переменная для вызова dbms_application.set_session_longops.
*/
rindexSessionLongops binary_integer;

/* ivar: slnoSessionLongops
  Переменная для вызова dbms_application.set_session_longops.
*/
slnoSessionLongops binary_integer;

/* ivar: nextUpdateLongopsTick
  Служебная переменная для времени следующего обновления v$session_longops.
*/
nextUpdateLongopsTick number := null;



/* group: Функции */



/* group: Параметры сессии */

/* func: getInstanceName
  Возвращает имя текущей базы ( значение параметра INSTANCE_NAME).
*/
function getInstanceName
return varchar2
is
begin
  return sys_context( 'USERENV','INSTANCE_NAME');
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'Ошибка при получении instance_name.'
    , true
  );
end getInstanceName;

/* func: getSessionSid
  Возвращает SID текущей сессии.
*/
function getSessionSid
return number
is
begin
  if currentSessionSid is null then
    currentSessionSid := sys_context( 'USERENV','SID');
  end if;
  return currentSessionSid;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'Ошибка при получении sid текущей сессии.'
    , true
  );
end getSessionSid;

/* func: getSessionSerial
  Возвращает serial# текущей сессии.

  Замечания:
  - для компиляции пакета при отсутствии прав на v$session выборка производится
    через динамический SQL ( в случае отсутствия прав будет возникать ошибка
    при выполнении функции);
*/
function getSessionSerial
return number
is
begin
  if currentSessionSerial is null then

    -- Динамический SQL для исключения зависимости от прав на v$session
    execute immediate '
select
  ss.serial#
from
  v$session ss
where
  ss.sid = :sessionSid
'
    into
      currentSessionSerial
    using
      getSessionSid()
    ;
  end if;
  return currentSessionSerial;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'Ошибка при получении serial# текущей сессии.'
    , true
  );
end getSessionSerial;

/* func: getIpAddress
  Возвращает IP адрес текущего сервера БД.

  Замечания:
  - для успешного выполнения функции в Oracle 11 и выше нужны дополнительные права;
*/
function getIpAddress
return varchar2
is

  -- IP адрес текущего сервера
  ipAddress varchar2(16);

begin

  -- Функция возвращает IP адрес сервера БД.
  ipAddress := utl_inaddr.get_host_address();
  return ipAddress;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'Ошибка при определении ip-адреса текущего сервера БД.'
    , true
  );
end getIpAddress;



/* group: Настройки БД */

/* iproc: getDatabaseConfig
  Определяет настройки БД, если они не были определены ранее.
*/
procedure getDatabaseConfig
is

  instanceName cmn_database_config.instance_name%type;

begin
  if databaseConfig.instance_name is null then
    instanceName := getInstanceName();

    select
      coalesce( min( dc.instance_name), instanceName)
        as instance_name
      , coalesce( min( dc.is_production), 0)
        as is_production
      , coalesce( min( dc.smtp_server), Default_SmtpServer)
        as smtp_server
      , min( dc.notify_email) as notify_email
      , min( dc.ip_address_production) as ip_address_production
    into
      databaseConfig.instance_name
      , databaseConfig.is_production
      , databaseConfig.smtp_server
      , databaseConfig.notify_email
      , databaseConfig.ip_address_production
    from
      cmn_database_config dc
    where
      lower( dc.instance_name) = lower( instanceName)
    ;

    -- Считаем БД тестовой, если ip-адрес сервера не совпадает с заданным
    if databaseConfig.ip_address_production is not null
        -- условие поставлено перед следующим, чтобы обеспечить выполнение
        -- функции getIpAddress в тестовой БД ( для тестирования)
        and nullif( databaseConfig.ip_address_production, getIpAddress())
          is not null
        and databaseConfig.is_production = 1
        then
      databaseConfig.is_production := 0;
    end if;

    -- Определяем адрес отправки писем исходя из типа БД
    if databaseConfig.notify_email is null then
      databaseConfig.notify_email :=
        case when databaseConfig.is_production = 1 then
          Default_NotifyEmail
        else
          Default_NotifyEmail_Test
        end
      ;
    end if;

  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'Ошибка при определении настроек БД.'
    , true
  );
end getDatabaseConfig;

/* func: isProduction
  Возвращает 1, если функция выполняется в промышленной базе, в других случаях
  возвращает 0.
*/
function isProduction
return integer
is
begin
  getDatabaseConfig();
  return databaseConfig.is_production;
end isProduction;

/* group: Нотификация по e-mail */

/* func: getSmtpServer
  Возвращает имя ( или IP-адрес) доступного SMTP-сервера.
*/
function getSmtpServer
return varchar2
is
begin
  getDatabaseConfig();
  return databaseConfig.smtp_server;
end getSmtpServer;

/* func: getMailAddressSource
  Формирует исходящий почтовый адрес для отправки сообщений.

  Параметры:
  systemName                  - название системы или модуля, формирующего
                                сообщение ( например, "Scheduler",
                                "DataGateway")
*/
function getMailAddressSource(
  systemName varchar2 := null
)
return varchar2
is
begin
  getDatabaseConfig();
  return
    case when systemName is not null then
      systemName || '.'
    end
    || databaseConfig.instance_name
    || '.oracle@' || MailSender_Domain
  ;
end getMailAddressSource;

/* func: getMailAddressDestination
  Возвращает целевой почтовый адрес для отправки сообщений.
*/
function getMailAddressDestination
return varchar2
is
begin
  getDatabaseConfig();
  return databaseConfig.notify_email;
end getMailAddressDestination;

/* proc: sendMail
  Отправляет письмо по e-mail.

  Параметры:
  mailSender                  - адрес отправителя
  mailRecipient               - адрес получателя
  subject                     - тема письма
  message                     - текст письма
  smtpServer                  - SMTP-сервер для отправки письма ( по умолчанию
                                используется сервер, возвращаемый функцией
                                <getSmtpServer>)
*/
procedure sendMail(
  mailSender varchar2
  , mailRecipient varchar2
  , subject varchar2
  , message varchar2
  , smtpServer varchar2 := null
)
is

  -- Максимально возможное число симоволов для кодирования в одной строке с
  -- помощью Quoted-Printable
  MaxQpLineLength constant pls_integer := 76 / 3;

  -- Имя кодировки текста в БД
  DefaultCharset constant varchar2(30) := 'Windows-1251';

  -- Имя кодировки текста в БД
  BodyHeader constant varchar2(1024) :=
    'MIME-Version: 1.0' || utl_tcp.CRLF
    || 'Content-Type: text/plain; charset=' || DefaultCharset || utl_tcp.CRLF
    || 'Content-Transfer-Encoding: 8bit' || utl_tcp.CRLF
  ;

  -- Переменная "соединение"
  lConnection UTL_SMTP.CONNECTION;



  /*
    Открывает соединение с сервером.
  */
  procedure openConnection
  is
  begin
    lConnection := utl_smtp.open_connection(
      case when smtpServer is not null then
        smtpServer
      else
        getSmtpServer()
      end
    );

    -- Инициализация по данным домена
    utl_smtp.helo( lConnection, MailSender_Domain);

    -- Указываем адрес отправителя
    utl_smtp.mail( lConnection, mailSender);

    -- Указываем адрес получателя
    utl_smtp.rcpt( lConnection, mailRecipient);

    -- Открываем поток ввода
    utl_smtp.open_data( lConnection);
  end openConnection;



  /*
    Пишет поле заголовка.
  */
  procedure writeField(
    fieldName varchar2
    , fieldValue varchar2
    , isEncode boolean := false
  )
  is
  begin
    utl_smtp.write_data(
      lConnection
      , fieldName || ': ' || fieldValue || utl_tcp.CRLF
    );
  end writeField;



  /*
    Пишет поле заголовка, кодируя значение с помощью Quoted-Printable.
  */
  procedure writeEncodedField(
    fieldName varchar2
    , fieldValue varchar2
  )
  is

    len pls_integer := nvl( length( fieldValue), 0);
    i pls_integer := 1;
    k pls_integer;

  begin
    utl_smtp.write_data( lConnection, fieldName || ':');
    loop

      -- Обеспечиваем разбиение длинного текста на несколько строк
      exit when i > len;
      k := least( len - i + 1, MaxQpLineLength);
      utl_smtp.write_data( lConnection, ' =?' || DefaultCharset || '?Q?');
      utl_smtp.write_raw_data( lConnection
        , utl_encode.quoted_printable_encode(
            utl_raw.cast_to_raw( substr( fieldValue, i, k))
          )
      );
      utl_smtp.write_data( lConnection, '?=' || utl_tcp.CRLF);
      i := i + k;
    end loop;

    -- Завершаем поле, если не было значения
    if len = 0 then
      utl_smtp.write_data( lConnection, ' ' || utl_tcp.CRLF);
    end if;
  end writeEncodedField;



  /*
    Пишет заголовок письма.
  */
  procedure writeHeader
  is
  begin

    -- Указываем адрес отправителя для отображения
    writeField( 'From', mailSender);

    -- Указываем адрес получателя для отображения
    writeField( 'To', mailRecipient);

    -- Указываем тему
    writeEncodedField( 'Subject', subject);

    -- Пишем заголовок для тела сообщения
    utl_smtp.write_data( lConnection, BodyHeader);

    -- Завершаем заголовок
    utl_smtp.write_data( lConnection, utl_tcp.CRLF);
  end writeHeader;



  /*
    Указываем тело письма.
  */
  procedure writeBody
  is
  begin
    utl_smtp.write_raw_data(
      lConnection
      , utl_raw.cast_to_raw( message)
    );
  end writeBody;



  /*
    Закрывает соединение с сервером.
  */
  procedure closeConnection
  is
  begin

    -- Закрываем поток ввода
    utl_smtp.close_data( lConnection);

    -- Закрываем соединение с SMTP-сервером
    utl_smtp.quit( lConnection);
  end closeConnection;



-- sendMail
begin

  -- Открываем соединение с SMTP-сервером
  openConnection();

  -- Пишем заголовок сообщения
  writeHeader();

  -- Пишем текст письма
  writeBody();

  -- Закрываем соединение
  closeConnection();

exception

  -- Перехватываем некоторые возможные ошибки
  when utl_smtp.transient_error or utl_smtp.permanent_error then
    begin

      -- Закрываем соединение с сервером
      utl_smtp.quit(lConnection);

    -- Если SMTP-сервер упал или не доступен, т.е. мы не имеем с ним
    -- соединения, то при вызове quit вызовется исключение, которое мы
    -- игнорируем
    exception when utl_smtp.transient_error or utl_smtp.permanent_error then
      null;
    end;

    -- Выводим сообщение об ошибке, которая произошла при отправке письма
    raise_application_error(
      pkg_Error.MailSendingError
      , 'Ошибка при отправке письма: ' || SQLERRM
    );
end sendMail;



/* group: Прогресс длительных операций */

/* proc: startSessionLongops
  Добавляет в представление v$session_longops строку для длительно выполняющейся
  операции.

  Параметры:
  operationName               - название выполняемой операции
  units                       - единица измерения объема работы
  target                      - ID объекта, над которым совершается операция
  targetDesc                  - описание объекта, над которым совершается
                                опеация
  sofar                       - объем выполненных работ
  totalWork                   - общий объем работы
  contextValue                - числовое значение, относящееся к текущему
                                состоянию
*/
procedure startSessionLongops(
  operationName varchar2
  , units varchar2 := null
  , target binary_integer := 0
  , targetDesc varchar2 := 'unknown target'
  , sofar number := 0
  , totalWork number := 0
  , contextValue binary_integer := 0
)
is
begin

  -- Устанавливаем в начальные значения
  rindexSessionLongops := dbms_application_info.set_session_longops_nohint;
  slnoSessionLongops := null;
  nextUpdateLongopsTick := null;

  -- Создаем строку для операции
  dbms_application_info.set_session_longops(
    rindex        => rindexSessionLongops
    , slno        => slnoSessionLongops
    , op_name     => operationName
    , units       => units
    , target      => target
    , target_desc => targetDesc
    , sofar       => sofar
    , totalwork   => totalWork
    , context     => contextValue
  );
end startSessionLongops;

/* proc: setSessionLongops
  Периодически обновляет прогресс выполнения текущей операции.

  Параметры:
  sofar                       - объем выполненных работ
  totalWork                   - общий объем работы
  contextValue                - числовое значение, относящееся к текущему
                                состоянию
*/
procedure setSessionLongops(
  sofar number
  , totalwork number
  , contextvalue binary_integer
)
is

  curTick number := dbms_utility.get_time();

begin

  -- Проверяем необходимость обновления
  if nextUpdateLongopsTick is null
      or nullif( totalWork, sofar) is null
      or curTick >= nextUpdateLongopsTick
      then
    dbms_application_info.set_session_longops(
      rindex        => rindexSessionLongops
      , slno        => slnoSessionLongops
      , sofar       => sofar
      , totalwork   => totalWork
      , context     => contextValue
    );
    nextUpdateLongopsTick := curTick +
      (
      extract( SECOND from UpdateLongops_Timeout)
      + extract( MINUTE from UpdateLongops_Timeout) * 60
      ) * 100
    ;
  end if;
end setSessionLongops;



/* group: Функции преобразования */

/* func: transliterate
  Transliterate Russian source text into Latin.

  Parameters:
  source                      - Russian source text.
*/
function transliterate(
  source in varchar2
)
return string
is

  -- Auxiliary variable.
  tmpSource varchar2(8000);

begin

  -- Transliterate the main part of cases
  tmpSource := translate(Source,
    'АаБбВвГгДдЕеЗзИиЙйКкЛлМмНнОоПпРрСсТтУуФфХхЦцЫыЬьЪъЭэ',
    'AaBbVvGgDdEeZzIiJjKkLlMmNnOoPpRrSsTtUuFfHhCcYy''''''''Ee');

  -- Special cases of transliteration
  tmpSource := replace(tmpSource, 'Ё', 'Jo');
  tmpSource := replace(tmpSource, 'ё', 'jo');
  tmpSource := replace(tmpSource, 'Ж', 'Zh');
  tmpSource := replace(tmpSource, 'ж', 'zh');
  tmpSource := replace(tmpSource, 'Ч', 'Ch');
  tmpSource := replace(tmpSource, 'ч', 'ch');
  tmpSource := replace(tmpSource, 'Ш', 'Sh');
  tmpSource := replace(tmpSource, 'ш', 'sh');
  tmpSource := replace(tmpSource, 'Щ', 'Sch');
  tmpSource := replace(tmpSource, 'щ', 'sch');
  tmpSource := replace(tmpSource, 'Ю', 'Ju');
  tmpSource := replace(tmpSource, 'ю', 'ju');
  tmpSource := replace(tmpSource, 'Я', 'Ja');
  tmpSource := replace(tmpSource, 'я', 'ja');

  return tmpSource;
end transliterate;

/* func: numberToWord
  Преобразовывает сумму числом в сумму прописью.
  Минимальное число: нуль рублей.
  Максимальное число: триллион рублей минус одна копейка (999999999999.99)
  Если число не может быть преобразовано в строку, функция возвращает строку
  '############################################## копеек'

  Параметр:
  source                      - сумма числом
*/
function numberToWord(
  source number
)
return varchar2
is

  -- Возвращаемая строка
  str varchar2(300);

begin

  -- Если входной параметр null, возвращаем null
  if source is null then
     return null;
  end if;

  -- k - копейки
  str := ltrim( to_char( source,
    '9,9,,9,,,,,,9,9,,9,,,,,9,9,,9,,,,9,9,,9,,,.99')) || 'k';

  -- t - тысячи; m - милионы; M - миллиарды;
  str := replace( str, ',,,,,,', 'eM');
  str := replace( str, ',,,,,', 'em');
  str := replace( str, ',,,,', 'et');

  -- e - единицы; d - десятки; c - сотни;
  str := replace( str, ',,,', 'e');
  str := replace( str, ',,', 'd');
  str := replace( str, ',', 'c');
  --
  str := replace( str, '0c0d0et', '');
  str := replace( str, '0c0d0em', '');
  str := replace( str, '0c0d0eM', '');
  --
  str := replace( str, '0c', '');
  str := replace( str, '1c', 'сто ');
  str := replace( str, '2c', 'двести ');
  str := replace( str, '3c', 'триста ');
  str := replace( str, '4c', 'четыреста ');
  str := replace( str, '5c', 'пятьсот ');
  str := replace( str, '6c', 'шестьсот ');
  str := replace( str, '7c', 'семьсот ');
  str := replace( str, '8c', 'восемьсот ');
  str := replace( str, '9c', 'девятьсот ');
  --
  str := replace( str, '1d0e', 'десять ');
  str := replace( str, '1d1e', 'одиннадцать ');
  str := replace( str, '1d2e', 'двенадцать ');
  str := replace( str, '1d3e', 'тринадцать ');
  str := replace( str, '1d4e', 'четырнадцать ');
  str := replace( str, '1d5e', 'пятнадцать ');
  str := replace( str, '1d6e', 'шестнадцать ');
  str := replace( str, '1d7e', 'семнадцать ');
  str := replace( str, '1d8e', 'восемнадцать ');
  str := replace( str, '1d9e', 'девятнадцать ');
  --
  str := replace( str, '0d', '');
  str := replace( str, '2d', 'двадцать ');
  str := replace( str, '3d', 'тридцать ');
  str := replace( str, '4d', 'сорок ');
  str := replace( str, '5d', 'пятьдесят ');
  str := replace( str, '6d', 'шестьдесят ');
  str := replace( str, '7d', 'семьдесят ');
  str := replace( str, '8d', 'восемьдесят ');
  str := replace( str, '9d', 'девяносто ');
  --
  str := replace( str, '0e', '');
  str := replace( str, '5e', 'пять ');
  str := replace( str, '6e', 'шесть ');
  str := replace( str, '7e', 'семь ');
  str := replace( str, '8e', 'восемь ');
  str := replace( str, '9e', 'девять ');
  --
  str := replace( str, '1e.', 'один рубль ');
  str := replace( str, '2e.', 'два рубля ');
  str := replace( str, '3e.', 'три рубля ');
  str := replace( str, '4e.', 'четыре рубля ');
  str := replace( str, '1et', 'одна тысяча ');
  str := replace( str, '2et', 'две тысячи ');
  str := replace( str, '3et', 'три тысячи ');
  str := replace( str, '4et', 'четыре тысячи ');
  str := replace( str, '1em', 'один миллион ');
  str := replace( str, '2em', 'два миллиона ');
  str := replace( str, '3em', 'три миллиона ');
  str := replace( str, '4em', 'четыре миллиона ');
  str := replace( str, '1eM', 'один миллиард ');
  str := replace( str, '2eM', 'два миллиарда ');
  str := replace( str, '3eM', 'три миллиарда ');
  str := replace( str, '4eM', 'четыре миллиарда ');
  --
  str := replace( str, '11k', '11 копеек');
  str := replace( str, '12k', '12 копеек');
  str := replace( str, '13k', '13 копеек');
  str := replace( str, '14k', '14 копеек');
  str := replace( str, '1k', '1 копейка');
  str := replace( str, '2k', '2 копейки');
  str := replace( str, '3k', '3 копейки');
  str := replace( str, '4k', '4 копейки');
  --
  str := replace( str, '.', 'рублей ');
  str := replace( str, 't', 'тысяч ');
  str := replace( str, 'm', 'миллионов ');
  str := replace( str, 'M', 'миллиардов ');
  str := replace( str, 'k', ' копеек');

  -- Данный блок нужен для корректной обработки суммы 0 рублей
  if substr( str, 1, 6) = 'рублей' then
     str := 'нуль '|| str;
  end if;

  return str;
end numberToWord;

/* func: getStringByDelimiter
  Функция достаёт часть строки по позиции и разделителю.

  Параметры:
  initString                  - строка, в которой осуществляется поиск
  delimiter                   - разделитель
  position                    - номер подстроки ( начиная с 1)
*/
function getStringByDelimiter(
  initString varchar2
  , delimiter varchar2
  , position integer := 1
)
return varchar2
is

  strPosition integer := 0;
  strLength integer := 0;

begin

  -- проверка на "дурака"
  if position < 1
        or position is null
        or instr( initString, delimiter) = 0 and position = 1
      then
    return initString;
  end if;

  -- Если нам задали несуществующий номер подстроки, тоже возвратим null
  if instr( initString, delimiter, 1, position) = 0
        and instr( initString, delimiter, 1, position - 1) = 0
      then
    return null;
  end if;

  if position > 1 then
    strPosition := instr( initString, delimiter, 1, position - 1);
    strLength :=
      instr( initString, delimiter, 1, position)
      - instr( initString, delimiter, 1, position - 1)
    ;
  elsif position = 1 then
    strPosition := 0;
    strLength := instr( initString, delimiter, 1, position);
  end if;

  -- Если у нас последняя часть строки
  if strLength < 0 then
    strLength :=
      length( initString)
      - instr( initString, delimiter, 1, position - 1) + 1
    ;
  end if;
  return substr( initString, strPosition + 1, strLength - 1);
end getStringByDelimiter;

/* func: split
  Функция разделяет строку по заданному разделителю и преобразует к таблице
  для обработки и использования в запросах.

  Параметры:
  initString                  - входная строка для разбора
  delimiter                   - разделитель ( по умолчанию ',')

  Возвращаемое значение:
  nested table со значениями преобразованной строки.

  Пример использования:

  (code)

  select column_value as result from table( pkg_Common.split( '1,4,3,23', ','));

  (end)

*/
function split(
  initString varchar2
  , delimiter varchar2 := ','
)
return cmn_string_table_t
pipelined
is

  lIdx pls_integer;
  lList varchar2(32767) := initString;
  lValue varchar2(32767);

begin
  loop
    lIdx := instr( lList, delimiter);
    if lIdx > 0 then
      pipe row( substr( lList, 1, lIdx - 1));
      lList := substr( lList, lIdx + length( delimiter));
    else
      pipe row( lList);
      exit;
    end if;
  end loop;
  return;
end split;

/* func: split( CLOB)
  Функция разделяет объект типа Clob по заданному разделителю и преобразует к таблице
  для обработки и использования в запросах.

  Входные параметры:
    initClob                    - входной объект типа Clob для разбора
    delimiter                   - разделитель

  Возврат:
    nested table со значениями преобразованного объекта типа Clob.
*/
function split(
  initClob clob
  , delimiter varchar2 := ','
)
return cmn_string_table_t
pipelined
is
  currentIndex pls_integer;
  nextIndex pls_integer := 1;

-- split
begin
  for safeLoopIndex in 1..100000 loop
    currentIndex := nextIndex;
    nextIndex := dbms_lob.instr( delimiter || initClob, delimiter, currentIndex + length( delimiter));

    if safeLoopIndex >= 100000 then
      raise_application_error(
        pkg_Error.IllegalArgument
        , 'Сработала защита от зацикливания '
          || '( ' || to_char( safeLoopIndex) || ' итераций)'
      );
    end if;

    if nextIndex > 0 then
      pipe row(
        dbms_lob.substr(
          delimiter || initClob
          , nextIndex - currentIndex - length( delimiter)
          , currentIndex + length( delimiter)
        )
      );
    else
      pipe row(
        dbms_lob.substr(
          delimiter || initClob
          , dbms_lob.getlength( delimiter || initClob) - currentIndex
          , currentIndex + length( delimiter)
        )
      );
      exit;
    end if;
  end loop;
  return;
end split;



/* group: Отладка */

/* proc: outputMessage
  Выводит текстовое сообщение через dbms_output.
  Строки сообщения, длина которых больше 255 символов, при выводе автоматически
  разбиваются на строки допустимого размера ( в связи ограничением на длину
  строки в процедуре dbms_output.put_line).

  Параметры:
  messageText                 - текст сообщения

  Замечания:
  - разбивка при выводе слишком длинных строк сообщения по возможности
    производится по символу новой строки ( 0x0A) либо перед пробелом;
*/
procedure outputMessage(
  messageText varchar2
)
is

  -- Максимальная длина вывода
  Max_OutputLength constant pls_integer:= 255;

  -- Длина строки
  len pls_integer := coalesce( length( messageText), 0);

  -- Стартовая позиция для текущего вывода
  i pls_integer := 1;

  -- Стартовая позиция для следующего вывода
  i2 pls_integer;

  -- Конечная позиция для текущего вывода ( не включая)
  k pls_integer := null;

-- outputMessage
begin
  loop
    i2 := len + 1;
    if i2 - i > Max_OutputLength then
      i2 := i + Max_OutputLength;

      -- Пытаемся разбить строку по символу новой строки
      k := instr( messageText, chr(10), i2 - len - 1);
      if k >= i then
        i2 := k + 1;
      else
        k := instr( messageText, ' ', i2 - len - 1);
        if k > i then
          i2 := k;
        else
          k := i2;
        end if;
      end if;
    elsif i > 1 then
      k := i2;
    end if;
    dbms_output.put_line(
      case when k is not null then
        substr( messageText, i, k - i)
      else
        messageText
      end
    );
    exit when i2 > len;
    i := i2;
  end loop;
end outputMessage;

end pkg_Common;
/
