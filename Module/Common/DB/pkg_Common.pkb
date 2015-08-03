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
  Возвращает имя текущей базы.
*/
function getInstanceName
return varchar2
is

  -- Имя текущего экземпляра
  instanceName varchar2(16);

  -- Временная переменная целого типа
  intValue binary_integer;

begin
  -- Функция возвращает значение указанного параметра в переменные intValue и
  -- strValue и тип параметра: 0 - integer/boolean 1 - string/file
  if dbms_utility.get_parameter_value( 'instance_name', intValue, instanceName)
      = 1 then
    null;
  else
    raise_application_error(
      pkg_Error.TypeMismatch
      , 'Параметр "instance_name" не является типом String.'
    );
  end if;
  return instanceName;
end getInstanceName;

/* iproc: getSessionId
  Получает sid и serial# текущей сессии и сохраняет в переменных пакета.
  Для компиляции пакета при отсутствии прав на v$session выборка производится
  через динамический SQL ( в случае отсутствия прав возникнет ошибка при
  выполнении процедуры).
*/
procedure getSessionId
is
begin
  if currentSessionSid is null then
    -- Динамический SQL для исключения зависимости от прав на v$session
    execute immediate '
select
  ss.sid
  , ss.serial#
from
  v$session ss
where
  ss.sid = ( select ms.sid from v$mystat ms where rownum = 1)
'
    into
      currentSessionSid
      , currentSessionSerial
    ;
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , 'Ошибка при получении sid и serial# текущей сессии.'
    , true
  );
end getSessionId;

/* func: getSessionSid
  Возвращает SID текущей сессии.
*/
function getSessionSid
return number
is
begin
  getSessionId();
  return currentSessionSid;
end getSessionSid;

/* func: getSessionSerial
  Возвращает serial# текущей сессии.
*/
function getSessionSerial
return number
is
begin
  getSessionId();
  return currentSessionSerial;
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
  Перегруженная функция разделяет строку по заданному разделителю и
  преобразует к таблице для обработки и использования в запросах.
  Функция аналогична функции <split>, но обрабатывает входную строку типа CLOB.

  Параметры:
  initClob                    - входная строка для разбора
  delimiter                   - разделитель

  Возвращаемые значения:
  nested table со значениями преобразованной строки.
*/
function split(
  initClob clob
  , delimiter varchar2 := ','
)
return cmn_string_table_t
pipelined
is

  lIdx pls_integer;
  lList clob :=  initClob;

begin
  loop
    lIdx := dbms_lob.instr(lList,delimiter);

    if lIdx > 0 then
      pipe row( dbms_lob.substr( lList, lIdx - 1));
      lList := dbms_lob.substr( lList, 32767, lIdx + length( delimiter));
    else
      pipe row( dbms_lob.substr( lList));
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


/* group: Функции для работы со склонением ФИО по падежам */

/* ifunc: getExceptionCase
  Функция поиска записи в справочнике исключений.

  Входные параметры:
    stringNativeCase            - Строка исключения в именительном падеже
    sexCode                     - Пол (M –мужской, W - женский)
    typeExceptionCode           - Тип исключения

  Возврат:
    запись со всеми полями представления <v_cmn_case_exception>.
*/
function getExceptionCase(
  stringNativeCase varchar2
  , sexCode varchar2
  , typeExceptionCode varchar2
)
return v_cmn_case_exception%rowtype
is
  -- Запись с исключением
  exceptionRec v_cmn_case_exception%rowtype;

-- getExceptionCase
begin
  select
    *
  into
    exceptionRec
  from
    v_cmn_case_exception ce
  where
    upper( trim( ce.native_case_name ) ) = upper( trim( stringNativeCase ) )
    and ce.sex_code = sexCode
    and ce.type_exception_code = typeExceptionCode
  ;

  return exceptionRec;

exception
  when no_data_found then
    return null;
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Во время поиска записи в справочнике исключений'
        || ' произошла ошибка ('
        || sqlerrm
        || ').'
      , true
    );
end getExceptionCase;

/* iproc: mergeExceptionCase
  Процедура добавления/обновления записи в справочнике исключений.
  Работает в автономной транзации для уменьшения количества блокировок
  таблицы исключений.

  Входные параметры:
    stringException             - Строка исключения
    stringNativeCase            - Строка исключения в именительном падеже
    sexCode                     - Пол (M –мужской, W - женский)
    typeExceptionCode           - Тип исключения
    caseCode                    - код падежа,
                                  (NAT – именительный, GEN -  родительный
                                  , DAT-дательный, ACC – винительный
                                  , ABL- творительный, PREP- предложный)
    operatorId                  - ИД оператора

  Выходные параметры отсутствуют.
*/
procedure mergeExceptionCase(
  stringException varchar2
  , stringNativeCase varchar2
  , sexCode varchar2 default Women_SexCode
  , typeExceptionCode varchar2
  , caseCode varchar2
  , operatorId integer
)
is
  pragma autonomous_transaction;

