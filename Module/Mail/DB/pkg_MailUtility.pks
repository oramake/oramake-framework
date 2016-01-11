create or replace package pkg_MailUtility is
/* package: pkg_MailUtility
  ��������������� ������� ������ Mail.
*/

/* pfunc: ChangeUrlPassword
  ���������� URL � ���������� �������
  ( <body::ChangeUrlPassword>).
*/
function ChangeUrlPassword(
  url varchar2
  , newPassword varchar2
)
return varchar2;
/* pfunc: GetAddress
  ���������� ��������������� �������� ����� ( <body::GetAddress>).
*/
function GetAddress(
  addressText varchar2
)
return varchar2;
/* pfunc: GetMailboxAddress
  ���������� ����� ��������� ����� �� URL ( <body::GetMailboxAddress>).
*/
function GetMailboxAddress(
  url varchar2
)
return varchar2;
/* pfunc: GetEncodedAddressList
  ���������� ������������ ������ �������
  ( <body::GetEncodedAddressList>).
*/
function GetEncodedAddressList(
  textAddressList varchar2
)
return varchar2;
/* pfunc: GetTextAddressList
  ���������� ��������� ������ �������
  ( <body::GetTextAddressList>).
*/
function GetTextAddressList(
  addressList varchar2
)
return varchar2;

/* pproc: SetDeleteErrorMessageUid
  ��������� �������� �������������� ���������,
  ������� ����� ������� �� ����� � ������ ������
  ��������� � ������ ������ (��. <pkg_Mail.FetchMessageImmediate>)
  ( <body::SetDeleteErrorMessageUid>)
*/
procedure SetDeleteErrorMessageUid(
  messageUid varchar2
);

/* pfunc: GetDeleteErrorMessageUid
  ��������� �������������� �������������� ���������,
  ������� ����� ������� �� ����� � ������ ������
  ��������� � ������ ������ (��. <pkg_Mail.FetchMessageImmediate>)
  ( <body::GetDeleteErrorMessageUid>)
*/
function GetDeleteErrorMessageUid
return varchar2;


/* pfunc: isEmailValid
   ��������� �������� ������������ ������ ����������� �����

   ���������:
     emailAddress                   - ����� ����������� �����

   �������:
     - ���� ����� email ���������, �� 1, ����� 0

   (<body::isEmailValid>)
*/
function isEmailValid (
  emailAddress in varchar2
  )
return integer;


end pkg_MailUtility;
/
