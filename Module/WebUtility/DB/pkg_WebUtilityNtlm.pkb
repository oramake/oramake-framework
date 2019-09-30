create or replace package body pkg_WebUtilityNtlm is
/* package body: pkg_WebUtilityNtlm::body */

/* group: Types */

  g_max_pl_varchar2_def          varchar2(32767);
  subtype t_max_pl_varchar2      is g_max_pl_varchar2_def%type;

/* group: Constants */

  m_NTLM_NegotiateUnicode        constant raw(4) := utl_raw.cast_from_binary_integer(1); --'00000001';
  m_NTLM_NegotiateOEM            constant raw(4) := utl_raw.cast_from_binary_integer(2); --'00000002';
  m_NTLM_RequestTarget           constant raw(4) := utl_raw.cast_from_binary_integer(4); --'00000004';
  m_NTLM_Unknown9                constant raw(4) := utl_raw.cast_from_binary_integer(8); -- '00000008';
  m_NTLM_NegotiateSign           constant raw(4) := utl_raw.cast_from_binary_integer(16); --'00000010';
  m_NTLM_NegotiateSeal           constant raw(4) := utl_raw.cast_from_binary_integer(32); --'00000020';
  m_NTLM_NegotiateDatagram       constant raw(4) := utl_raw.cast_from_binary_integer(64); --'00000040';
  m_NTLM_NegotiateLanManagerKey  constant raw(4) := utl_raw.cast_from_binary_integer(128); --'00000080';
  m_NTLM_Unknown8                constant raw(4) := utl_raw.cast_from_binary_integer(256); --'00000100';
  m_NTLM_NegotiateNTLM           constant raw(4) := utl_raw.cast_from_binary_integer(512); --'00000200';
  m_NTLM_NegotiateNTOnly         constant raw(4) := utl_raw.cast_from_binary_integer(1024); --'00000400';
  m_NTLM_Anonymous               constant raw(4) := utl_raw.cast_from_binary_integer(2048); --'00000800';
  m_NTLM_NegotiateOemDomainSuppl constant raw(4) := utl_raw.cast_from_binary_integer(4096); --'00001000';
  m_NTLM_NegotiateOemWorkstation constant raw(4) := utl_raw.cast_from_binary_integer(8192); --'00002000';
  m_NTLM_Unknown6                constant raw(4) := utl_raw.cast_from_binary_integer(16384); --'00004000';
  m_NTLM_NegotiateAlwaysSign     constant raw(4) := utl_raw.cast_from_binary_integer(32768); --'00008000';
  m_NTLM_TargetTypeDomain        constant raw(4) := utl_raw.cast_from_binary_integer(65536); --'00010000';
  m_NTLM_TargetTypeServer        constant raw(4) := utl_raw.cast_from_binary_integer(131072); --'00020000';
  m_NTLM_TargetTypeShare         constant raw(4) := utl_raw.cast_from_binary_integer(262144); --'00040000';
  m_NTLM_NegotiateExtendedSec    constant raw(4) := utl_raw.cast_from_binary_integer(524288); --'00080000';
  m_NTLM_NegotiateIdentify       constant raw(4) := utl_raw.cast_from_binary_integer(1048576); --'00100000';
  m_NTLM_Unknown5                constant raw(4) := utl_raw.cast_from_binary_integer(2097152); --'00200000';
  m_NTLM_RequestNonNTSessionKey  constant raw(4) := utl_raw.cast_from_binary_integer(4194304); --'00400000';
  m_NTLM_NegotiateTargetInfo     constant raw(4) := utl_raw.cast_from_binary_integer(8388608); --'00800000';
  m_NTLM_Unknown4                constant raw(4) := utl_raw.cast_from_binary_integer(16777216); --'01000000';

  m_NTLM_NegotiateVersion        constant raw(4) := utl_raw.cast_from_binary_integer(33554432); --'02000000';
  m_NTLM_Unknown3                constant raw(4) := utl_raw.cast_from_binary_integer(67108864); --'04000000';
  m_NTLM_Unknown2                constant raw(4) := utl_raw.cast_from_binary_integer(134217728); --'08000000';
  m_NTLM_Unknown1                constant raw(4) := utl_raw.cast_from_binary_integer(268435456); --'10000000';
  m_NTLM_Negotiate128            constant raw(4) := utl_raw.cast_from_binary_integer(536870912); --'20000000';
  m_NTLM_NegotiateKeyExchange    constant raw(4) := utl_raw.cast_from_binary_integer(1073741824); --'40000000';
  m_NTLM_Negotiate56             constant raw(4) := utl_raw.cast_from_binary_integer(128, utl_raw.little_endian); -- '80000000'; -- using little endian instead of big beacuse utl_raw.cast_from_binary_integer(2147483648) results in overflow



