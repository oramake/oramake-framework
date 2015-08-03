create or replace package pkg_Common is
/* package: pkg_Common
  ������������ ����� ������ Common.
  �������� ������������������� ������� ���������� ����������.
*/



/* group: ��������� */

/* const: Module_Name
  �������� ������, � �������� ��������� �����.
*/
Module_Name constant varchar2(30) := 'Common';

/* const: LastName_TypeExceptionCode
  ��� ���� ���������� "�������".
*/
LastName_TypeExceptionCode constant varchar2(1) := 'L';

/* const: FirstName_TypeExceptionCode
  ��� ���� ���������� "���".
*/
FirstName_TypeExceptionCode constant varchar2(1) := 'F';

/* const: MiddleName_TypeExceptionCode
  ��� ���� ���������� "��������".
*/
MiddleName_TypeExceptionCode constant varchar2(1) := 'M';

/* const: Native_CaseCode
  ��� ������������� ������.
*/
Native_CaseCode constant varchar2(10) := 'NAT';

/* const: Genetive_CaseCode
  ��� ������������ ������.
*/
Genetive_CaseCode constant varchar2(10) := 'GEN';

/* const: Dative_CaseCode
  ��� ���������� ������.
*/
Dative_CaseCode constant varchar2(10) := 'DAT';

/* const: Accusative_CaseCode
  ��� ������������ ������.
*/
Accusative_CaseCode constant varchar2(10) := 'ACC';

/* const: Ablative_CaseCode
  ��� ������������� ������.
*/
Ablative_CaseCode constant varchar2(10) := 'ABL';

/* const: Preposition_CaseCode
  ��� ����������� ������.
*/
Preposition_CaseCode constant varchar2(10) := 'PREP';

/* const: Men_Code
  ��� �������� ����.
*/
Men_SexCode constant varchar2(10) := 'M';

/* const: Women_Code
  ��� �������� ����.
*/
Women_SexCode constant varchar2(10) := 'W';

/* group: ������� */



/* group: ��������� ������ */

/* pfunc: getInstanceName
  ���������� ��� ������� ����.

  ( <body::getInstanceName>)
*/
function getInstanceName
return varchar2;

/* pfunc: getSessionSid
  ���������� SID ������� ������.

  ( <body::getSessionSid>)
*/
function getSessionSid
return number;

/* pfunc: getSessionSerial
  ���������� serial# ������� ������.

  ( <body::getSessionSerial>)
*/
function getSessionSerial
return number;

/* pfunc: getIpAddress
  ���������� IP ����� �������� ������� ��.

  ���������:
  - ��� ��������� ���������� ������� � Oracle 11 � ���� ����� �������������� �����;

  ( <body::getIpAddress>)
*/
function getIpAddress
return varchar2;



/* group: ��������� �� */

/* pfunc: isProduction
  ���������� 1, ���� ������� ����������� � ������������ ����, � ������ �������
  ���������� 0.

  ( <body::isProduction>)
*/
function isProduction
return integer;



/* group: ����������� �� e-mail */

/* pfunc: getSmtpServer
  ���������� ��� ( ��� IP-�����) ���������� SMTP-�������.

  ( <body::getSmtpServer>)
*/
function getSmtpServer
return varchar2;

/* pfunc: getMailAddressSource
  ��������� ��������� �������� ����� ��� �������� ���������.

  ���������:
  systemName                  - �������� ������� ��� ������, ������������
                                ��������� ( ��������, "Scheduler",
                                "DataGateway")

  ( <body::getMailAddressSource>)
*/
function getMailAddressSource(
  systemName varchar2 := null
)
return varchar2;

/* pfunc: getMailAddressDestination
  ���������� ������� �������� ����� ��� �������� ���������.

  ( <body::getMailAddressDestination>)
*/
function getMailAddressDestination
return varchar2;

/* pproc: sendMail
  ���������� ������ �� e-mail.

  ���������:
  mailSender                  - ����� �����������
  mailRecipient               - ����� ����������
  subject                     - ���� ������
  message                     - ����� ������
  smtpServer                  - SMTP-������ ��� �������� ������ ( �� ���������
                                ������������ ������, ������������ ��������
                                <getSmtpServer>)

  ( <body::sendMail>)
*/
procedure sendMail(
  mailSender varchar2
  , mailRecipient varchar2
  , subject varchar2
  , message varchar2
  , smtpServer varchar2 := null
);



/* group: �������� ���������� �������� */

/* pproc: startSessionLongops
  ��������� � ������������� v$session_longops ������ ��� ��������� �������������
  ��������.

  ���������:
  operationName               - �������� ����������� ��������
  units                       - ������� ��������� ������ ������
  target                      - ID �������, ��� ������� ����������� ��������
  targetDesc                  - �������� �������, ��� ������� �����������
                                �������
  sofar                       - ����� ����������� �����
  totalWork                   - ����� ����� ������
  contextValue                - �������� ��������, ����������� � ��������
                                ���������

  ( <body::startSessionLongops>)
*/
procedure startSessionLongops(
  operationName varchar2
  , units varchar2 := null
  , target binary_integer := 0
  , targetDesc varchar2 := 'unknown target'
  , sofar number := 0
  , totalWork number := 0
  , contextValue binary_integer := 0
);

