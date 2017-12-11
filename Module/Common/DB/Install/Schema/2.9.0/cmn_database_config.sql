alter table
  cmn_database_config
add
(
  test_notify_flag              number(1,0)
  , sender_domain               varchar2(100)
  , default_flag                number(1,0)               default 0 not null
  , constraint cmn_database_config_chk_not_fl check
    (test_notify_flag in ( 0, 1))
  , constraint cmn_database_config_chk_if_def check
    (default_flag in ( 0, 1))
)
/



comment on table cmn_database_config is
  'Настройки для базы данных [ SVN root: Oracle/Module/Common]'
/
comment on column cmn_database_config.instance_name is
  'Имя экземляра БД, к которой относятся настройки ( сравнивается без учета регистра, в случае отсутствия настроек база данных считается тестовой)'
/
comment on column cmn_database_config.is_production is
  'Флаг промышленной БД ( 1 промышленная, 0 тестовая)'
/
comment on column cmn_database_config.ip_address_production is
  'IP-адрес промышленного сервера БД ( если указан, то БД будет считаться промышленной только в случае совпадения IP-адреса сервера с указанным, при отсутствии IP-адрес сервера БД не проверяется)'
/
comment on column cmn_database_config.test_notify_flag is
  'Флаг отправки нотификации в тестовой среде ( 1 идет, 0 не идет, по умолчанию нотификация не идет)'
/
comment on column cmn_database_config.sender_domain is
  'Домен отправителя, указываемый при соединении с SMTP-сервером ( при отсутствии используется SMTP-сервер по умолчанию, заданный в строке по умолчанию)'
/
comment on column cmn_database_config.smtp_server is
  'Используемый SMTP-сервер ( имя или ip-адрес, при отсутствии используется SMTP-сервер по умолчанию, заданный в строке по умолчанию)'
/
comment on column cmn_database_config.notify_email is
  'Адрес для отправки нотификации по e-mail ( при отсутствии используется адрес по умолчанию, заданный в строке по умолчанию)'
/
comment on column cmn_database_config.default_flag is
  'Признак того, что это строка с данными по умолчанию'
/