/* group: Variables */

/* ivar: logger
  Logger of package..
*/
logger lg_logger_t := lg_logger_t.GetLogger(
  moduleName    => pkg_WebUtility.Module_Name
  , objectName  => 'pkg_WebUtilityNtml'
);

/* ivar: endianness
  Bytes order.
  Global setup for all functions.
*/
endianness pls_integer := utl_raw.little_endian;



/* group: Functions */



/* pfunc: bitShiftLeftBi
  bitwise shift left (binary integer).
*/
function bitShiftLeftBi(
  val in binary_integer
  , shift in number
)
return binary_integer
is
begin
  return val * power(2, shift);
end bitShiftLeftBi;

/* pfunc: bitShiftLeftRaw
  bitwise shift left (raw).
*/
function bitShiftLeftRaw(
  val in raw
  , shift in number
)
return raw
as
begin
  return
    utl_raw.cast_from_binary_integer(
      bitShiftLeftBi(
        utl_raw.cast_to_binary_integer(
          val
          , endianness
        )
      , shift
      )
      , endianness
    );
end bitShiftLeftRaw;

/* pfunc: bitShiftRightBi
  bitwise shift right (binary integer)
*/
function bitShiftRightBi(
  val in binary_integer
  , shift in number
)
return binary_integer
is
begin
  return
    trunc(val / power(2, shift));
end bitShiftRightBi;


/* pfunc: bitShiftRightRaw
  bitwise shift right (raw)
*/
function bitShiftRightRaw(
  val in raw
  , shift in number
)
return raw
is
begin
  return
    utl_raw.cast_from_binary_integer(
      bitShiftRightBi(
        utl_raw.cast_to_binary_integer(
          val
          , endianness
        )
        , shift
      )
      , endianness
    );
end bitShiftRightRaw;

/* pfunc: bitOrMulti
  Perform bitwise OR operations on multiple RAWs
*/
function bitOrMulti(
  raw1 in raw
  , raw2 in raw
  , raw3 in raw := null
  , raw4 in raw := null
  , raw5 in raw := null
  , raw6 in raw := null
  , raw7 in raw := null
  , raw8 in raw := null
  , raw9 in raw := null
  , raw10 in raw := null
  , raw11 in raw := null
  , raw12 in raw := null
)
return raw
as
  returnValue raw(5000);
begin
  returnValue := utl_raw.bit_or(raw1, raw2);

  if raw3 is not null then
    returnValue := utl_raw.bit_or(returnValue, raw3);
  end if;

  if raw4 is not null then
    returnValue := utl_raw.bit_or(returnValue, raw4);
  end if;

  if raw5 is not null then
    returnValue := utl_raw.bit_or(returnValue, raw5);
  end if;

  if raw6 is not null then
    returnValue := utl_raw.bit_or(returnValue, raw6);
  end if;

  if raw7 is not null then
    returnValue := utl_raw.bit_or(returnValue, raw7);
  end if;

  if raw8 is not null then
    returnValue := utl_raw.bit_or(returnValue, raw8);
  end if;

  if raw9 is not null then
    returnValue := utl_raw.bit_or(returnValue, raw9);
  end if;

  if raw10 is not null then
    returnValue := utl_raw.bit_or(returnValue, raw10);
  end if;

  if raw11 is not null then
    returnValue := utl_raw.bit_or(returnValue, raw11);
  end if;

  if raw12 is not null then
    returnValue := utl_raw.bit_or(returnValue, raw12);
  end if;

  return returnValue;
end bitOrMulti;


/* pfunc: intToRawLittleEndian
  Returning little endian value of integer of specified length
*/
function intToRawLittleEndian(
  numberValue in number
  , length in number
)
return raw
as
  returnValue raw(5000);
begin
  returnValue := utl_raw.substr(
    utl_raw.cast_from_binary_integer(numberValue, utl_raw.little_endian)
    , 1
    , length);

  return returnValue;

end intToRawLittleEndian;

