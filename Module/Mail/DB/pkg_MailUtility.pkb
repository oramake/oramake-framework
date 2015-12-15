create or replace package body pkg_MailUtility is
/* package body: pkg_MailUtility::body */

/* itype: TUrlString
  Тип для строки с URL.
*/
subtype TUrlString is varchar2(1000);

/* ivar: logger
  Интерфейсный объект к модулю Logging
*/
  logger lg_logger_t := lg_logger_t.GetLogger(
    moduleName => pkg_Mail.Module_Name
    , objectName => 'pkg_MailUtility'
  );

/* ivar: deleteErrorMessageUid
  Идентификатор сообщения для удаления из ящика
*/
  deleteErrorMessageUid ml_message.message_uid%type := null;

/* func: ChangeUrlPasswordJava
  Возвращает URL с измененным паролем.
*/
function ChangeUrlPasswordJava(
  url varchar2
  , newPassword varchar2
)
return varchar2
is
language java name '
Mail.changeUrlPassword(
  java.lang.String
  , java.lang.String
)
return java.lang.String
';
/* func: ChangeUrlPassword
  Возвращает URL с измененным паролем.

  Параметры:
  url                         - URL почтового ящика в URL-encoded формате
                                ( pop3://user:passwd@server.domen)
  newPassword                 - новый пароль
*/
function ChangeUrlPassword(
  url varchar2
  , newPassword varchar2
)
return varchar2
is

--ChangeUrlPassword
begin
  return
    ChangeUrlPasswordJava(
      url           => url
      , newPassword => newPassword
    )
  ;
end ChangeUrlPassword;
/* func: GetAddressJava
  Возвращает нормализованный почтовый адрес.
*/
function GetAddressJava(
  addressText varchar2
)
return varchar2
is
language java name '
Mail.getAddress(
  java.lang.String
)
return java.lang.String
';
/* func: GetAddress
  Возвращает нормализованный почтовый адрес.
  При наличии нескольких адресов, возвращается первый из них.

  Параметры:
  addressText                 - текст адреса
*/
function GetAddress(
  addressText varchar2
)
return varchar2
is

--GetAddress
begin
  return GetAddressJava( addressText);
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( 'Ошибка при получении нормализованного почтового адреса ('
      || ' address_text="' || addressText || '"'
      || ').' )
    , true
  );
end GetAddress;
/* func: GetMailboxAddressJava
  Возвращает адрес почтового ящика по URL.
*/
function GetMailboxAddressJava(
  url varchar2
)
return varchar2
is
language java name '
Mail.getMailboxAddress(
  java.lang.String
)
return java.lang.String
';
/* func: GetMailboxAddress
  Возвращает адрес почтового ящика по URL ( в случае невозможности - выбрасывает
  исключение).

  Параметры:
  url                         - URL почтового ящика в URL-encoded формате
                                ( pop3://user:passwd@server.domen)
*/
function GetMailboxAddress(
  url varchar2
)
return varchar2
is

  mailboxAddress ml_message.recipient_address%type;
                                        --URL с удаленным паролем
  clearUrl TUrlString;

--GetMailboxAddress
begin
  clearUrl := ChangeUrlPassword( url, null);
  mailboxAddress := GetMailboxAddressJava( url);
  if mailboxAddress is null then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Не удалось определить адрес.'
    );
  end if;
  return mailboxAddress;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( 'Ошибка при определении адреса почтового ящика по URL'
      || case when clearUrl is not null then
          ' "' || clearUrl || '"'
        end
      || '.' )
    , true
  );
end GetMailboxAddress;
/* func: GetEncodedAddressListJava
  Возвращает кодированный список адресов
  ( обертка для <Mail.getEncodedAddressList>).
*/
function GetEncodedAddressListJava(
  textAddressList varchar2
)
return varchar2
is
language java name '
Mail.getEncodedAddressList(
  java.lang.String
)
return java.lang.String
';
/* func: GetEncodedAddressList
  Возвращает кодированный список адресов.

  Параметры:
  textAddressList             - текст адреса ( можно список с разделителем ","
                                или ";")
*/
function GetEncodedAddressList(
  textAddressList varchar2
)
return varchar2
is

--GetEncodedAddressList
begin
  return GetEncodedAddressListJava( textAddressList);
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( 'Ошибка при получении кодированного списка адресов ('
      || ' textAddressList="' || textAddressList || '"'
      || ').' )
    , true
  );
end GetEncodedAddressList;
/* func: GetTextAddressListJava
  Возвращает текстовый список адресов
  ( обертка для <Mail.getTextAddressList>).
*/
function GetTextAddressListJava(
  addressList varchar2
)
return varchar2
is
language java name '
Mail.getTextAddressList(
  java.lang.String
)
return java.lang.String
';
/* func: GetTextAddressList
  Возвращает текстовый список адресов.

  Параметры:
  addressList             - список адресов
*/
function GetTextAddressList(
  addressList varchar2
)
return varchar2
is

