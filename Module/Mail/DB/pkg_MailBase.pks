create or replace package pkg_MailBase is
/* package: pkg_MailBase
  Базовый пакет модуля Mail.

  SVN root: Oracle/Module/Mail
*/



/* group: Типы */

/* type: SmtpConfigT
  Настройки SMTP-сервера (тип)
*/
type SmtpConfigT is record (
  smtp_server ml_message.smtp_server%type
  , username varchar2(100)
  , password varchar2(100)
  , default_flag number(1)
);

/* type: SmtpConfigListT
  Список настроек SMTP-серверов (тип, коллекция элементов типа <SmtpConfigT>)
*/
type SmtpConfigListT is table of SmtpConfigT;



/* group: Константы */

/* const: Module_Name
  Название модуля, к которому относится пакет
*/
Module_Name constant varchar2(30) := 'Mail';

/* const: Module_SvnRoot
  Путь к корневому каталогу модуля в Subversion
*/
Module_SvnRoot constant varchar2(100) := 'Oracle/Module/Mail';



/* group: Настроечные параметры */

/* const: DefaultSmtpServer_OptSName
  Краткое наименование параметра
  "SMTP-сервер по умолчанию для отправки писем".
*/
DefaultSmtpServer_OptSName constant varchar2(50) := 'DefaultSmtpServer';

/* const: DefaultSmtpUsername_OptSName
  Краткое наименование параметра
  "Имя пользователя для авторизации на SMTP-сервере по умолчанию"
*/
DefaultSmtpUsername_OptSName constant varchar2(50) := 'DefaultSmtpUsername';

/* const: DefaultSmtpPassword_OptSName
  Краткое наименование параметра
  "Пароль для авторизации на SMTP-сервере по умолчанию"
*/
DefaultSmtpPassword_OptSName constant varchar2(50) := 'DefaultSmtpPassword';



/* group: Функции */

/* pfunc: getDefaultSmtpConfig
  Возвращает настройки SMTP-сервера по умолчанию.

  Параметры:
  getAuthParamsFlag           - Возвращать параметры авторизации
                                (имя пользователя и пароль)
                                (1 да (по умолчанию), 0 нет)

  Возврат:
  настройки (тип <SmtpConfigT>)

  ( <body::getDefaultSmtpConfig>)
*/
function getDefaultSmtpConfig(
  getAuthParamsFlag integer := null
)
return SmtpConfigT;

/* pfunc: getDefaultSmtpServer
  Возвращает SMTP-сервер по умолчанию.

  ( <body::getDefaultSmtpServer>)
*/
function getDefaultSmtpServer
return varchar2;

/* pfunc: parseSmtpServerList
  Разбирает строку со списком адресов SMTP-серверов.

  smtpServerList              - список имён (или ip-адресов) SMTP-серверов
                                через ",". Вместо пустой строки подставляется
                                SMTP-сервер по умолчанию.

  Возврат:
  список настроек SMTP-серверов (тип <SmtpConfigListT>)

  ( <body::parseSmtpServerList>)
*/
function parseSmtpServerList(
  smtpServerList varchar2
)
return SmtpConfigListT;

end pkg_MailBase;
/