/* pfunc: strToBase64
  encode string using base64
*/
function strToBase64(
  str in varchar2
)
return varchar2
as
begin
  return
    utl_raw.cast_to_varchar2(
      utl_encode.base64_encode(utl_raw.cast_to_raw(str))
    );

end strToBase64;

/* pfunc: getWorkstationName
  Get workstation name for executing user
*/
function getWorkstationName return varchar2
as
begin
  return
    upper(sys_context('USERENV', 'server_host'));
end getWorkstationName;



/* pfunc: getNegotiateMmessage
  Get negotiate message
*/
function getNegotiateMessage(
  username in varchar2
  , domain in varchar2
)
return varchar2
as

  bodyLength                  number;
  payloadStart                number;

  protocol                    raw(16);
  workstation                 raw(16);
  domainRaw                   raw(16);

  typeRaw                     raw(4);
  flags                       raw(4);

  workstationLength            raw(2);
  workstationMaxLength        raw(2);
  workstationBufferOffset     raw(4);

  domainLength                raw(2);
  domainMaxLength             raw(2);
  domainBufferOffset          raw(4);

  productMajorVersion         raw(1);
  productMinorVersion         raw(1);
  productBuild                raw(2);

  versionReserved1            raw(1);
  versionReserved2            raw(1);
  versionReserved3            raw(1);

  ntlmRevisionCurrent         raw(1);

  returnRaw                   raw(100);

  returnValue                 t_max_pl_varchar2;

begin

  bodyLength := 40;
  payloadStart := bodylength;

  protocol := utl_raw.cast_to_raw('NTLMSSP' || chr(0));

  typeRaw := intToRawLittleEndian(1, 4); --- Type 1

  flags := bitOrMulti(
    m_NTLM_NegotiateUnicode
    , m_NTLM_NegotiateOEM
    , m_NTLM_RequestTarget
    , m_NTLM_NegotiateNTLM
    , m_NTLM_NegotiateOemDomainSuppl
    , m_NTLM_NegotiateOemWorkstation
    , m_NTLM_NegotiateAlwaysSign
    , m_NTLM_NegotiateExtendedSec
    , m_NTLM_NegotiateVersion
    , m_NTLM_Negotiate128
    , m_NTLM_Negotiate56
  );

  -- need to convert flags to little endian
  flags := intToRawLittleEndian(utl_raw.cast_to_binary_integer(flags), 4);

  workstation := utl_raw.cast_to_raw(getWorkstationName());
  domainRaw := utl_raw.cast_to_raw(domain);

  workstationLength := intToRawLittleEndian(utl_raw.length(workstation), 2);
  workstationMaxLength := intToRawLittleEndian(utl_raw.length(workstation), 2);
  workstationBufferOffset := intToRawLittleEndian(payloadStart, 4);

  payloadStart := payloadStart + utl_raw.length(workstation);

  domainLength := intToRawLittleEndian (utl_raw.length(domainRaw), 2);
  domainMaxLength := intToRawLittleEndian (utl_raw.length(domainRaw), 2);
  domainBufferOffset := intToRawLittleEndian (payloadStart, 4);

  payloadStart := payloadStart + utl_raw.length(domainRaw);

  productMajorVersion := intToRawLittleEndian (5, 1);
  productMinorVersion := intToRawLittleEndian (1, 1);
  productBuild := intToRawLittleEndian (2600, 2);

  versionReserved1 := intToRawLittleEndian (0, 1);
  versionReserved2 := intToRawLittleEndian (0, 1);
  versionReserved3 := intToRawLittleEndian (0, 1);

  ntlmRevisionCurrent := intToRawLittleEndian (15, 1);

  returnRaw := utl_raw.concat(protocol,
                             typeRaw,
                             flags,
                             domainLength,
                             domainMaxLength,
                             domainBufferOffset,
                             workstationLength,
                             workstationMaxLength,
                             workstationBufferOffset,
                             productMajorVersion,
                             productMinorVersion,
                             productBuild);

  returnRaw := utl_raw.concat(returnRaw,
                             versionReserved1,
                             versionReserved2,
                             versionReserved3,
                             ntlmRevisionCurrent);

  if utl_raw.length (returnRaw) <> bodyLength then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Length of negotiate message is ' || utl_raw.length(returnRaw) || ' (should be ' || bodyLength ||')'
        )
    );
  end if;

  returnRaw := utl_raw.concat (returnRaw, workstation, domainRaw);

  returnValue := utl_raw.cast_to_varchar2(returnRaw);
  returnValue := strToBase64(returnValue);
  returnValue := replace(returnValue, chr(13) || chr(10), '');

  return returnValue;

