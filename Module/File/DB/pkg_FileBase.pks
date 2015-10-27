create or replace package pkg_FileBase is
/* package: pkg_FileBase
  Базовый пакет модуля.

  SVN root: Oracle/Module/File
*/



/* group: Константы */



/* group: Наименования настроечных параметров */

/* const: ProxyServerAddress_OptSName
  Короткое наименование опции "Адрес прокси-сервера ( используется для
  запросов по протоколу HTTP)"
*/
ProxyServerAddress_OptSName constant varchar2(50) := 'ProxyServerAddress';

/* const: ProxyServerPort_OptSName
  Короткое наименование опции "Порт прокси-сервера"
*/
ProxyServerPort_OptSName constant varchar2(50) := 'ProxyServerPort';

/* const: ProxyUsername_OptSName
  Короткое наименование опции
  "Имя пользователя для авторизации на прокси-сервере"
*/
ProxyUsername_OptSName constant varchar2(50) := 'ProxyUsername';

/* const: ProxyPassword_OptSName
  Короткое наименование опции
  "Пароль пользователя для авторизации на прокси-сервере"
*/
ProxyPassword_OptSName constant varchar2(50) := 'ProxyPassword';

/* const: ProxyDomain_OptSName
  Короткое наименование опции
  "Домен пользователя для авторизации на прокси-сервере"
*/
ProxyDomain_OptSName constant varchar2(50) := 'ProxyDomain';

/* const: ProxySkipAddressList_OptSName
  Короткое наименование опции
  "Список адресов, для которых прокси-сервер не используется"
*/
ProxySkipAddressList_OptSName constant varchar2(50) := 'ProxySkipAddressList';



/* group: Функции */

/* pproc: getProxyConfig
  Возвращает настройки прокси-сервера для обращения по указанному URL.
  Вызывается из Java-класса ru.company.netfile.HttpFile.

  Параметры:
  serverAddress               - адрес прокси-сервера ( null если не требуется
                                использовать прокси-сервер)
                                ( возврат)
  serverPort                  - порт прокси-сервера
                                ( возврат)
  username                    - имя пользователя для авторизации на
                                прокси-сервере
  password                    - пароль пользователя для авторизации на
                                прокси-сервере
  domain                      - домен пользователя для авторизации на
                                прокси-сервере
  targetProtocol              - протокол из URL назначения
  targetHost                  - хост из URL назначения
  targetPort                  - порт из URL назначения

  ( <body::getProxyConfig>)
*/
procedure getProxyConfig(
  serverAddress out varchar2
  , serverPort out integer
  , username out varchar2
  , password out varchar2
  , domain out varchar2
  , targetProtocol varchar2
  , targetHost varchar2
  , targetPort integer
);

end pkg_FileBase;
/
