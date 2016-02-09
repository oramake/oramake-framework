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



/* group: ������� */



/* group: ��������� ������ */

/* pfunc: getInstanceName
  ���������� ��� ������� ���� ( �������� ��������� INSTANCE_NAME).

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

  ���������:
  - ��� ���������� ������ ��� ���������� ���� �� v$session ������� ������������
    ����� ������������ SQL ( � ������ ���������� ���� ����� ��������� ������
    ��� ���������� �������);

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

end pkg_Common;
/