end getNegotiateMessage;

/* pproc: parseChallengeMessage
  Parse challenge message from server
*/
procedure parseChallengeMessage(
  message2 in varchar2
  , serverChallengeRaw out raw
  , negotiateFlagsRaw out raw
)
as
  message                    t_max_pl_varchar2;

  msg                        raw(4000);

  signature                  raw(8);
  msgType                    raw(4);

  targetNameLength           raw(2);
  targetNameMaxLength        raw(2);
  targetNameOffset           raw(4);

  targetName                 raw(100);

  negotiateFlags             raw(4);

  serverChallenge            raw(8);
  reserved                   raw(8);

  targetInfoLength           raw(2);
  targetInfoMaxLength        raw(2);
  targetInfoOffset           raw(4);

  targetInfo                 raw(100);

begin

  msg := utl_encode.base64_decode(utl_raw.cast_to_raw(message2));

  signature := utl_raw.substr(msg, 1, 8);
  msgType := utl_raw.substr(msg, 9, 4);

  targetNameLength := utl_raw.substr(msg, 13, 2);
  targetNameMaxLength := utl_raw.substr(msg, 15, 2);
  targetNameOffset := utl_raw.substr(msg, 17, 4);

  -- using reverse because the flags are in little endian order?
  negotiateFlags := utl_raw.reverse(utl_raw.substr(msg, 21, 4));

  serverChallenge := utl_raw.substr(msg, 25, 8);
  reserved := utl_raw.substr(msg, 33, 8);

  targetInfoLength := utl_raw.substr(msg, 41, 2);
  targetInfoMaxLength := utl_raw.substr(msg, 43, 2);
  targetInfoOffset := utl_raw.substr(msg, 45, 4);

  serverChallengeRaw := serverChallenge;
  negotiateFlagsRaw := negotiateFlags;

end parseChallengeMessage;

/* pproc: createDesKey
  create an 8-byte DES key from a 7-byte key

  Remarks:      insert a null bit after every seven bits (so 1010100 becomes 01010100)
*/
function createDesKey(
  bytes in raw
)
return raw
as
  byte1                        raw(1);
  byte2                        raw(1);
  byte3                        raw(1);
  byte4                        raw(1);
  byte5                        raw(1);
  byte6                        raw(1);
  byte7                        raw(1);
  byte8                        raw(1);
  returnValue                  raw(8);

  function raw2num(rawValue in raw) return number
  is
  begin
    return utl_raw.cast_to_binary_integer(rawValue, utl_raw.little_endian);
  end raw2num;

  function get8bitMask return raw
  as
  begin
    return utl_raw.cast_from_binary_integer(255, utl_raw.little_endian);
  end get8bitMask;

begin
  endianness := utl_raw.little_endian;

  byte1 := utl_raw.substr(bytes, 1, 1);
  byte2 := utl_raw.substr( utl_raw.bit_or(utl_raw.bit_and(bitShiftLeftRaw (utl_raw.substr(bytes, 1, 1), 7), get8bitMask), bitShiftRightRaw (utl_raw.substr(bytes, 2, 1), 1)) , 1, 1);
  byte3 := utl_raw.substr( utl_raw.bit_or(utl_raw.bit_and(bitShiftLeftRaw (utl_raw.substr(bytes, 2, 1), 6), get8bitMask), bitShiftRightRaw (utl_raw.substr(bytes, 3, 1), 2)) , 1, 1);
  byte4 := utl_raw.substr( utl_raw.bit_or(utl_raw.bit_and(bitShiftLeftRaw (utl_raw.substr(bytes, 3, 1), 5), get8bitMask), bitShiftRightRaw (utl_raw.substr(bytes, 4, 1), 3)) , 1, 1);
  byte5 := utl_raw.substr( utl_raw.bit_or(utl_raw.bit_and(bitShiftLeftRaw (utl_raw.substr(bytes, 4, 1), 4), get8bitMask), bitShiftRightRaw (utl_raw.substr(bytes, 5, 1), 4)) , 1, 1);
  byte6 := utl_raw.substr( utl_raw.bit_or(utl_raw.bit_and(bitShiftLeftRaw (utl_raw.substr(bytes, 5, 1), 3), get8bitMask), bitShiftRightRaw (utl_raw.substr(bytes, 6, 1), 5)) , 1, 1);
  byte7 := utl_raw.substr( utl_raw.bit_or(utl_raw.bit_and(bitShiftLeftRaw (utl_raw.substr(bytes, 6, 1), 2), get8bitMask), bitShiftRightRaw (utl_raw.substr(bytes, 7, 1), 6)) , 1, 1);
  byte8 := utl_raw.substr( utl_raw.bit_and (bitShiftLeftRaw (utl_raw.substr(bytes, 7, 1), 1), get8bitMask), 1, 1);

  returnValue := utl_raw.concat (byte1, byte2, byte3, byte4, byte5, byte6, byte7, byte8);

  return returnValue;