-- mergeExceptionCase
begin
  -- Добавляем/обновляем данные в таблице исключений
  merge into
    cmn_case_exception dst
  using
    (
    select
      stringNativeCase as native_case_name
      , upper( trim( sexCode ) ) as sex_code
      , upper( trim( typeExceptionCode ) ) as type_exception_code
      , decode(
          upper( trim( caseCode ) )
          , pkg_Common.Genetive_CaseCode
          , initcap( stringException )
          , null
        ) as genetive_case_name
      , decode(
          upper( trim( caseCode ) )
          , pkg_Common.Dative_CaseCode
          , initcap( stringException )
          , null
        ) as dative_case_name
      , decode(
          upper( trim( caseCode ) )
          , pkg_Common.Accusative_CaseCode
          , initcap( stringException )
          , null
        ) as accusative_case_name
      , decode(
          upper( trim( caseCode ) )
          , pkg_Common.Ablative_CaseCode
          , initcap( stringException )
          , null
        ) as ablative_case_name
      , decode(
          upper( trim( caseCode ) )
          , pkg_Common.Preposition_CaseCode
          , initcap( stringException )
          , null
        ) as preposition_case_name
      , operatorId as operator_id
    from
      dual
    ) src
  on
    (
    upper( trim( dst.native_case_name ) ) = upper( trim( src.native_case_name ) )
    and dst.sex_code = src.sex_code
    and dst.type_exception_code = src.type_exception_code
    )
  when matched then
    update set
      dst.genetive_case_name =
        coalesce( src.genetive_case_name, dst.genetive_case_name )
      , dst.dative_case_name =
          coalesce( src.dative_case_name, dst.dative_case_name )
      , dst.accusative_case_name =
          coalesce( src.accusative_case_name, dst.accusative_case_name )
      , dst.ablative_case_name =
          coalesce( src.ablative_case_name, dst.ablative_case_name )
      , dst.preposition_case_name =
          coalesce( src.preposition_case_name, dst.preposition_case_name )
      , dst.deleted = 0
  when not matched then
    insert(
      dst.native_case_name
      , dst.genetive_case_name
      , dst.dative_case_name
      , dst.accusative_case_name
      , dst.ablative_case_name
      , dst.preposition_case_name
      , dst.sex_code
      , dst.type_exception_code
      , dst.operator_id
    )
    values(
      src.native_case_name
      , src.genetive_case_name
      , src.dative_case_name
      , src.accusative_case_name
      , src.ablative_case_name
      , src.preposition_case_name
      , src.sex_code
      , src.type_exception_code
      , src.operator_id
    )
  ;

  commit;

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Во время добавления/обновления записи в справочнике исключений'
        || ' произошла ошибка ('
        || sqlerrm
        || ').'
      , true
    );
end mergeExceptionCase;

/* ifunc: getNormalizedString
  Функция нормализации строки - удаления всех пробелов до и
  после символа "-" и символов "(", ")" и текста внутри скобок.

  Входные параметры
    inputString                 - Исходная строка

  Возврат:
    outputStr                   - Нормализованная строка
*/
function getNormalizedString(
  inputString varchar2
)
return varchar2
is
-- getNormalizedString
begin
  -- Удаляем все пробелы до и после символа "-"
  return regexp_replace(
    -- Удаляем символы "(", ")" и текст внутри скобок
    regexp_replace(
      inputString
      , '\(([^()]*)\)'
    )
    , '\s*[-–—]\s*'
    , '-'
  );
end getNormalizedString;

/* ifunc: getSexCode
  Функция определения пола, если он не задан явно.

  Входные параметры:
    stringNativeCase               - Строка в именительном падеже
    formatString                   - Формат преобразования
*/
function getSexCode(
  stringNativeCase varchar2
  , formatString varchar2
)
return varchar2
is
  sexCode varchar2(1);

-- getSexCode
begin
  sexCode :=
    -- Ищем позицию отчества в исходной строке и выделяем его
    -- окончание
    case when
      -- Чтобы не было ошибки в случае, когда в строке нет отчетства
      instr( formatString, pkg_Common.MiddleName_TypeExceptionCode, 1 ) > 0
      and (
        upper(
          substr(
            regexp_substr(
              stringNativeCase
              , '[^ ]+'
              , 1
              , instr( formatString, pkg_Common.MiddleName_TypeExceptionCode, 1 )
            )
            , -1
          )
        ) = 'Ч'
        or upper( stringNativeCase ) like '%ОГЛЫ%'
      )
    then
      Men_SexCode
    else
      Women_SexCode
    end
  ;

  return coalesce( sexCode, Women_SexCode );