/* pproc: setSessionLongops
  ������������ ��������� �������� ���������� ������� ��������.

  ���������:
  sofar                       - ����� ����������� �����
  totalWork                   - ����� ����� ������
  contextValue                - �������� ��������, ����������� � ��������
                                ���������

  ( <body::setSessionLongops>)
*/
procedure setSessionLongops(
  sofar number
  , totalwork number
  , contextvalue binary_integer
);



/* group: ������� �������������� */

/* pfunc: transliterate
  Transliterate Russian source text into Latin.

  Parameters:
  source                      - Russian source text.

  ( <body::transliterate>)
*/
function transliterate(
  source in varchar2
)
return string;

/* pfunc: numberToWord
  ��������������� ����� ������ � ����� ��������.
  ����������� �����: ���� ������.
  ������������ �����: �������� ������ ����� ���� ������� (999999999999.99)
  ���� ����� �� ����� ���� ������������� � ������, ������� ���������� ������
  '############################################## ������'

  ��������:
  source                      - ����� ������

  ( <body::numberToWord>)
*/
function numberToWord(
  source number
)
return varchar2;

/* pfunc: getStringByDelimiter
  ������� ������ ����� ������ �� ������� � �����������.

  ���������:
  initString                  - ������, � ������� �������������� �����
  delimiter                   - �����������
  position                    - ����� ��������� ( ������� � 1)

  ( <body::getStringByDelimiter>)
*/
function getStringByDelimiter(
  initString varchar2
  , delimiter varchar2
  , position integer := 1
)
return varchar2;

/* pfunc: split
  ������� ��������� ������ �� ��������� ����������� � ����������� � �������
  ��� ��������� � ������������� � ��������.

  ���������:
  initString                  - ������� ������ ��� �������
  delimiter                   - ����������� ( �� ��������� ',')

  ������������ ��������:
  nested table �� ���������� ��������������� ������.

  ������ �������������:

  (code)

  select column_value as result from table( pkg_Common.split( '1,4,3,23', ','));

  (end)


  ( <body::split>)
*/
function split(
  initString varchar2
  , delimiter varchar2 := ','
)
return cmn_string_table_t
pipelined;

/* pfunc: split( CLOB)
  ������������� ������� ��������� ������ �� ��������� ����������� �
  ����������� � ������� ��� ��������� � ������������� � ��������.
  ������� ���������� ������� <split>, �� ������������ ������� ������ ���� CLOB.

  ���������:
  initClob                    - ������� ������ ��� �������
  delimiter                   - �����������

  ������������ ��������:
  nested table �� ���������� ��������������� ������.

  ( <body::split( CLOB)>)
*/
function split(
  initClob clob
  , delimiter varchar2 := ','
)
return cmn_string_table_t
pipelined;



/* group: ������� */

/* pproc: outputMessage
  ������� ��������� ��������� ����� dbms_output.
  ������ ���������, ����� ������� ������ 255 ��������, ��� ������ �������������
  ����������� �� ������ ����������� ������� ( � ����� ������������ �� �����
  ������ � ��������� dbms_output.put_line).

  ���������:
  messageText                 - ����� ���������

  ���������:
  - �������� ��� ������ ������� ������� ����� ��������� �� �����������
    ������������ �� ������� ����� ������ ( 0x0A) ���� ����� ��������;

  ( <body::outputMessage>)
*/
procedure outputMessage(
  messageText varchar2
);


/* group: ������� ��� ������ �� ���������� ��� �� ������� */

/* pproc: updateExceptionCase
  ��������� ����������/���������� ������ � ����������� ����������.

  ������� ���������:
    exceptionCaseId             - �� ������ ����������
    stringException             - ������ ����������
    stringNativeCase            - ������ ���������� � ������������ ������
    stringConvertInCase         - ������, ���������� ���������� ��������
                                  convertNameOnCase
    formatString                - ������ ������ ��� �������������� (
                                  "L"- ������ �������� �������
                                  , "F"- ������ �������� ���
                                  , "M" - ������ �������� ��������)
                                  , ���� �������� null, �� �������,
                                  ��� ������ ������ "LFM"
    sexCode                     - ��� (M � �������, W - �������)
    caseCode                    - ��� ������ (NAT � ������������
                                  , GEN - �����������
                                  , DAT - ���������, ACC � �����������
                                  , ABL - ������������, PREP - ����������)
    operatorId                  - �� ���������

  �������� ��������� �����������.

  ( <body::updateExceptionCase>)
*/
procedure updateExceptionCase(
  exceptionCaseId integer default null
  , stringException varchar2
  , stringNativeCase varchar2
  , stringConvertInCase varchar2
  , formatString varchar2
  , sexCode varchar2 default null
  , caseCode varchar2
  , operatorId integer
);

/* pfunc: convertNameInCase
  ������� �������������� ��� � ���������� ������. ������� ����
  � ������� � � ���������� ������ ������ ���������. ������� �������
  ������ ���������� ���� �� ����� ������ "-", ��� ���� ���������� �������� ��
  � ����� ����� �� �����.


  ������� ���������:
    nameText                    - ������ ��� ��������������
    formatString                - ������ ������ ��� ��������������
    caseCode                    - ��� ������ ��������������
    sexCode                     - ���

  �������:
    ������ � ��������� ������.

  ( <body::convertNameInCase>)
*/
function convertNameInCase(
  nameText varchar2
  , formatString varchar2
  , caseCode varchar2
  , sexCode varchar2 default null
)
return varchar2;

end pkg_Common;
/