end createDesKey;

/* pproc: getLmHashedPasswordV1
  create LanManager (LM) hashed password
*/
function getLmHashedPasswordV1(
  password in raw
)
return raw
as

  -- http://en.wikipedia.org/wiki/LM_hash - "The DES CipherMode should be set to ECB, and PaddingMode should be set to NONE."
  algorithm                  constant pls_integer := dbms_crypto.encrypt_des + dbms_crypto.chain_ecb + dbms_crypto.pad_none;

  userPwLength               pls_integer;
  lmPassword                 raw(255);
  magicStr                   constant raw(20) := utl_raw.cast_to_raw('KGS!@#$%'); -- page 57 in [MS-NLMP]

  lowKey                     raw(8);
  highKey                    raw(8);
  lowHash                    raw(255);
  highHash                   raw(255);

  returnvalue                raw(2000);

begin

  lmPassword := password;

  userPwLength := utl_raw.length (lmPassword);

  -- pad the password length to 14 bytes
  if userPwLength < 14 then
    for i in 1..(14-userPwLength) loop
      lmPassword := utl_raw.concat(lmPassword, hextoraw('0'));
    end loop;
  end if;
  lmPassword := utl_raw.substr(lmPassword, 1, 14);

  -- do hash
  lowKey := createDesKey (utl_raw.substr(lmPassword, 1, 7));
  highKey := createDesKey (utl_raw.substr(lmPassword, 8, 7));
  lowHash := dbms_crypto.encrypt (magicStr, algorithm, lowKey);
  highHash := dbms_crypto.encrypt (magicStr, algorithm, highKey);

  returnValue := utl_raw.concat (lowHash, highHash);

  return returnValue;

end getLmHashedPasswordV1;


/* pproc: getNtHashedPasswordV1
  Get NT hashed password
*/
function getNtHashedPasswordV1(
  password in varchar2
)
return raw
as
  returnValue raw(4000);
begin
  returnValue := dbms_crypto.hash(utl_raw.cast_to_raw(convert (password, 'AL16UTF16LE')), dbms_crypto.HASH_MD4);

  return returnValue;

end getNtHashedPasswordV1;


/* pproc: getLmResponse
  get LM response
*/
function getLmResponse(
  passwordHashRaw in raw
  , serverChallengeRaw in raw
)
return raw
as
  rawValue                   raw(21);
  passwordHashLength         pls_integer;
  passwordHash               raw(21);
  serverChallenge            raw(8);

  hash1                      raw(8);
  hash2                      raw(8);
  hash3                      raw(8);

  algorithm                  constant pls_integer :=
                               dbms_crypto.encrypt_des
                             + dbms_crypto.chain_ecb
                             + dbms_crypto.pad_none;

  returnValue                raw (24);

begin
  passwordHashLength := utl_raw.length (passwordHashRaw);
  logger.trace(
    'get_response: password hash length = ' || to_char(passwordHashLength)
  );

  if passwordHashLength < 21 then
    passwordHash := utl_raw.substr(passwordHashRaw, 1, least(21, passwordHashLength));
    for i in 1..(21-passwordHashLength) loop
      passwordHash := utl_raw.concat(passwordHash, hextoraw('0'));
    end loop;
  end if;

  logger.trace(
    'new byte length = ' || to_char(utl_raw.length (passwordHash))
  );

  passwordHash := utl_raw.substr(passwordHash, 1, 21);

  serverChallenge := utl_raw.substr(serverChallengeRaw, 1, 8);

  hash1 := dbms_crypto.encrypt(serverChallenge, algorithm, createDesKey(utl_raw.substr(passwordHash, 1, 7)));
  hash2 := dbms_crypto.encrypt(serverChallenge, algorithm, createDesKey(utl_raw.substr(passwordHash, 8, 7)));
  hash3 := dbms_crypto.encrypt(serverChallenge, algorithm, createDesKey(utl_raw.substr(passwordHash, 15, 7)));

  returnValue := utl_raw.concat(hash1, hash2, hash3);

  return returnValue;