end getSexCode;

/* proc: updateExceptionCase
  Процедура добавления/обновления записи в справочнике исключений.

  Входные параметры:
    exceptionCaseId             - ИД записи исключения
    stringException             - Строка исключения
    stringNativeCase            - Строка исключения в именительном падеже
    strConvertInCase            - Строка, полученная склонением функцией
                                  convertNameInCase
    formatString                - формат строки для преобразования (
                                  "L"- строка содержит фамилию
                                  , "F"- строка содержит имя
                                  , "M" - строка содержит отчество)
                                  , если параметр null, то считаем,
                                  что формат строки "LFM"
    sexCode                     - Пол (M – мужской, W - женский)
    caseCode                    - код падежа (NAT – именительный
                                  , GEN - родительный
                                  , DAT - дательный, ACC – винительный
                                  , ABL - творительный, PREP - предложный)
    operatorId                  - ИД оператора

  Выходные параметры отсутствуют.
*/
procedure updateExceptionCase(
  exceptionCaseId integer default null
  , stringException varchar2
  , stringNativeCase varchar2
  , stringConvertInCase varchar2
  , formatString varchar2
  , sexCode varchar2 default null
  , caseCode varchar2
  , operatorId integer
)
is
  -- Код типа исключения
  typeExceptionCode cmn_case_exception.type_exception_code%type;
  -- Пол
  sexCodeNormalized cmn_case_exception.sex_code%type;
  -- Запись исключения
  caseExceptionRec cmn_case_exception%rowtype;
  -- Нормализованный формат строки
  normalizedFormatStr varchar2(20) := upper( trim( formatString ) );
  -- Тип падежа
  normalizedCaseCode varchar2(20) := upper( trim( caseCode ) );

  -- Нормализованные значения строк ФИО
  -- Строка с исключением
  normalizedstringException varchar2(150);
  -- Строка в именительном падеже
  normalizedstringNativeCase varchar2(150);
  -- Строка результат преобразования функции
  normalizedStrConvertInCase varchar2(150);

  -- Разбиваем строки по частям в соответствии с форматом
  -- Строка исключение
  stringExceptionPart varchar2(50);
  -- Строка в именительном падеже
  stringNativeCasePart varchar2(50);
  -- Строка результат работы функции преобразования
  strConvertInCasePart varchar2(50);

-- updateExceptionCase
begin
  -- Получаем нормализованные строки
  normalizedstringException := getNormalizedString( stringException );
  normalizedstringNativeCase := getNormalizedString( stringNativeCase );
  normalizedStrConvertInCase := getNormalizedString( stringConvertInCase );

  -- Пол
  sexCodeNormalized := coalesce(
    sexCode
    , getSexCode(
        stringNativeCase => normalizedStringNativeCase
        , formatString => normalizedFormatStr
      )
  );

  -- Если указан ИД записи - редактируем ее
  if exceptionCaseId is not null then
    -- Считываем параметры записи
    select
      *
    into
      caseExceptionRec
    from
      cmn_case_exception ce
    where
      ce.exception_case_id = exceptionCaseId
    ;

    if caseExceptionRec.Deleted = 1 then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , 'Невозможно редактировать удаленную запись.'
        , true
      );
    end if;

    -- Выделяем исключение из строки
    -- Тип исключения берем из записи по ид-ку и определяем
    -- какую часть исходной строки с исключением необходимо сохранить
    stringExceptionPart := regexp_substr(
      normalizedstringException
      , '[^ ]+'
      , 1
      , instr( normalizedFormatStr, caseExceptionRec.Type_Exception_Code, 1 )
    );
    -- Выделяем именительный падеж исключения
    stringNativeCasePart := regexp_substr(
      normalizedStringNativeCase
      , '[^ ]+'
      , 1
      , instr( normalizedFormatStr, caseExceptionRec.Type_Exception_Code, 1 )
    );
    -- Обновляем запись в таблице исключений
    update
      cmn_case_exception ce
    set
      ce.genetive_case_name =
        case when
          normalizedCaseCode = pkg_Common.Genetive_CaseCode
        then
          stringExceptionPart
        else
          ce.genetive_case_name
        end
      , ce.dative_case_name =
          case when
            normalizedCaseCode = pkg_Common.Dative_CaseCode
          then
            stringExceptionPart
          else
            ce.dative_case_name
          end
      , ce.accusative_case_name =
          case when
            normalizedCaseCode = pkg_Common.Accusative_CaseCode
          then
            stringExceptionPart
          else
            ce.accusative_case_name
          end
      , ce.ablative_case_name =
          case when
            normalizedCaseCode = pkg_Common.Ablative_CaseCode
          then
            stringExceptionPart
          else
            ce.ablative_case_name
          end
      , ce.preposition_case_name =
          case when
            normalizedCaseCode = pkg_Common.Preposition_CaseCode
          then
            stringExceptionPart
          else
            ce.preposition_case_name
          end
      , ce.sex_code = sexCodeNormalized
    where
      ce.exception_case_id = exceptionCaseId
    ;

  -- Если задан именительный падеж - добавляем/обновляем исключение
  elsif stringNativeCase is not null then
    for i in 1..length( normalizedFormatStr ) loop
      -- Определяем код типа исключения
      typeExceptionCode := substr( normalizedFormatStr, i, 1 );

      -- Выделяем часть из строки с именительным падежом по
      -- позиции, соответствующей коду исключения
      stringNativeCasePart := regexp_substr(
        normalizedStringNativeCase
        , '[^ ]+'
        , 1
        , i
      );
      -- Выделяем часть из строки с исключением по
      -- позиции, соответствующей коду исключения
      stringExceptionPart := regexp_substr(
        normalizedstringException
        , '[^ ]+'
        , 1
        , i
      );
      -- Выделяем часть из строки с результатом функции преобразования по
      -- позиции, соответствующей коду исключения
      strConvertInCasePart := regexp_substr(
        normalizedStrConvertInCase
        , '[^ ]+'
        , 1
        , i
      );

      -- Если исключение не совпадает с
      -- результатом функции преобразования - сохраняем его в таблице
      if stringExceptionPart != strConvertInCasePart then
        mergeExceptionCase(
          stringException => stringExceptionPart
          , stringNativeCase => stringNativeCasePart
          , sexCode => sexCodeNormalized
          , typeExceptionCode => typeExceptionCode
          , caseCode => caseCode
          , operatorId => operatorId
        );
      end if;

    end loop;
  -- Если не задан ни 1 параметр - генерируем ошибку
  else
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Невозможно добавить запись в таблицу исключений.'
      , true
    );
  end if;

