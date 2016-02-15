create or replace package body pkg_Common is
/* package body: pkg_Common::body */



/* group: ��������� */

/* iconst: Default_SmtpServer
  SMTP-������ ��� �������� ����� �� ���������.
*/
Default_SmtpServer constant varchar2(30) := '';

/* iconst: Default_NotifyEmail
  �������� ����� �� ��������� ��� �������� ����� � ������������ �� ������������
  ��.
*/
Default_NotifyEmail constant varchar2(100) := '';

/* iconst: Default_NotifyEmail_Test
  �������� ����� �� ��������� ��� �������� ����� � ������������ �� �������� ��.
*/
Default_NotifyEmail_Test constant varchar2(100) := '';

/* iconst: MailSender_Domain
  ����� �����������, ����������� ��� ���������� � SMTP-��������.
*/
MailSender_Domain constant varchar2(30) := '';

/* iconst: UpdateLongops_Timeout
  ������������� ���������� ���������� � ���������� ���������� ��������.
*/
UpdateLongops_Timeout constant interval day to second := INTERVAL '5' SECOND;



/* group: ���������� */

/* ivar: currentSessionSid
  SID ������� ������.
*/
currentSessionSid number;

/* ivar: currentSessionSerial
  serial# ������� ������.
*/
currentSessionSerial number;

/* ivar: databaseConfig
  ������������ � ������� ������ ��������� ��.
*/
databaseConfig cmn_database_config%rowtype;

/* ivar: rindexSessionLongops
  ���������� ��� ������ dbms_application.set_session_longops.
*/
rindexSessionLongops binary_integer;

/* ivar: slnoSessionLongops
  ���������� ��� ������ dbms_application.set_session_longops.
*/
slnoSessionLongops binary_integer;

/* ivar: nextUpdateLongopsTick
  ��������� ���������� ��� ������� ���������� ���������� v$session_longops.
*/
nextUpdateLongopsTick number := null;



/* group: ������� */



/* group: ��������� ������ */

/* func: getInstanceName
  ���������� ��� ������� ���� ( �������� ��������� INSTANCE_NAME).
*/
function getInstanceName
return varchar2
is
begin
  return sys_context( 'USERENV','INSTANCE_NAME');
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '������ ��� ��������� instance_name.'
    , true
  );
end getInstanceName;

/* func: getSessionSid
  ���������� SID ������� ������.
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
    , '������ ��� ��������� sid ������� ������.'
    , true
  );
end getSessionSid;

/* func: getSessionSerial
  ���������� serial# ������� ������.

  ���������:
  - ��� ���������� ������ ��� ���������� ���� �� v$session ������� ������������
    ����� ������������ SQL ( � ������ ���������� ���� ����� ��������� ������
    ��� ���������� �������);
*/
function getSessionSerial
return number
is
begin
  if currentSessionSerial is null then

    -- ������������ SQL ��� ���������� ����������� �� ���� �� v$session
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
    , '������ ��� ��������� serial# ������� ������.'
    , true
  );
end getSessionSerial;

/* func: getIpAddress
  ���������� IP ����� �������� ������� ��.

  ���������:
  - ��� ��������� ���������� ������� � Oracle 11 � ���� ����� �������������� �����;
*/
function getIpAddress
return varchar2
is

  -- IP ����� �������� �������
  ipAddress varchar2(16);

begin

  -- ������� ���������� IP ����� ������� ��.
  ipAddress := utl_inaddr.get_host_address();
  return ipAddress;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '������ ��� ����������� ip-������ �������� ������� ��.'
    , true
  );
end getIpAddress;



/* group: ��������� �� */

/* iproc: getDatabaseConfig
  ���������� ��������� ��, ���� ��� �� ���� ���������� �����.
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

    -- ������� �� ��������, ���� ip-����� ������� �� ��������� � ��������
    if databaseConfig.ip_address_production is not null
        -- ������� ���������� ����� ���������, ����� ���������� ����������
        -- ������� getIpAddress � �������� �� ( ��� ������������)
        and nullif( databaseConfig.ip_address_production, getIpAddress())
          is not null
        and databaseConfig.is_production = 1
        then
      databaseConfig.is_production := 0;
    end if;

    -- ���������� ����� �������� ����� ������ �� ���� ��
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
    , '������ ��� ����������� �������� ��.'
    , true
  );
end getDatabaseConfig;

/* func: isProduction
  ���������� 1, ���� ������� ����������� � ������������ ����, � ������ �������
  ���������� 0.
*/
function isProduction
return integer
is
begin
  getDatabaseConfig();
  return databaseConfig.is_production;
end isProduction;

/* group: ����������� �� e-mail */

/* func: getSmtpServer
  ���������� ��� ( ��� IP-�����) ���������� SMTP-�������.
*/
function getSmtpServer
return varchar2
is
begin
  getDatabaseConfig();
  return databaseConfig.smtp_server;