end getLmResponse;

/* pproc calcResponse2sr
  Calculate response for extended security
*/
procedure calcResponse2sr(
  passwordHash      in raw
  , serverChallenge in raw
  , ntChallenge     out raw
  , lmChallenge     out raw
)
as
  clientChallenge  raw(16);
  sess             raw(4000);
begin
  clientChallenge := hextoraw('AAAAAAAAAAAAAAAA');

  lmChallenge := utl_raw.concat (clientChallenge, hextoraw('00000000000000000000000000000000'));
  sess := dbms_crypto.hash(utl_raw.concat(serverChallenge, clientChallenge), dbms_crypto.HASH_MD5);

  ntChallenge := getLmResponse(passwordHash, utl_raw.substr(sess, 1, 8));

  logger.trace(
    'Challenge: ' || rawtohex(ntChallenge)
    || ', NT: ' || rawtohex(rawtohex(lmChallenge))
    || ', LM: = ' || rawtohex(utl_raw.concat(serverChallenge, lmChallenge))
    || ', Sess: ' || rawtohex(sess)
    || ', Client Challenge: ' ||  rawtohex(clientChallenge)
  );

end calcResponse2sr;


/* pfunc: getAuthenticateMessage
  Get authenticate (type 3) message
*/
function getAuthenticateMessage(
  userStr in varchar2
  , passwordStr in varchar2
  , domainStr in varchar2
  , serverChallengeRaw in raw
  , negotiateFlagsRaw in raw
)
return varchar2
as
  returnValue                t_max_pl_varchar2;

  bodyLength                 number;
  payloadStart               number;

  isUnicode                  boolean;
  negotiateExtSec            boolean;

  workstationStr             varchar2(500);

  protocol                   raw(16);
  workstation                raw(32);
  domain                     raw(32);
  username                   raw(32); -- was: raw(16)

  passwordHash               raw(32);
  clientChallenge            raw(8);

  typeRaw                    raw(4);
  flags                      raw(4);

  workstationLength          raw(2);
  workstationMaxLength       raw(2);
  workstationBufferOffset    raw(4);

  domainLength               raw(2);
  domainMaxLength            raw(2);
  domainBufferOffset         raw(4);

  usernameLength             raw(2);
  usernameMaxLength          raw(2);
  usernameBufferOffset       raw(4);

  lmChallengeResponse        raw(100);
  ntChallengeResponse        raw(100);
  encRandSessionKey          raw(100);

  lmChallengeLength          raw(2);
  lmChallengeMaxLength       raw(2);
  lmChallengeBufferOffset    raw(4);

  ntChallengeLength          raw(2);
  ntChallengeMaxLength       raw(2);
  ntChallengeBufferOffset    raw(4);

  encrandsesskeyLength       raw(2);
  encrandsesskeyMaxLength    raw(2);
  encrandsesskeyBufferOffset raw(4);

  productMajorVersion        raw(1);
  productMinorVersion        raw(1);
  productBuild               raw(2);

  versionReserved1           raw(1);
  versionReserved2           raw(1);
  versionReserved3           raw(1);

  ntlmRevisionCurrent        raw(1);

  returnRaw                  raw(2000);

  lmHashedPassword           raw(2000);