exception
  when no_data_found then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Указан ИД несуществующей записи ('
        || 'exceptionCaseId="' || to_char( exceptionCaseId ) || '"'
        || ').'
      , true
    );
  when dup_val_on_index then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Запись с такими параметрами уже существует в справочнике'
        || ' исключений ('
        || 'exceptionCaseId="' || to_char( exceptionCaseId ) || '"'
        || ', sexCode="' || sexCode || '"'
        || ').'
      , true
    );
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Во время добавления/обновления записи в справочнике исключений '
        || ' произошла ошибка ('
        || 'exceptionCaseId="' || to_char( exceptionCaseId ) || '"'
        || ', stringException="' || stringException || '"'
        || ', stringNativeCase="' || stringNativeCase || '"'
        || ', stringConvertInCase="' || stringConvertInCase || '"'
        || ', formatString="' || formatString || '"'
        || ', sexCode="' || sexCode || '"'
        || ', caseCode="' || caseCode || '"'
        || ', operatorId="' || to_char( operatorId ) || '"'
        || ').'
      , true
    );
end updateExceptionCase;

/* ifunc: convertInCase
  Функция преобразования ФИО к указанному падежу.

  Входные параметры:
    nameText                    - Строка для преобразования
    typeExceptionCode           - Формат строки для преобразования
    caseCode                    - Код падежа преобразования (
                                  NAT – именительный, GEN -  родительный
                                  , DAT-дательный, ACC – винительный
                                  , ABL- творительный, PREP- предложный)
    sexCode                     - Пол W-women (женский), M-men (мужской)

  Возврат:
    строка в указанном падеже.
*/

function convertInCase(
  nameText varchar2
  , typeExceptionCode varchar2
  , caseCode varchar2
  , sexCode varchar2 default Women_SexCode
)
return varchar2
is
  tailChr varchar2(1);
  nameInCase varchar2(50) := nameText;

  --
  function termCompare(
    nameText varchar2
    , tail varchar2
  )
  return boolean
  is
  -- termCompare
  begin
    if nvl( length( nameText ) , 0 ) < nvl( length( tail ), 0 ) then
      return false;
    end if;

    if lower( substr( nameText, -length( tail ) ) ) = lower( tail ) then
      return true;
    else
      return false;
    end if;

  end termCompare;

  /*
    Процедура дополнения необходимым окончанием в зависимости от падежа.
  */
  procedure makeName(
    nameText in out varchar2
    , posNumber number
    , genTail varchar2
    , datTail varchar2
    , accTail varchar2
    , ablTail varchar2
    , preTail varchar2
  )
  is
  begin
    select
      substr( nameText, 1, length( nameText ) - posNumber )
      || decode(
        caseCode
        , pkg_Common.Genetive_CaseCode
        , genTail
        , pkg_Common.Dative_CaseCode
        , datTail
        , pkg_Common.Ablative_CaseCode
        , ablTail
        , pkg_Common.Accusative_CaseCode
        , accTail
        , pkg_Common.Preposition_CaseCode
        , preTail
      )
    into
      nameText
    from
      dual
    ;
  end makeName;