end getSmtpServer;

/* func: getMailAddressSource
  ��������� ��������� �������� ����� ��� �������� ���������.

  ���������:
  systemName                  - �������� ������� ��� ������, ������������
                                ��������� ( ��������, "Scheduler",
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
  ���������� ������� �������� ����� ��� �������� ���������.
*/
function getMailAddressDestination
return varchar2
is
begin
  getDatabaseConfig();
  return databaseConfig.notify_email;
end getMailAddressDestination;

/* proc: sendMail
  ���������� ������ �� e-mail.

  ���������:
  mailSender                  - ����� �����������
  mailRecipient               - ����� ����������
  subject                     - ���� ������
  message                     - ����� ������
  smtpServer                  - SMTP-������ ��� �������� ������ ( �� ���������
                                ������������ ������, ������������ ��������
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

  -- ����������� ��������� ����� ��������� ��� ����������� � ����� ������ �
  -- ������� Quoted-Printable
  MaxQpLineLength constant pls_integer := 76 / 3;

  -- ��� ��������� ������ � ��
  DefaultCharset constant varchar2(30) := 'Windows-1251';

  -- ��� ��������� ������ � ��
  BodyHeader constant varchar2(1024) :=
    'MIME-Version: 1.0' || utl_tcp.CRLF
    || 'Content-Type: text/plain; charset=' || DefaultCharset || utl_tcp.CRLF
    || 'Content-Transfer-Encoding: 8bit' || utl_tcp.CRLF
  ;

  -- ���������� "����������"
  lConnection UTL_SMTP.CONNECTION;



  /*
    ��������� ���������� � ��������.
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

    -- ������������� �� ������ ������
    utl_smtp.helo( lConnection, MailSender_Domain);

    -- ��������� ����� �����������
    utl_smtp.mail( lConnection, mailSender);

    -- ��������� ����� ����������
    utl_smtp.rcpt( lConnection, mailRecipient);

    -- ��������� ����� �����
    utl_smtp.open_data( lConnection);
  end openConnection;



  /*
    ����� ���� ���������.
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
    ����� ���� ���������, ������� �������� � ������� Quoted-Printable.
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

      -- ������������ ��������� �������� ������ �� ��������� �����
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

    -- ��������� ����, ���� �� ���� ��������
    if len = 0 then
      utl_smtp.write_data( lConnection, ' ' || utl_tcp.CRLF);
    end if;
  end writeEncodedField;



  /*
    ����� ��������� ������.
  */
  procedure writeHeader
  is
  begin

    -- ��������� ����� ����������� ��� �����������
    writeField( 'From', mailSender);

    -- ��������� ����� ���������� ��� �����������
    writeField( 'To', mailRecipient);

    -- ��������� ����
    writeEncodedField( 'Subject', subject);

    -- ����� ��������� ��� ���� ���������
    utl_smtp.write_data( lConnection, BodyHeader);

    -- ��������� ���������
    utl_smtp.write_data( lConnection, utl_tcp.CRLF);
  end writeHeader;



  /*
    ��������� ���� ������.
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
    ��������� ���������� � ��������.
  */
  procedure closeConnection
  is
  begin

    -- ��������� ����� �����
    utl_smtp.close_data( lConnection);

    -- ��������� ���������� � SMTP-��������
    utl_smtp.quit( lConnection);
  end closeConnection;



-- sendMail
begin

  -- ��������� ���������� � SMTP-��������
  openConnection();

  -- ����� ��������� ���������
  writeHeader();

  -- ����� ����� ������
  writeBody();

  -- ��������� ����������
  closeConnection();

exception

  -- ������������� ��������� ��������� ������
  when utl_smtp.transient_error or utl_smtp.permanent_error then
    begin

      -- ��������� ���������� � ��������
      utl_smtp.quit(lConnection);

    -- ���� SMTP-������ ���� ��� �� ��������, �.�. �� �� ����� � ���
    -- ����������, �� ��� ������ quit ��������� ����������, ������� ��
    -- ����������
    exception when utl_smtp.transient_error or utl_smtp.permanent_error then
      null;
    end;

    -- ������� ��������� �� ������, ������� ��������� ��� �������� ������
    raise_application_error(
      pkg_Error.MailSendingError
      , '������ ��� �������� ������: ' || SQLERRM
    );
end sendMail;



/* group: �������� ���������� �������� */

