create or replace package pkg_MailTest
as
/* package: pkg_MailTest
   Пакет для тестирования модуля Mail
*/



/* group: Константы */



/* group: Параметры тестирования */

/* const: TestSender_OptSName
  Наименование настроечного параметра
  "Тесты: Адрес отправителя"
*/
TestSender_OptSName constant varchar2(50) := 'TestSender';

/* const: TestRecipient_OptSName
  Наименование настроечного параметра
  "Тесты: Адреса получателей"
*/
TestRecipient_OptSName constant varchar2(50) := 'TestRecipient';

/* const: TestSmtpServer_OptSName
  Наименование настроечного параметра
  "Тесты: SMTP сервер"
*/
TestSmtpServer_OptSName constant varchar2(50) := 'TestSmtpServer';

/* const: TestSmtpUsername_OptSName
  Наименование настроечного параметра
  "Тесты: Пользователь для авторизации на SMTP-сервере"
*/
TestSmtpUsername_OptSName constant varchar2(50) := 'TestSmtpUsername';

/* const: TestSmtpPassword_OptSName
  Наименование настроечного параметра
  "Тесты: Пароль для авторизации на SMTP-сервере"
*/
TestSmtpPassword_OptSName constant varchar2(50) := 'TestSmtpPassword';

/* const: TestFetchUrl_OptSName
  Наименование настроечного параметра
  "Тесты: URL почтового ящика в URL-encoded формате ( pop3://user@server.domen)"
*/
TestFetchUrl_OptSName constant varchar2(50) := 'TestFetchUrl';

/* const: TestFetchPassword_OptSName
  Наименование настроечного параметра
  "Тесты: Пароль для подключения к почтовому ящику"
*/
TestFetchPassword_OptSName constant varchar2(50) := 'TestFetchPassword';

/* const: TestFetchSendAddress_OptSName
  Наименование настроечного параметра
  "Тесты: Адрес для отправки сообщений на почтовый ящик ( в случае, если он отличается от адреса, выделяемого из URL почтового ящика)"
*/
TestFetchSendAddress_OptSName constant varchar2(50) := 'TestFetchSendAddress';



/* group: Функции */

/* pproc: smtpsend
  Отправляет письмо ( немедленно).

  ( <body::smtpsend>)
*/
procedure smtpsend(
  recipient varchar2 := null
  , copyRecipient varchar2 := null
  , subject varchar2 := null
  , messageText varchar2 := null
  , sender varchar2 := null
  , smtpServer varchar2 := null
  , username varchar2 := null
  , password varchar2 := null
);

/* pproc: testEmailValidation
   Выполняет тестовые сценарии для проверки работы валидатора email адресов

  ( <body::testEmailValidation>)
*/
procedure testEmailValidation;

/* pproc: testSendMail
  Тестирование немедленной отправки почтовых сообщений.

  Параметры:
  testCaseNumber              - Номер проверяемого тестового случая
                                ( по умолчанию без ограничений)

  ( <body::testSendMail>)
*/
procedure testSendMail(
  testCaseNumber integer := null
);

/* pproc: testSendMessage
  Тестирование отправки почтовых сообщений.

  Параметры:
  testCaseNumber              - Номер проверяемого тестового случая
                                ( по умолчанию без ограничений)

  ( <body::testSendMessage>)
*/
procedure testSendMessage(
  testCaseNumber integer := null
);

/* pproc: testSendHtmlMessage
  Тестирование отправки почтовых сообщений в формате HTML.

  Параметры:
  testCaseNumber              - Номер проверяемого тестового случая
                                ( по умолчанию без ограничений)

  ( <body::testSendHtmlMessage>)
*/
procedure testSendHtmlMessage(
  testCaseNumber integer := null
);

/* pproc: testFetchMessage
  Тестирование получения почтовых сообщений.

  Параметры:
  testCaseNumber              - Номер проверяемого тестового случая
                                ( по умолчанию без ограничений)

  ( <body::testFetchMessage>)
*/
procedure testFetchMessage(
  testCaseNumber integer := null
);

end pkg_MailTest;
/
