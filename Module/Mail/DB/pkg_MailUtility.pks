create or replace package pkg_MailUtility is
/* package: pkg_MailUtility
  Вспомогательные функции модуля Mail.
*/



/* group: Функции */

/* pfunc: changeUrlPassword
  Возвращает URL с измененным паролем.

  Параметры:
  url                         - URL почтового ящика в URL-encoded формате
                                ( pop3://user:passwd@server.domen)
  newPassword                 - новый пароль

  ( <body::changeUrlPassword>)
*/
function changeUrlPassword(
  url varchar2
  , newPassword varchar2
)
return varchar2;

/* pfunc: getAddress
  Возвращает нормализованный почтовый адрес.
  При наличии нескольких адресов, возвращается первый из них.

  Параметры:
  addressText                 - текст адреса

  ( <body::getAddress>)
*/
function getAddress(
  addressText varchar2
)
return varchar2;

/* pfunc: getMailboxAddress
  Возвращает адрес почтового ящика по URL ( в случае невозможности -
  выбрасывает исключение).

  Параметры:
  url                         - URL почтового ящика в URL-encoded формате
                                ( pop3://user:passwd@server.domen)

  ( <body::getMailboxAddress>)
*/
function getMailboxAddress(
  url varchar2
)
return varchar2;

/* pfunc: getEncodedAddressList
  Возвращает кодированный список адресов.

  Параметры:
  textAddressList             - текст адреса ( можно список с разделителем ","
                                или ";")

  ( <body::getEncodedAddressList>)
*/
function getEncodedAddressList(
  textAddressList varchar2
)
return varchar2;

/* pfunc: getTextAddressList
  Возвращает текстовый список адресов.

  Параметры:
  addressList                 - список адресов

  ( <body::getTextAddressList>)
*/
function getTextAddressList(
  addressList varchar2
)
return varchar2;

/* pproc: setDeleteErrorMessageUid
  Установка значения идентификатора сообщения,
  которое нужно удалить из ящика в случае ошибки
  получения в данной сессии (см. <pkg_MailHandler.fetchMessageImmediate>)
  При null, сообщения удаляются только при получении.

  Параметры:
  messageUid                  - значение идентификатора сообщения для удаления

  ( <body::setDeleteErrorMessageUid>)
*/
procedure setDeleteErrorMessageUid(
  messageUid varchar2
);

/* pfunc: getDeleteErrorMessageUid
  Получение установленного идентификатора сообщения,
  которое нужно удалить из ящика в случае ошибки
  получения в данной сессии (см. <pkg_MailHandler.fetchMessageImmediate>)

  Возврат:
  значение идентификатора сообщения для удаления.

  ( <body::getDeleteErrorMessageUid>)
*/
function getDeleteErrorMessageUid
return varchar2;

/* pfunc: isEmailValid
   Выполняет проверку корректности адреса электронной почты

   Параметры:
     emailAddress                   - адрес электронной почты

   Возврат:
     - если адрес email корректен, то 1, иначе 0

  ( <body::isEmailValid>)
*/
function isEmailValid (
  emailAddress in varchar2
  )
return integer;

end pkg_MailUtility;
/
