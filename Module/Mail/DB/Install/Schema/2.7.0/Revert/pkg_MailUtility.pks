create or replace package pkg_MailUtility is
/* package: pkg_MailUtility
  ��������������� ������� ������ Mail.
*/



/* group: ������� */

/* pfunc: changeUrlPassword
  ���������� URL � ���������� �������.

  ���������:
  url                         - URL ��������� ����� � URL-encoded �������
                                ( pop3://user:passwd@server.domen)
  newPassword                 - ����� ������

  ( <body::changeUrlPassword>)
*/
function changeUrlPassword(
  url varchar2
  , newPassword varchar2
)
return varchar2;

/* pfunc: getAddress
  ���������� ��������������� �������� �����.
  ��� ������� ���������� �������, ������������ ������ �� ���.

  ���������:
  addressText                 - ����� ������

  ( <body::getAddress>)
*/
function getAddress(
  addressText varchar2
)
return varchar2;

/* pfunc: getMailboxAddress
  ���������� ����� ��������� ����� �� URL ( � ������ ������������� -
  ����������� ����������).

  ���������:
  url                         - URL ��������� ����� � URL-encoded �������
                                ( pop3://user:passwd@server.domen)

  ( <body::getMailboxAddress>)
*/
function getMailboxAddress(
  url varchar2
)
return varchar2;

/* pfunc: getEncodedAddressList
  ���������� ������������ ������ �������.

  ���������:
  textAddressList             - ����� ������ ( ����� ������ � ������������ ","
                                ��� ";")

  ( <body::getEncodedAddressList>)
*/
function getEncodedAddressList(
  textAddressList varchar2
)
return varchar2;

/* pfunc: getTextAddressList
  ���������� ��������� ������ �������.

  ���������:
  addressList                 - ������ �������

  ( <body::getTextAddressList>)
*/
function getTextAddressList(
  addressList varchar2
)
return varchar2;

/* pproc: setDeleteErrorMessageUid
  ��������� �������� �������������� ���������,
  ������� ����� ������� �� ����� � ������ ������
  ��������� � ������ ������ (��. <pkg_MailHandler.fetchMessageImmediate>)
  ��� null, ��������� ��������� ������ ��� ���������.

  ���������:
  messageUid                  - �������� �������������� ��������� ��� ��������

  ( <body::setDeleteErrorMessageUid>)
*/
procedure setDeleteErrorMessageUid(
  messageUid varchar2
);

/* pfunc: getDeleteErrorMessageUid
  ��������� �������������� �������������� ���������,
  ������� ����� ������� �� ����� � ������ ������
  ��������� � ������ ������ (��. <pkg_MailHandler.fetchMessageImmediate>)

  �������:
  �������� �������������� ��������� ��� ��������.

  ( <body::getDeleteErrorMessageUid>)
*/
function getDeleteErrorMessageUid
return varchar2;

/* pfunc: isEmailValid
   ��������� �������� ������������ ������ ����������� �����

   ���������:
     emailAddress                   - ����� ����������� �����

   �������:
     - ���� ����� email ���������, �� 1, ����� 0

  ( <body::isEmailValid>)
*/
function isEmailValid (
  emailAddress in varchar2
  )
return integer;

end pkg_MailUtility;
/