-- convertInCase
begin
  -- Фамилия
  if typeExceptionCode = pkg_Common.LastName_TypeExceptionCode then
    -- Предусмотрим обработку сдвоенной фамилии:
    if instr( nameText, '-' ) > 0 then
      nameInCase :=
        -- Для фамилий, содержащих приставки –сюрюн, -сал,
        -- -оол, -оглы, -кызы, -кыс, -заде
        -- первую часть фамилии не склоняем
        case when
          upper(
            substr( nameText, instr( nameText, '-' ) + 1 )
          ) not in (
            'СЮРЮН'
            , 'САЛ'
            , 'ООЛ'
            , 'ОГЛЫ'
            , 'КЫЗЫ'
            , 'КЫС'
            , 'ЗАДЕ'
          )
        then
          convertNameInCase(
            nameText => substr( nameText, 1, instr( nameText, '-' ) - 1 )
            , formatString => pkg_Common.LastName_TypeExceptionCode
            , caseCode => caseCode
            , sexCode => sexCode
          )
        else
          substr( nameText, 1, instr( nameText, '-' ) - 1 )
        end
        || '-'
        || convertNameInCase(
             nameText => substr( nameText, instr( nameText, '-' ) + 1 )
             , formatString => pkg_Common.LastName_TypeExceptionCode
             , caseCode => caseCode
             , sexCode => sexCode
           )
      ;
    else

      tailChr := lower( substr( nameText, -1 ) );
      -- Мужчины
      if sexCode = Men_SexCode then
        if tailChr not in ( 'о', 'е', 'у', 'ю', 'и', 'э', 'ы' ) then
          if tailChr = 'в' then
            makeName( nameInCase, 0, 'а', 'у', 'а', 'ым', 'е' );
          elsif tailChr = 'н'
            and termCompare( nameInCase, 'ин' )
          then
            makeName( nameInCase, 0, 'а', 'у', 'а', 'ым', 'е' );
          elsif tailChr = 'ц'
            and termCompare( nameText, 'ец' )
          then
            if length( nameText ) > 3
              and lower( substr( nameText, -3 ) ) in (
                'аец', 'еец', 'иец', 'оец', 'уец'
              )
            then
              makeName( nameInCase, 2, 'йца', 'йцу', 'йца', 'йцем', 'йце' );
            elsif length( nameText ) > 3
              and lower( substr( nameText, -3 ) ) in (
                'тец', 'бец', 'вец', 'мец', 'нец', 'рец', 'сец'
              )
              and lower( substr( nameText, -4, 1 ) ) in (
                'а', 'е', 'и', 'о', 'у', 'ы', 'э', 'ю', 'я', 'ё'
              )
            then
              makeName( nameInCase, 2, 'ца', 'цу', 'ца', 'цом', 'це' );
            elsif length( nameText ) > 3
              and lower( substr( nameText, -3 ) ) = 'лец'
            then
              makeName( nameInCase, 2, 'ьца', 'ьцу', 'ьца', 'ьцом', 'ьце' );
            else
              makeName( nameInCase, 0, 'а', 'у', 'а', 'ом', 'е' );
            end if;
          elsif tailChr = 'х'
            and (
              termCompare( nameText, 'их' )
              or termCompare( nameText, 'ых' )
            )
          then
            makeName( nameInCase, 0, null, null, null, null, null );
          elsif tailChr in (
            'б', 'г', 'д', 'ж', 'з', 'л', 'м', 'н', 'п', 'р', 'с'
            , 'т', 'ф', 'х', 'ц', 'ч', 'ш', 'щ'
          )
          then
            makeName( nameInCase, 0, 'а', 'у', 'а', 'ом', 'е' );
          elsif tailChr = 'я'
            and not(
              termCompare( nameText, 'ия' )
              or termCompare( nameText, 'ая' )
            )
          then
            makeName( nameInCase, 1, 'и', 'е', 'ю', 'ей', 'е' );
          elsif tailChr = 'а'
            and not(
              termCompare( nameText, 'иа' )
              or termCompare( nameText, 'уа' )
            )
          then
            makeName( nameInCase, 1, 'и', 'е', 'у', 'ой', 'е' );
          elsif tailChr = 'ь' then
            makeName( nameInCase, 1, 'я', 'ю', 'я', 'ем', 'е' );
          elsif tailChr = 'к' then
            if length( nameText ) > 4
              and termCompare( nameText, 'ок' )
            then
              makeName( nameInCase, 2, 'ка', 'ку', 'ка', 'ком', 'ке' );
            elsif length( nameText ) > 4
              and (
                termCompare( nameText, 'лек' )
                or termCompare( nameText, 'рек' )
              )
            then
              makeName( nameInCase, 2, 'ька', 'ьку', 'ька', 'ьком', 'ьке' );
            else
              makeName( nameInCase, 0, 'а', 'у', 'а', 'ом', 'е' );
            end if;
          elsif tailChr = 'й' then
            if length( nameText ) > 4 then
              if termCompare( nameText, 'ский' )
                or termCompare( nameText, 'цкий' )
              then
                makeName( nameInCase, 2, 'ого', 'ому', 'ого', 'им', 'ом' );
              elsif termCompare( nameText, 'ой' ) then
                makeName( nameInCase, 2, 'ого', 'ому', 'ого', 'им', 'ом' );
              elsif termCompare( nameText, 'ый' ) then
                makeName( nameInCase, 2, 'ого', 'ому', 'ого', 'ым', 'ом' );
              elsif lower( substr( nameText, -3 ) ) in (
                'рий', 'жий', 'лий', 'вий', 'дий'
                , 'бий', 'гий', 'зий', 'мий', 'ний', 'пий', 'сий', 'фий', 'хий'
              )
              then
                makeName( nameInCase, 1, 'я', 'ю', 'я', 'ем', 'и' );
              elsif termCompare( nameText, 'ий' ) then
                makeName( nameInCase, 2, 'его', 'ему', 'его', 'им', 'им' );
              else
                makeName( nameInCase, 1, 'я', 'ю', 'я', 'ем', 'е' );
              end if;
            else
              makeName( nameInCase, 1, 'я', 'ю', 'я', 'ем', 'е' );
            end if;
          end if;
        end if;
      -- Женщины
      elsif sexCode = Women_SexCode then
        if lower( substr( nameText, -3 ) ) in (
          'ова', 'ева', 'ына', 'ина', 'ена'
        )
        then
          makeName( nameInCase, 1, 'ой', 'ой', 'у', 'ой', 'ой' );
        elsif termCompare( nameText, 'ая' )
          and lower( substr( nameText, -3, 1 ) ) = 'ц'
        then
          makeName( nameInCase, 2, 'ей', 'ей', 'ую', 'ей', 'ей' );
        elsif termCompare( nameText, 'ая' ) then
          makeName( nameInCase, 2, 'ой', 'ой', 'ую', 'ой', 'ой' );
        elsif termCompare( nameText, 'ля' )
          or termCompare( nameText, 'ня' )
        then
          makeName( nameInCase, 1, 'и', 'е', 'ю', 'ей', 'е' );
        elsif termCompare( nameText, 'а' )
          and lower( substr( nameText, -2, 1 ) ) = 'д'
        then
          makeName( nameInCase, 1, 'ы', 'е', 'у', 'ой', 'е' );
        end if;
      end if;
    end if;

  -- Имя
  elsif typeExceptionCode = pkg_Common.FirstName_TypeExceptionCode then
    tailChr := lower( substr( nameText, -1 ) );
    -- Мужчины
    if sexCode = Men_SexCode then
      if tailChr not in ( 'е', 'и', 'у' ) then
        if upper( nameText ) = 'ЛЕВ' then
          makeName( nameInCase, 2, 'ьва', 'ьву', 'ьва', 'ьвом', 'ьве' );
        elsif tailChr in (
          'б', 'в', 'г', 'д', 'з', 'ж', 'к', 'м', 'н', 'п', 'р'
          , 'с', 'т', 'ф', 'х', 'ц', 'ч', 'ш', 'щ'
        )
        then
          makeName( nameInCase, 0, 'а', 'у', 'а', 'ом', 'е' );
        elsif tailChr = 'а' then
          makeName( nameInCase, 1, 'ы', 'е', 'у', 'ой', 'е' );
        elsif tailChr = 'о' then
          makeName( nameInCase, 1, 'а', 'у', 'а', 'ом', 'е' );
        elsif tailChr = 'я' then
          if termCompare( nameText, 'ья' ) then
            makeName( nameInCase, 1, 'и', 'е', 'ю', 'ей', 'е' );
          elsif termCompare( nameText, 'ия' ) then
            makeName( nameInCase, 1, 'и', 'е', 'ю', 'ей', 'е' );
          else
            makeName( nameInCase, 1, 'и', 'е', 'ю', 'ей', 'е' );
          end if;
        elsif tailChr = 'й' then
          if termCompare( nameText, 'ай' ) then
            makeName( nameInCase, 1, 'я', 'ю', 'я', 'ем', 'е' );
          else
            if termCompare( nameText, 'ей' ) then
              makeName( nameInCase, 1, 'я', 'ю', 'я', 'ем', 'е' );
            else
              makeName( nameInCase, 1, 'я', 'ю', 'я', 'ем', 'и' );
            end if;
          end if;
        elsif tailChr = 'ь' then
          makeName( nameInCase, 1, 'я', 'ю', 'я', 'ем', 'е' );
        elsif tailChr = 'л' then
          if termCompare( nameText, 'авел' ) then
            makeName( nameInCase, 2, 'ла', 'лу', 'ла', 'лом', 'ле' );
          else
            makeName( nameInCase, 0, 'а', 'у', 'а', 'ом', 'е' );
          end if;
        end if;
      end if;
    -- женщины
    elsif sexCode = Women_SexCode then
      if tailChr = 'а'
        and length( nameText ) > 1
      then
        if lower( substr( nameText, -2 ) ) in (
          'га', 'ха', 'ка', 'ша', 'ча', 'ща', 'жа'
        )
        then
          makeName( nameInCase, 1, 'и', 'е', 'у', 'ой', 'е' );
        else
          makeName( nameInCase, 1, 'ы', 'е', 'у', 'ой', 'е' );
        end if;
      elsif tailChr = 'я'
        and length( nameText ) > 1
      then
        if termCompare( nameText, 'ия' )
          and lower( substr( nameText, -4 ) ) = 'ьфия'
        then
          makeName( nameInCase, 1, 'и', 'е', 'ю', 'ей', 'е' );
        elsif termCompare( nameText, 'ия' ) then
          makeName( nameInCase, 1, 'и', 'и', 'ю', 'ей', 'и' );
        else
          makeName( nameInCase, 1, 'и', 'е', 'ю', 'ей', 'е' );
        end if;
      elsif tailChr = 'ь' then
        if termCompare( nameText, 'вь' ) then
          makeName( nameInCase, 1, 'и', 'и', 'ь', 'ью', 'и' );
        else
          makeName( nameInCase, 1, 'и', 'и', 'ь', 'ью', 'ье' );
        end if;
      end if;
    end if;

  -- Отчество
  elsif typeExceptionCode = pkg_Common.MiddleName_TypeExceptionCode then
    tailChr := lower( substr( nameText, -1 ) );
    -- Мужчины
    if sexCode = Men_SexCode then
      if tailChr = 'ч' then
        makeName( nameInCase, 0, 'а', 'у', 'а', 'ем', 'е' );
      end if;
    -- Женщины
    elsif sexCode = Women_SexCode then
      if tailChr = 'а'
        and length( nameText ) != 1
      then
        makeName( nameInCase, 1, 'ы', 'е', 'у', 'ой', 'е' );
      end if;
    end if;
  end if;

  return nameInCase;

