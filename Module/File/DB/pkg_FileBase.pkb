create or replace package body pkg_FileBase is
/* package body: pkg_FileBase::body */



/* group: ѕеременные */

/* ivar: logger
  Ћогер пакета.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => pkg_FileOrigin.Module_Name
  , objectName  => 'pkg_FileBase'
);



/* group: ‘ункции */

/* proc: getProxyConfig
  ¬озвращает настройки прокси-сервера дл€ обращени€ по указанному URL.
  ¬ызываетс€ из Java-класса com.technology.oramake.file.netfile.HttpFile.

  ѕараметры:
  serverAddress               - адрес прокси-сервера ( null если не требуетс€
                                использовать прокси-сервер)
                                ( возврат)
  serverPort                  - порт прокси-сервера
                                ( возврат)
  username                    - им€ пользовател€ дл€ авторизации на
                                прокси-сервере
  password                    - пароль пользовател€ дл€ авторизации на
                                прокси-сервере
  domain                      - домен пользовател€ дл€ авторизации на
                                прокси-сервере
  targetProtocol              - протокол из URL назначени€
  targetHost                  - хост из URL назначени€
  targetPort                  - порт из URL назначени€
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
)
is

  -- —писок параметров модул€
  opl opt_option_list_t := opt_option_list_t(
    moduleName => pkg_FileOrigin.Module_Name
  );

  -- ‘лаг использовани€ прокси-сервера
  useProxyFlag integer;

  -- ѕараметр с некорректным значением
  badOptionValue varchar2(200);

begin
  select
    1 - count(*)
  into useProxyFlag
  from
    (
    select
      lower( replace( t.column_value, '*', '%')) as host_mask
    from
      table( pkg_Common.split(
        opl.getString( ProxySkipAddressList_OptSName)
        , ';'
      )) t
    ) a
  where
    lower( targetHost) like a.host_mask
    or lower( targetProtocol || '://' || targetHost) like a.host_mask
    or lower( targetHost || ':' || targetPort) like a.host_mask
    or lower( targetProtocol || '://' || targetHost || ':' || targetPort)
      like a.host_mask
    and rownum <= 1
  ;
  if useProxyFlag = 1 then
    serverAddress := opl.getString( ProxyServerAddress_OptSName);
    serverPort    := opl.getNumber( ProxyServerPort_OptSName);
    username      := opl.getString( ProxyUsername_OptSName);
    password      := opl.getString( ProxyPassword_OptSName);
    domain        := opl.getString( ProxyDomain_OptSName);
    badOptionValue :=
      case
        when serverAddress is null then ProxyServerAddress_OptSName
        when serverPort is null then ProxyServerPort_OptSName
        when username is null then ProxyUsername_OptSName
        when password is null then ProxyPassword_OptSName
        when domain is null then ProxyDomain_OptSName
      end
    ;
    if badOptionValue is not null then
      raise_application_error(
        pkg_Error.ProcessError
        , 'Ќе задано значение настроечного параметра модул€'
          || ' "' || badOptionValue || '"'
          || ', необходимое дл€ использовани€ прокси-сервера.'
      );
    end if;
  end if;
  logger.trace(
    'getProxyConfig'
    || ': for'
      || ' protocol "' || targetProtocol || '"'
      || ', host "' || targetHost || '"'
      || ', port "' || targetPort || '"'
    || case when serverAddress is null then
        ': without proxy'
      else
        ': use proxy'
        || ' address "' || serverAddress || '"'
        || ', port "' || serverPort || '"'
        || ', username "' || username || '"'
        || ', domain "' || domain || '"'
      end
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'ќшибка при возврате настроек прокси-сервера дл€ обращени€ по URL ('
        || ' targetProtocol="' || targetProtocol || '"'
        || ', targetHost="' || targetHost || '"'
        || ', targetPort=' || targetPort
        || ').'
      )
    , true
  );
end getProxyConfig;

end pkg_FileBase;
/