/* proc: startSessionLongops
  ��������� � ������������� v$session_longops ������ ��� ��������� �������������
  ��������.

  ���������:
  operationName               - �������� ����������� ��������
  units                       - ������� ��������� ������ ������
  target                      - ID �������, ��� ������� ����������� ��������
  targetDesc                  - �������� �������, ��� ������� �����������
                                �������
  sofar                       - ����� ����������� �����
  totalWork                   - ����� ����� ������
  contextValue                - �������� ��������, ����������� � ��������
                                ���������
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

  -- ������������� � ��������� ��������
  rindexSessionLongops := dbms_application_info.set_session_longops_nohint;
  slnoSessionLongops := null;
  nextUpdateLongopsTick := null;

  -- ������� ������ ��� ��������
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
  ������������ ��������� �������� ���������� ������� ��������.

  ���������:
  sofar                       - ����� ����������� �����
  totalWork                   - ����� ����� ������
  contextValue                - �������� ��������, ����������� � ��������
                                ���������
*/
procedure setSessionLongops(
  sofar number
  , totalwork number
  , contextvalue binary_integer
)
is

  curTick number := dbms_utility.get_time();

begin

  -- ��������� ������������� ����������
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



/* group: ������� �������������� */

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
    '����������������������������������������������������',
    'AaBbVvGgDdEeZzIiJjKkLlMmNnOoPpRrSsTtUuFfHhCcYy''''''''Ee');

  -- Special cases of transliteration
  tmpSource := replace(tmpSource, '�', 'Jo');
  tmpSource := replace(tmpSource, '�', 'jo');
  tmpSource := replace(tmpSource, '�', 'Zh');
  tmpSource := replace(tmpSource, '�', 'zh');
  tmpSource := replace(tmpSource, '�', 'Ch');
  tmpSource := replace(tmpSource, '�', 'ch');
  tmpSource := replace(tmpSource, '�', 'Sh');
  tmpSource := replace(tmpSource, '�', 'sh');
  tmpSource := replace(tmpSource, '�', 'Sch');
  tmpSource := replace(tmpSource, '�', 'sch');
  tmpSource := replace(tmpSource, '�', 'Ju');
  tmpSource := replace(tmpSource, '�', 'ju');
  tmpSource := replace(tmpSource, '�', 'Ja');
  tmpSource := replace(tmpSource, '�', 'ja');

  return tmpSource;
end transliterate;

/* func: numberToWord
  ��������������� ����� ������ � ����� ��������.
  ����������� �����: ���� ������.
  ������������ �����: �������� ������ ����� ���� ������� (999999999999.99)
  ���� ����� �� ����� ���� ������������� � ������, ������� ���������� ������
  '############################################## ������'

  ��������:
  source                      - ����� ������
*/
function numberToWord(
  source number
)
return varchar2
is

  -- ������������ ������
  str varchar2(300);

begin

  -- ���� ������� �������� null, ���������� null
  if source is null then
     return null;
  end if;

  -- k - �������
  str := ltrim( to_char( source,
    '9,9,,9,,,,,,9,9,,9,,,,,9,9,,9,,,,9,9,,9,,,.99')) || 'k';

  -- t - ������; m - �������; M - ���������;
  str := replace( str, ',,,,,,', 'eM');
  str := replace( str, ',,,,,', 'em');
  str := replace( str, ',,,,', 'et');

  -- e - �������; d - �������; c - �����;
  str := replace( str, ',,,', 'e');
  str := replace( str, ',,', 'd');
  str := replace( str, ',', 'c');
  --
  str := replace( str, '0c0d0et', '');
  str := replace( str, '0c0d0em', '');
  str := replace( str, '0c0d0eM', '');
  --
  str := replace( str, '0c', '');
  str := replace( str, '1c', '��� ');
  str := replace( str, '2c', '������ ');
  str := replace( str, '3c', '������ ');
  str := replace( str, '4c', '��������� ');
  str := replace( str, '5c', '������� ');
  str := replace( str, '6c', '�������� ');
  str := replace( str, '7c', '������� ');
  str := replace( str, '8c', '��������� ');
  str := replace( str, '9c', '��������� ');
  --
  str := replace( str, '1d0e', '������ ');
  str := replace( str, '1d1e', '����������� ');
  str := replace( str, '1d2e', '���������� ');
  str := replace( str, '1d3e', '���������� ');
  str := replace( str, '1d4e', '������������ ');
  str := replace( str, '1d5e', '���������� ');
  str := replace( str, '1d6e', '����������� ');
  str := replace( str, '1d7e', '���������� ');
  str := replace( str, '1d8e', '������������ ');
  str := replace( str, '1d9e', '������������ ');
  --
  str := replace( str, '0d', '');
  str := replace( str, '2d', '�������� ');
  str := replace( str, '3d', '�������� ');
  str := replace( str, '4d', '����� ');
  str := replace( str, '5d', '��������� ');
  str := replace( str, '6d', '���������� ');
  str := replace( str, '7d', '��������� ');
  str := replace( str, '8d', '����������� ');
  str := replace( str, '9d', '��������� ');
  --
  str := replace( str, '0e', '');
  str := replace( str, '5e', '���� ');
  str := replace( str, '6e', '����� ');
  str := replace( str, '7e', '���� ');
  str := replace( str, '8e', '������ ');
  str := replace( str, '9e', '������ ');
  --
  str := replace( str, '1e.', '���� ����� ');
  str := replace( str, '2e.', '��� ����� ');
  str := replace( str, '3e.', '��� ����� ');
  str := replace( str, '4e.', '������ ����� ');
  str := replace( str, '1et', '���� ������ ');
  str := replace( str, '2et', '��� ������ ');
  str := replace( str, '3et', '��� ������ ');
  str := replace( str, '4et', '������ ������ ');
  str := replace( str, '1em', '���� ������� ');
  str := replace( str, '2em', '��� �������� ');
  str := replace( str, '3em', '��� �������� ');
  str := replace( str, '4em', '������ �������� ');
  str := replace( str, '1eM', '���� �������� ');
  str := replace( str, '2eM', '��� ��������� ');
  str := replace( str, '3eM', '��� ��������� ');
  str := replace( str, '4eM', '������ ��������� ');
  --
  str := replace( str, '11k', '11 ������');
  str := replace( str, '12k', '12 ������');
  str := replace( str, '13k', '13 ������');
  str := replace( str, '14k', '14 ������');
  str := replace( str, '1k', '1 �������');
  str := replace( str, '2k', '2 �������');
  str := replace( str, '3k', '3 �������');
  str := replace( str, '4k', '4 �������');
  --
  str := replace( str, '.', '������ ');
  str := replace( str, 't', '����� ');
  str := replace( str, 'm', '��������� ');
  str := replace( str, 'M', '���������� ');
  str := replace( str, 'k', ' ������');

  -- ������ ���� ����� ��� ���������� ��������� ����� 0 ������
  if substr( str, 1, 6) = '������' then
     str := '���� '|| str;
  end if;

  return str;
