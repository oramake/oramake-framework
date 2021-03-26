create or replace package body pkg_MailBase is
/* package body: pkg_MailBase::body */



/* group: Переменные */

/* ivar: logger
  Логер пакета.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName => Module_Name
  , objectName => 'pkg_MailBase'
);

/* ivar: moduleOption
  Настроечные параметры модуля.
*/
moduleOption opt_option_list_t := opt_option_list_t(
  findModuleString => Module_SvnRoot
);



/* group: Функции */

/* func: getDefaultSmtpConfig
  Возвращает настройки SMTP-сервера по умолчанию.

  Параметры:
  getAuthParamsFlag           - Возвращать параметры авторизации
                                (имя пользователя и пароль)
                                (1 да (по умолчанию), 0 нет)

  Возврат:
  настройки (тип <SmtpConfigT>)
*/
function getDefaultSmtpConfig(
  getAuthParamsFlag integer := null
)
return SmtpConfigT
is

  cfg SmtpConfigT;

begin
  cfg.smtp_server := moduleOption.getString(
    optionShortName => DefaultSmtpServer_OptSName
    , useCacheFlag  => 1
  );
  if cfg.smtp_server is not null and coalesce( getAuthParamsFlag, 1) != 0 then
    cfg.username := moduleOption.getString(
      optionShortName => DefaultSmtpUsername_OptSName
      , useCacheFlag  => 1
    );
    cfg.password := moduleOption.getString(
      optionShortName => DefaultSmtpPassword_OptSName
      , useCacheFlag  => 1
    );
  else
    cfg.smtp_server := pkg_Common.getSmtpServer();
  end if;
  cfg.default_flag := 1;
  return cfg;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при определении настроек SMTP-сервера по умолчанию ('
        || 'getAuthParamsFlag=' || getAuthParamsFlag
        || ').'
      )
    , true
  );
end getDefaultSmtpConfig;

/* func: getDefaultSmtpServer
  Возвращает SMTP-сервер по умолчанию.
*/
function getDefaultSmtpServer
return varchar2
is

  cfg SmtpConfigT;

begin
  cfg := getDefaultSmtpConfig( getAuthParamsFlag => 0);
  return cfg.smtp_server;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при определении SMTP-сервера по умолчанию.'
      )
    , true
  );
end getDefaultSmtpServer;

/* func: parseSmtpServerList
  Разбирает строку со списком адресов SMTP-серверов.

  smtpServerList              - список имён (или ip-адресов) SMTP-серверов
                                через ",". Вместо пустой строки подставляется
                                SMTP-сервер по умолчанию.

  Возврат:
  список настроек SMTP-серверов (тип <SmtpConfigListT>)
*/
function parseSmtpServerList(
  smtpServerList varchar2
)
return SmtpConfigListT
is

  -- Результирующая коллекция
  resList SmtpConfigListT := SmtpConfigListT();

  -- Указатели на символы в строке
  i integer := 1;
  j integer;

  -- Признак окончания разбора
  finished boolean := false;

  -- Длина строки списка имён SMTP-серверов
  lengthSmtpList integer := coalesce( length( smtpServerList),0);

  -- Настройки добавляемого сервера
  cfg SmtpConfigT;

  -- Настройки SMTP-сервера по умолчанию
  defCfg pkg_MailBase.SmtpConfigT;

begin
  defCfg := getDefaultSmtpConfig();
  i := 1;
  for safeLoop in 1..lengthSmtpList+2 loop
    j := coalesce( instr( smtpServerList, ',', i, 1),0);
    if j = 0 then
      j := lengthSmtpList + 1;
      finished := true;
    end if;

    -- Получаем следующий элемент
    cfg.smtp_server := replace(
      substr( smtpServerList, i, j-i)
      , ' '
    );
    if cfg.smtp_server is null then
      cfg := defCfg;
    else
      cfg.default_flag :=
        case when cfg.smtp_server = defCfg.smtp_server then 1 else 0 end
      ;
    end if;
    resList.extend;
    resList( resList.last) := cfg;
    logger.trace( 'add SMTP: "' || cfg.smtp_server || '"');
    cfg := null;
    exit when finished;
    i := j + 1;
  end loop;
  return resList;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка разбора строки списка адресов SMTP ('
        || 'smtpServerList="' || smtpServerList || '"'
        || ').'
      )
    , true
  );
end parseSmtpServerList;

end pkg_MailBase;
/
