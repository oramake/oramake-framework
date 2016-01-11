create or replace package pkg_MailUtility is
/* package: pkg_MailUtility
  Вспомогательные функции модуля Mail.
*/

/* pfunc: ChangeUrlPassword
  Возвращает URL с измененным паролем
  ( <body::ChangeUrlPassword>).
*/
function ChangeUrlPassword(
  url varchar2
  , newPassword varchar2
)
return varchar2;
/* pfunc: GetAddress
  Возвращает нормализованный почтовый адрес ( <body::GetAddress>).
*/
function GetAddress(
  addressText varchar2
)
return varchar2;
/* pfunc: GetMailboxAddress
  Возвращает адрес почтового ящика по URL ( <body::GetMailboxAddress>).
*/
function GetMailboxAddress(
  url varchar2
)
return varchar2;
/* pfunc: GetEncodedAddressList
  Возвращает кодированный список адресов
  ( <body::GetEncodedAddressList>).
*/
function GetEncodedAddressList(
  textAddressList varchar2
)
return varchar2;
/* pfunc: GetTextAddressList
  Возвращает текстовый список адресов
  ( <body::GetTextAddressList>).
*/
function GetTextAddressList(
  addressList varchar2
)
return varchar2;

/* pproc: SetDeleteErrorMessageUid
  Установка значения идентификатора сообщения,
  которое нужно удалить из ящика в случае ошибки
  получения в данной сессии (см. <pkg_Mail.FetchMessageImmediate>)
  ( <body::SetDeleteErrorMessageUid>)
*/
procedure SetDeleteErrorMessageUid(
  messageUid varchar2
);

/* pfunc: GetDeleteErrorMessageUid
  Получение установленного идентификатора сообщения,
  которое нужно удалить из ящика в случае ошибки
  получения в данной сессии (см. <pkg_Mail.FetchMessageImmediate>)
  ( <body::GetDeleteErrorMessageUid>)
*/
function GetDeleteErrorMessageUid
return varchar2;


/* pfunc: isEmailValid
   Выполняет проверку корректности адреса электронной почты

   Параметры:
     emailAddress                   - адрес электронной почты

   Возврат:
     - если адрес email корректен, то 1, иначе 0

   (<body::isEmailValid>)
*/
function isEmailValid (
  emailAddress in varchar2
  )
return integer;


end pkg_MailUtility;
/