end convertInCase;

/* func: convertNameInCase
  Функция преобразования ФИО к указанному падежу. Порядок слов
  в формате и в переданной строке должен совпадать. Двойные фамилии
  должны отделяться друг от друга знаком "-", при этом количество пробелов до
  и после знака не важно.

  Входные параметры:
    nameText                    - Строка для преобразования
    formatString                - Формат строки для преобразования
    caseCode                    - Код падежа преобразования
    sexCode                     - Пол

  Возврат:
    строка в указанном падеже.
*/
function convertNameInCase(
  nameText varchar2
  , formatString varchar2
  , caseCode varchar2
  , sexCode varchar2 default null
)
return varchar2
is
  -- Результат преобразования
  strConvertInCase varchar2(150);
  -- Код типа исключения
  typeExceptionCode cmn_case_exception.type_exception_code%type;
  -- Пол
  normalizedsexCode cmn_case_exception.sex_code%type;
  -- Нормализованный формат строки
  normalizedFormatStr varchar2(20) := upper( trim( formatString ) );
  -- Тип падежа
  normalizedCaseCode varchar2(20) := upper( trim( caseCode ) );

  -- Нормализованная строка в именительном падеже
  normalizedStringNativeCase varchar2(150);

  -- Строка результат работы функции преобразования
  strConvertInCasePart varchar2(50);

  -- Запись с исключением
  exceptionRec v_cmn_case_exception%rowtype;

  -- Строка в именительном падеже
  stringNativeCasePart varchar2(50);

  -- Исключение при некорректном формате
  UncorrectFormat exception;
  -- Флаг наличия кода типа исключения в справочнике
  isExceptionTypeCodeExists integer;

  -- Оглы, Кызы
  isOglyExists integer;
  isKyzyExists integer;