end numberToWord;

/* func: getStringByDelimiter
  ������� ������ ����� ������ �� ������� � �����������.

  ���������:
  initString                  - ������, � ������� �������������� �����
  delimiter                   - �����������
  position                    - ����� ��������� ( ������� � 1)
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

  -- �������� �� "������"
  if position < 1
        or position is null
        or instr( initString, delimiter) = 0 and position = 1
      then
    return initString;
  end if;

  -- ���� ��� ������ �������������� ����� ���������, ���� ��������� null
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

  -- ���� � ��� ��������� ����� ������
  if strLength < 0 then
    strLength :=
      length( initString)
      - instr( initString, delimiter, 1, position - 1) + 1
    ;
  end if;
  return substr( initString, strPosition + 1, strLength - 1);
end getStringByDelimiter;

/* func: split
  ������� ��������� ������ �� ��������� ����������� � ����������� � �������
  ��� ��������� � ������������� � ��������.

  ���������:
  initString                  - ������� ������ ��� �������
  delimiter                   - ����������� ( �� ��������� ',')

  ������������ ��������:
  nested table �� ���������� ��������������� ������.

  ������ �������������:

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
  ������� ��������� ������ ���� Clob �� ��������� ����������� � ����������� � �������
  ��� ��������� � ������������� � ��������.

  ������� ���������:
    initClob                    - ������� ������ ���� Clob ��� �������
    delimiter                   - �����������

  �������:
    nested table �� ���������� ���������������� ������� ���� Clob.
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
        , '��������� ������ �� ������������ '
          || '( ' || to_char( safeLoopIndex) || ' ��������)'
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



/* group: ������� */

/* proc: outputMessage
  ������� ��������� ��������� ����� dbms_output.
  ������ ���������, ����� ������� ������ 255 ��������, ��� ������ �������������
  ����������� �� ������ ����������� ������� ( � ����� ������������ �� �����
  ������ � ��������� dbms_output.put_line).

  ���������:
  messageText                 - ����� ���������

  ���������:
  - �������� ��� ������ ������� ������� ����� ��������� �� �����������
    ������������ �� ������� ����� ������ ( 0x0A) ���� ����� ��������;
*/
procedure outputMessage(
  messageText varchar2
)
is

  -- ������������ ����� ������
  Max_OutputLength constant pls_integer:= 255;

  -- ����� ������
  len pls_integer := coalesce( length( messageText), 0);

  -- ��������� ������� ��� �������� ������
  i pls_integer := 1;

  -- ��������� ������� ��� ���������� ������
  i2 pls_integer;

  -- �������� ������� ��� �������� ������ ( �� �������)
  k pls_integer := null;

-- outputMessage
begin
  loop
    i2 := len + 1;
    if i2 - i > Max_OutputLength then
      i2 := i + Max_OutputLength;

      -- �������� ������� ������ �� ������� ����� ������
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