--GetTextAddressList
begin
  return GetTextAddressListJava( addressList);
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( 'Ошибка при получении текстового списка адресов ('
      || ' addressList="' || addressList || '"'
      || ').' )
    , true
  );
end GetTextAddressList;

/* proc: SetDeleteErrorMessageUid
  Установка значения идентификатора сообщения,
  которое нужно удалить из ящика в случае ошибки
  получения в данной сессии (см. <pkg_Mail.FetchMessageImmediate>)
  При null, сообщения удаляются только при получении.

  Параметры:
    messageUid               - значение идентификатора
                               сообщения для удаления
*/
procedure SetDeleteErrorMessageUid(
  messageUid varchar2
)
is
begin
  pkg_MailUtility.deleteErrorMessageUid :=
    SetDeleteErrorMessageUid.messageUid;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack(
        'Ошибка установки идентификатора сообщения для удаления'
      )
    , true
  );
end SetDeleteErrorMessageUid;

/* func: GetDeleteErrorMessageUid
  Получение установленного идентификатора сообщения,
  которое нужно удалить из ящика в случае ошибки
  получения в данной сессии (см. <pkg_Mail.FetchMessageImmediate>)

  Возврат:
    - значение идентификатора сообщения для удаления
*/
function GetDeleteErrorMessageUid
return varchar2
is
begin
  return
    deleteErrorMessageUid;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack(
        'Ошибка получения идентификатора сообщения для удаления'
      )
    , true
  );
end GetDeleteErrorMessageUid;


/* func: isEmailValid
   Выполняет проверку корректности адреса электронной почты

   Параметры:
     emailAddress                   - адрес электронной почты

   Возврат:
     - если адрес email корректен, то 1, иначе 0
*/
function isEmailValid (
  emailAddress in varchar2
  )
return integer
is
  -- общий формат адреса
  Email_GeneralFormat constant varchar2(100) := '^(.*)@(.*)$';
  -- максимальная длина адреса
  Email_MaxLength constant pls_integer := 254;
  -- формат локальной части адреса
  Email_LocalPartFormat constant varchar2(100) :=
      '^[[:alnum:]!#\$%&''\*\+\/=\?\^_`\.\{\|\}~-]+$'
  ;
  -- максимальная длина локальной части адреса
  Email_LocalPartLength constant pls_integer := 64;
  -- формат доменной части адреса
  Email_DomainPartFormat constant varchar2(100) :=
      '^[[:alnum:]-\.]+$'
  ;
  -- максимальная длина доменной части адреса
  Email_DomainPartLength constant pls_integer := 253;
  -- формат части адреса, при которой весь адрес признается некорректным
  Email_IllegalPartFormat constant varchar2(100) := '(^\.)|(\.$)|([\.]{2,})';

  -- локальная часть адреса
  localPart varchar2(255);
  -- доменная часть адреса
  domainPart varchar2(255);


  /*
    Разбивает адрес на локальную и доменную части
  */
  procedure splitAddress (
      emailAddress     in varchar2
    , localPart        out varchar2
    , domainPart       out varchar2
    )
  is
  -- splitAddress
  begin
    localPart  := regexp_substr( emailAddress, Email_GeneralFormat, 1, 1, 'i', 1 );
    domainPart := regexp_substr( emailAddress, Email_GeneralFormat, 1, 1, 'i', 2 );

  end splitAddress;


  /*
    Проверяет длину адреса
  */
  function checkLength (
    emailAddress in varchar2
    )
  return boolean
  is
  -- checkLength
  begin
    if length( emailAddress ) between 3 and Email_MaxLength then
      return true;
    else
      return false;
    end if;

  end checkLength;


  /*
     Проверяет локальную часть адреса
  */
  function checkLocalPart (
    localPart in varchar2
    )
  return boolean
  is
  -- checkLocalPart
  begin
    if length( localPart ) between 1 and Email_LocalPartLength then
      return regexp_like( localPart, Email_LocalPartFormat )
         and not regexp_like( localPart, Email_IllegalPartFormat )
      ;
    else
      return false;
    end if;

  end checkLocalPart;


  /*
     Проверяет доменную часть адреса
  */
  function checkDomainPart (
    domainPart in varchar2
    )
  return boolean
  is
  -- checkDomainPart
  begin
    if length( domainPart ) between 1 and Email_DomainPartLength then
      return regexp_like( domainPart, Email_DomainPartFormat )
         and not regexp_like( domainPart, Email_IllegalPartFormat )
      ;
    else
      return false;
    end if;

  end checkDomainPart;


-- isEmailValid
begin
  -- разбивает адрес на локальную и доменную часть
  splitAddress(
      emailAddress => emailAddress
    , localPart    => localPart
    , domainPart   => domainPart
    );

  -- проверка частей адреса
  if (
         checkLength( emailAddress )
     and checkLocalPart( localPart )
     and checkDomainPart( domainPart )
     )
  then
    return 1;
  else
    return 0;
  end if;

end isEmailValid;


end pkg_MailUtility;
/
