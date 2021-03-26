create or replace package pkg_MailBase is
/* package: pkg_MailBase
  ������� ����� ������ Mail.

  SVN root: Oracle/Module/Mail
*/



/* group: ���� */

/* type: SmtpConfigT
  ��������� SMTP-������� (���)
*/
type SmtpConfigT is record (
  smtp_server ml_message.smtp_server%type
  , username varchar2(100)
  , password varchar2(100)
  , default_flag number(1)
);

/* type: SmtpConfigListT
  ������ �������� SMTP-�������� (���, ��������� ��������� ���� <SmtpConfigT>)
*/
type SmtpConfigListT is table of SmtpConfigT;



/* group: ��������� */

/* const: Module_Name
  �������� ������, � �������� ��������� �����
*/
Module_Name constant varchar2(30) := 'Mail';

/* const: Module_SvnRoot
  ���� � ��������� �������� ������ � Subversion
*/
Module_SvnRoot constant varchar2(100) := 'Oracle/Module/Mail';



/* group: ����������� ��������� */

/* const: DefaultSmtpServer_OptSName
  ������� ������������ ���������
  "SMTP-������ �� ��������� ��� �������� �����".
*/
DefaultSmtpServer_OptSName constant varchar2(50) := 'DefaultSmtpServer';

/* const: DefaultSmtpUsername_OptSName
  ������� ������������ ���������
  "��� ������������ ��� ����������� �� SMTP-������� �� ���������"
*/
DefaultSmtpUsername_OptSName constant varchar2(50) := 'DefaultSmtpUsername';

/* const: DefaultSmtpPassword_OptSName
  ������� ������������ ���������
  "������ ��� ����������� �� SMTP-������� �� ���������"
*/
DefaultSmtpPassword_OptSName constant varchar2(50) := 'DefaultSmtpPassword';



/* group: ������� */

/* pfunc: getDefaultSmtpConfig
  ���������� ��������� SMTP-������� �� ���������.

  ���������:
  getAuthParamsFlag           - ���������� ��������� �����������
                                (��� ������������ � ������)
                                (1 �� (�� ���������), 0 ���)

  �������:
  ��������� (��� <SmtpConfigT>)

  ( <body::getDefaultSmtpConfig>)
*/
function getDefaultSmtpConfig(
  getAuthParamsFlag integer := null
)
return SmtpConfigT;

/* pfunc: getDefaultSmtpServer
  ���������� SMTP-������ �� ���������.

  ( <body::getDefaultSmtpServer>)
*/
function getDefaultSmtpServer
return varchar2;

/* pfunc: parseSmtpServerList
  ��������� ������ �� ������� ������� SMTP-��������.

  smtpServerList              - ������ ��� (��� ip-�������) SMTP-��������
                                ����� ",". ������ ������ ������ �������������
                                SMTP-������ �� ���������.

  �������:
  ������ �������� SMTP-�������� (��� <SmtpConfigListT>)

  ( <body::parseSmtpServerList>)
*/
function parseSmtpServerList(
  smtpServerList varchar2
)
return SmtpConfigListT;

end pkg_MailBase;
/