begin

  bodyLength := 72;
  payloadStart := bodyLength;

  workstationStr := getWorkstationName();

  logger.trace(
    'Workstation: "' || workstationStr || '"'
  );


  flags := bitOrMulti(
    m_NTLM_NegotiateUnicode
    , m_NTLM_RequestTarget
    , m_NTLM_NegotiateNTLM
    , m_NTLM_NegotiateAlwaysSign
    , m_NTLM_NegotiateExtendedSec
    , m_NTLM_NegotiateTargetInfo
    , m_NTLM_NegotiateVersion
    , m_NTLM_Negotiate128
    , m_NTLM_Negotiate56
  );

  -- need to convert flags to little endian
  flags := intToRawLittleEndian(utl_raw.cast_to_binary_integer(flags), 4);

  lmChallengeResponse := getLmResponse (getLmHashedPasswordV1(utl_raw.cast_to_raw(upper(passwordStr))), serverChallengeRaw);
  ntChallengeResponse := getLmResponse (getNtHashedPasswordV1(passwordStr), serverChallengeRaw);
  encRandSessionKey := null;

  if utl_raw.bit_and (negotiateFlagsRaw, m_NTLM_NegotiateUnicode) = m_NTLM_NegotiateUnicode then
    isUnicode := true;
  else
    isUnicode := false;
  end if;

  if utl_raw.bit_and (negotiateFlagsRaw, m_NTLM_NegotiateExtendedSec) = m_NTLM_NegotiateExtendedSec then
    negotiateExtSec := true;
  else
    negotiateExtSec := false;
  end if;

  if isUnicode then
    workstation := utl_raw.cast_to_raw(convert (workstationStr, 'AL16UTF16LE'));
    domain := utl_raw.cast_to_raw(convert (domainStr, 'AL16UTF16LE'));
    username := utl_raw.cast_to_raw(convert (userStr, 'AL16UTF16LE'));
  else
    workstation := utl_raw.cast_to_raw(workstationStr);
    domain := utl_raw.cast_to_raw(domainStr);
    username := utl_raw.cast_to_raw(userStr);
  end if;

  if negotiateExtSec then
    passwordHash := getNtHashedPasswordV1(passwordStr);
    calcResponse2sr(passwordHash, serverChallengeRaw, ntChallengeResponse, lmChallengeResponse);
  end if;

  protocol := utl_raw.cast_to_raw('NTLMSSP' || chr(0));
  typeRaw := intToRawLittleEndian(3, 4); --- Type 3

  domainLength := intToRawLittleEndian(utl_raw.length(domain), 2);
  domainMaxLength := intToRawLittleEndian(utl_raw.length(domain), 2);
  domainBufferOffset := intToRawLittleEndian(payloadStart, 4);
  payloadStart := payloadStart + utl_raw.length(domain);

  usernameLength := intToRawLittleEndian(utl_raw.length(username), 2);
  usernameMaxLength := intToRawLittleEndian(utl_raw.length(username), 2);
  usernameBufferOffset := intToRawLittleEndian(payloadStart, 4);
  payloadStart := payloadStart + utl_raw.length(username);

  workstationLength := intToRawLittleEndian(utl_raw.length(workstation), 2);
  workstationMaxLength := intToRawLittleEndian(utl_raw.length(workstation), 2);
  workstationBufferOffset := intToRawLittleEndian(payloadStart, 4);
  payloadStart := payloadStart + utl_raw.length(workstation);

  lmChallengeLength := intToRawLittleEndian(utl_raw.length(lmChallengeResponse), 2);
  lmChallengeMaxLength := intToRawLittleEndian(utl_raw.length(lmChallengeResponse), 2);
  lmChallengeBufferOffset := intToRawLittleEndian(payloadStart, 4);
  payloadStart := payloadStart + utl_raw.length(lmChallengeResponse);

  ntChallengeLength := intToRawLittleEndian(utl_raw.length(ntChallengeResponse), 2);
  ntChallengeMaxLength := intToRawLittleEndian(utl_raw.length(ntChallengeResponse), 2);
  ntChallengeBufferOffset := intToRawLittleEndian(payloadStart, 4);
  payloadStart := payloadStart + utl_raw.length(ntChallengeResponse);

  encrandsesskeyLength := intToRawLittleEndian(0, 2);
  encrandsesskeyMaxLength := intToRawLittleEndian(0, 2);
  encrandsesskeyBufferOffset := intToRawLittleEndian(payloadStart, 4);
  payloadStart := payloadStart + 0;

  productMajorVersion := intToRawLittleEndian(5, 1);
  productMinorVersion := intToRawLittleEndian(1, 1);
  productBuild := intToRawLittleEndian(2600, 2);

  versionReserved1 := intToRawLittleEndian(0, 1);
  versionReserved2 := intToRawLittleEndian(0, 1);
  versionReserved3 := intToRawLittleEndian(0, 1);

  ntlmRevisionCurrent := intToRawLittleEndian(15, 1);

  returnRaw := utl_raw.concat(protocol,
                             typeRaw,
                             lmChallengeLength,
                             lmChallengeMaxLength,
                             lmChallengeBufferOffset,
                             ntChallengeLength,
                             ntChallengeMaxLength,
                             ntChallengeBufferOffset,
                             domainLength,
                             domainMaxLength,
                             domainBufferOffset);

  returnRaw := utl_raw.concat (returnRaw,
                              usernameLength,
                              usernameMaxLength,
                              usernameBufferOffset,
                              workstationLength,
                              workstationMaxLength,
                              workstationBufferOffset,
                              encrandsesskeyLength,
                              encrandsesskeyMaxLength,
                              encrandsesskeyBufferOffset);

  returnRaw := utl_raw.concat (returnRaw,
                              flags,
                              productMajorVersion,
                              productMinorVersion,
                              productBuild,
                              versionReserved1,
                              versionReserved2,
                              versionReserved3,
                              ntlmRevisionCurrent);

  if utl_raw.length (returnRaw) <> bodyLength then
    raise_application_error (-20000, 'Length of authenticate message is ' || utl_raw.length(returnRaw) || ' (should be ' || bodyLength ||')');
  end if;

  returnRaw := utl_raw.concat (returnRaw, domain, username, workstation, lmChallengeResponse, ntChallengeResponse);

  returnValue := utl_raw.cast_to_varchar2(returnRaw);
  returnValue := strToBase64(returnValue);
  returnValue := replace(returnValue, chr(13) || chr(10), '');

  return returnValue;

