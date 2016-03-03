create or replace package body pkg_OptionCrypto is
/* package body: pkg_OptionCrypto::body */



/* group: ���������� */

/* ivar: logger
  ����� ������.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => 'Option'
  , objectName  => 'pkg_OptionCrypto'
);

/* ivar: cipherType
  ��� ������������� ����� ( ��������� ������ dbms_crypto).
*/
cipherType pls_integer;

/* ivar: cryptoKey
  ���� ����������/������������.
*/
cryptoKey raw(100);





/* group: ������� */

/* func: isCryptoAvailable
  ���������� ���� ����������� ������������� ������� ����������.

  �������:
  1 ���� ������� ��������, ����� 0.
*/
function isCryptoAvailable
return integer
is

  -- ���� ����������� ������� ����������
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
        '������ ��� ����������� ����������� ������� ����������.'
      )
    , true
  );
end isCryptoAvailable;

/* iproc: setCryptoConfig
  ������������� ��������� ����������, �������� �� � ���������� ������
  <cipherType> � <cryptoKey>.
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
        '������ ��� ����������� �������� ����������.'
      )
    , true
  );
end setCryptoConfig;

/* func: encrypt
  ���������� ������������� ��������.

  ���������:
  inputString                 - ������� ������
  forbiddenChar               - ����������� ��� ������������� � �������������
                                �������� ������
                                ( �� ��������� ��� �����������)

  �������:
  ������������� ������.
*/
function encrypt(
  inputString varchar2
  , forbiddenChar varchar2 := null
)
return varchar2
is

  -- ������������� ��������
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
        , '� ������������� �������� ���������� ����������� ������ ('
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
        '������ ��� ���������� ��������.'
      )
    , true
  );
end encrypt;

/* func: decrypt
  ���������� �������������� ��������.

  ���������:
  inputString                 - ������� ������

  �������:
  �������������� ������.
*/
function decrypt(
  inputString varchar2
)
return varchar2
is

  -- �������������� ��������
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
        '������ ��� ����������� ��������.'
      )
    , true
  );
end decrypt;

end pkg_OptionCrypto;
/
