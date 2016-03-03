create or replace package body pkg_OptionCrypto is
/* package body: pkg_OptionCrypto::body */



/* group: Переменные */

/* ivar: logger
  Логер пакета.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => 'Option'
  , objectName  => 'pkg_OptionCrypto'
);

/* ivar: cipherType
  Тип используемого шифра ( кодировка пакета dbms_crypto).
*/
cipherType pls_integer;

/* ivar: cryptoKey
  Ключ шифрования/дешифрования.
*/
cryptoKey raw(100);





/* group: Функции */

/* func: isCryptoAvailable
  Возвращает флаг возможности использования функций шифрования.

  Возврат:
  1 если функции доступны, иначе 0.
*/
function isCryptoAvailable
return integer
is

  -- Флаг доступности функций шифрования
  isAvailable integer;

begin
  select
    count(*) as is_available
  into isAvailable
  from
    all_objects t
  where
    t.owner = 'SYS'
    and t.object_name = 'DBMS_CRYPTO'
    and t.object_type = 'PACKAGE'
  ;
  return isAvailable;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при определении доступности функций шифрования.'
      )
    , true
  );
end isCryptoAvailable;

/* iproc: setCryptoConfig
  Устанавливает настройки шифрования, сохраняя их в переменных пакета
  <cipherType> и <cryptoKey>.
*/
procedure setCryptoConfig
is
begin
  execute immediate '
begin
  :cipherType :=
    dbms_crypto.ENCRYPT_AES256
    + dbms_crypto.CHAIN_CBC
    + dbms_crypto.PAD_PKCS5
  ;
end;
'
  using
    out cipherType
  ;
  cryptoKey := opt_getLocalCryptoKey();
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при определении настроек шифрования.'
      )
    , true
  );
end setCryptoConfig;

/* func: encrypt
  Возвращает зашифрованное значение.

  Параметры:
  inputString                 - входная строка
  forbiddenChar               - запрещенный для использования в зашифрованном
                                значении символ
                                ( по умолчанию без ограничений)

  Возврат:
  зашифрованная строка.
*/
function encrypt(
  inputString varchar2
  , forbiddenChar varchar2 := null
)
return varchar2
is

  -- Зашифрованное значение
  outString opt_value.string_value%type;

-- encrypt
begin
  if cipherType is null then
    setCryptoConfig();
  end if;
  if inputString is not null then
    execute immediate '
begin
:outString :=
  rawtohex(
    dbms_crypto.encrypt(
      src   => utl_i18n.string_to_raw( :inputString, ''AL32UTF8'')
      , typ => :cipherType
      , key => :cryptoKey
    )
  )
;
end;
'
    using
      out outString
      , inputString
      , cipherType
      , cryptoKey
    ;
    if forbiddenChar is not null and instr( outString, forbiddenChar) > 0 then
      raise_application_error(
        pkg_Error.ProcessError
        , 'В зашифрованном значении содержится запрещенный символ ('
          || ' forbiddenChar="' || forbiddenChar || '"'
          || ').'
      );
    end if;
  end if;
  return outString;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при шифровании значения.'
      )
    , true
  );
end encrypt;

/* func: decrypt
  Возвращает расшифрованное значение.

  Параметры:
  inputString                 - входная строка

  Возврат:
  расшифрованная строка.
*/
function decrypt(
  inputString varchar2
)
return varchar2
is

  -- Расшифрованное значение
  outString opt_value.string_value%type;

begin
  if cipherType is null then
    setCryptoConfig();
  end if;
  if inputString is not null then
    execute immediate '
begin
:outString :=
  utl_i18n.raw_to_char(
    dbms_crypto.decrypt(
      src   => hextoraw( :inputString)
      , typ => :cipherType
      , key => :cryptoKey
    )
    , ''AL32UTF8''
  )
;
end;
'
    using
      out outString
      , inputString
      , cipherType
      , cryptoKey
    ;
  end if;
  return outString;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при расшифровке значения.'
      )
    , true
  );
end decrypt;

end pkg_OptionCrypto;
/