-- convertNameInCase
begin
  -- Получаем нормализованные строки
  normalizedStringNativeCase := getNormalizedString( nameText );

  select
    count(*)
  into
    isExceptionTypeCodeExists
  from
    cmn_type_exception te
  where
    instr( normalizedFormatStr, te.type_exception_code, 1 ) > 0
  ;

  if normalizedStringNativeCase is null
    or isExceptionTypeCodeExists = 0
    or normalizedCaseCode not in (
      pkg_Common.Genetive_CaseCode
      , pkg_Common.Dative_CaseCode
      , pkg_Common.Accusative_CaseCode
      , pkg_Common.Ablative_CaseCode
      , pkg_Common.Preposition_CaseCode
    )
  then
    raise UncorrectFormat;
  end if;

  -- Пол
  normalizedSexCode := coalesce(
    sexCode
    , getSexCode(
        stringNativeCase => normalizedStringNativeCase
        , formatString => normalizedFormatStr
      )
  );

  -- Проверяем наличие "оглы" и "кызы"
  -- оглы
  select
    count(*)
  into
    isOglyExists
  from
    (
    select
      regexp_substr(
        normalizedStringNativeCase
        , '[^ ]+'
        , 1
        , level
      ) as name
    from
      dual
    connect by
      level <= length( normalizedStringNativeCase ) -
        length( replace( normalizedStringNativeCase, ' ' ) ) + 1
    ) t
  where
    upper( t.name ) = upper( 'оглы' )
    -- Учитываем только приставку, если это само
    -- отчество - в конце не добавляем "оглы"
    and length( t.name ) > 4
  ;
  -- кызы
  select
    count(*)
  into
    isKyzyExists
  from
    (
    select
      regexp_substr(
        normalizedStringNativeCase
        , '[^ ]+'
        , 1
        , level
      ) as name
    from
      dual
    connect by
      level <= length( normalizedStringNativeCase ) -
        length( replace( normalizedStringNativeCase, ' ' ) ) + 1
    ) t
  where
    upper( t.name ) = upper( 'кызы' )
    -- Учитываем только приставку, если это само
    -- отчество - в конце не добавляем "кызы"
    and length( t.name ) > 4
  ;

  -- В цикле по формату преобразования
  for i in 1..length( normalizedFormatStr ) loop
    -- Определяем код типа исключения
    typeExceptionCode := substr( normalizedFormatStr, i, 1 );
    -- Выделяем именительный падеж из строки
    stringNativeCasePart := regexp_substr(
      normalizedStringNativeCase
      , '[^ ]+'
      , 1
      , i
    );

    -- Ищем в справочнике исключений
    exceptionRec := getExceptionCase(
      stringNativeCase => stringNativeCasePart
      , sexCode => normalizedSexCode
      , typeExceptionCode => typeExceptionCode
    );


    strConvertInCase := ltrim(
      strConvertInCase
      || ' '
      || coalesce(
           case
             normalizedCaseCode
           when
             Pkg_Common.Genetive_CaseCode
           then
             exceptionRec.genetive_case_name
           when
             Pkg_Common.Dative_CaseCode
           then
             exceptionRec.dative_case_name
           when
             Pkg_Common.Accusative_CaseCode
           then
             exceptionRec.accusative_case_name
           when
             Pkg_Common.Ablative_CaseCode
           then
             exceptionRec.ablative_case_name
           when
             Pkg_Common.Preposition_CaseCode
           then
             exceptionRec.preposition_case_name
           end
           , convertInCase(
               nameText => stringNativeCasePart
               , typeExceptionCode => typeExceptionCode
               , caseCode => normalizedCaseCode
               , sexCode => normalizedsexCode
             )
         )
      -- Оглы, Кызы
      || case when
           typeExceptionCode = pkg_Common.MiddleName_TypeExceptionCode
           and isOglyExists = 1
         then
           ' Оглы'
         when
           typeExceptionCode = pkg_Common.MiddleName_TypeExceptionCode
           and isKyzyExists = 1
         then
           ' Кызы'
         end
    );

  end loop;

  return initCap( trim( strConvertInCase ) );

exception
  when UncorrectFormat then
    return normalizedStringNativeCase;
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Во время преобразования ФИО к указанному падежу произошла ошибка ('
        || 'nameText="' || nameText || '"'
        || ', formatString="' || formatString || '"'
        || ', caseCode="' || caseCode || '"'
        || ', sexCode="' || sexCode || '"'
        || '):'
        || sqlerrm
        || '.'
      , true
    );
end convertNameInCase;

end pkg_Common;
/