end getAuthenticateMessage;


/* pfunc: ntlmLogin
  Perform NTLM authentification

  Параметры:
  requestUrl                  - URL of web service
  username                    - The username for the authentication
  password                    - The password for the HTTP authentication
  domain                      - The user domain for the authentication

  Return:
  ntlm token.

*/
function ntlmLogin(
  requestUrl                varchar2
  , username                varchar2
  , password                varchar2
  , domain                  varchar2
)
return varchar2
is
  method                      varchar2(255) := 'GET';

  req                         utl_http.req;
  resp                        utl_http.resp;
  responseBody                clob;

  returnValue                 varchar2(2000);

  name                        varchar2(500);
  value                       varchar2(500);

  ntlmMessage                 varchar2(500);
  negotiateMessage            varchar2(500);
  serverChallenge             raw(4000);
  negotiateFlags              raw(4000);
  authenticateMessage         varchar2(500);

  function getResponseBody(
    resp in out utl_http.resp
  )
  return clob
  is
    data        t_max_pl_varchar2;
    returnValue clob;
  begin
    begin
      loop
        utl_http.read_text(r => resp, data => data);
        returnValue := returnValue || data;
      end loop;
    exception
      when utl_http.end_of_body then
        null;
    end;

    return returnValue;

  end getResponseBody;

-- ntlmLogin
begin
  logger.trace(
    'NTLM аутентификации('
    || 'requestUrl="' || requestUrl || '"'
    || ', username="' || username || '"'
    || ', password="' || password || '"'
    || ', domain="' || domain || '"'
    || ').'
  );

  utl_http.set_detailed_excp_support (enable => true);
  utl_http.set_response_error_check (enable => false);

  utl_http.set_persistent_conn_support (true, 10);

  negotiateMessage := 'NTLM ' || getNegotiateMessage (domain, username);

  logger.trace(
    'Negotiate Message: "' || negotiateMessage || '"'
  );

  -- Request 1
  req :=  utl_http.begin_request (requestUrl, method);
  utl_http.set_header (req, 'Authorization', negotiateMessage);

  resp := utl_http.get_response(req);

  responseBody := getResponseBody (resp);

  if resp.status_code = utl_http.http_unauthorized then
    -- received server challenge
    utl_http.get_header_by_name (resp, 'WWW-Authenticate', value, 1);
    utl_http.end_response (resp);

    if substr(value, 1, 4) = 'NTLM' then
      value := substr(value, 6);
      parseChallengeMessage(value, serverChallenge, negotiateFlags);
      authenticateMessage := 'NTLM '
        || getAuthenticateMessage(
             username
             , password
             , domain
             , serverChallenge
             , negotiateFlags
           );
        logger.trace(
          'Authenticate Message: "' || authenticateMessage || '"'
        );

      -- this is what needs to be passed as the Authorization header in the next call
      -- (and TCP connection must be kept persistent)
      returnValue := authenticateMessage;
    end if;
  else
    utl_http.end_response (resp);
    returnValue := null;
  end if;

  return returnValue;

end ntlmLogin;

procedure ntlmLogoff
as
begin
  utl_http.close_persistent_conns;
  logger.trace(
    'Persistent connection count (should be zero): ' || utl_http.get_persistent_conn_count
  );
end ntlmLogoff;

end pkg_WebUtilityNtlm;
/
