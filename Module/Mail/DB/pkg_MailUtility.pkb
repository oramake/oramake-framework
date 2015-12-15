create or replace package body pkg_MailUtility is
/* package body: pkg_MailUtility::body */

/* itype: TUrlString
  ��� ��� ������ � URL.
*/
subtype TUrlString is varchar2(1000);

/* ivar: logger
  ������������ ������ � ������ Logging
*/
  logger lg_logger_t := lg_logger_t.GetLogger(
    moduleName => pkg_Mail.Module_Name
    , objectName => 'pkg_MailUtility'
  );

/* ivar: deleteErrorMessageUid
  ������������� ��������� ��� �������� �� �����
*/
  deleteErrorMessageUid ml_message.message_uid%type := null;

/* func: ChangeUrlPasswordJava
  ���������� URL � ���������� �������.
*/
function ChangeUrlPasswordJava(
  url varchar2
  , newPassword varchar2
)
return varchar2
is
language java name '
Mail.changeUrlPassword(
  java.lang.String
  , java.lang.String
)
return java.lang.String
';
/* func: ChangeUrlPassword
  ���������� URL � ���������� �������.

  ���������:
  url                         - URL ��������� ����� � URL-encoded �������
                                ( pop3://user:passwd@server.domen)
  newPassword                 - ����� ������
*/
function ChangeUrlPassword(
  url varchar2
  , newPassword varchar2
)
return varchar2
is

--ChangeUrlPassword
begin
  return
    ChangeUrlPasswordJava(
      url           => url
      , newPassword => newPassword
    )
  ;
end ChangeUrlPassword;
/* func: GetAddressJava
  ���������� ��������������� �������� �����.
*/
function GetAddressJava(
  addressText varchar2
)
return varchar2
is
language java name '
Mail.getAddress(
  java.lang.String
)
return java.lang.String
';
/* func: GetAddress
  ���������� ��������������� �������� �����.
  ��� ������� ���������� �������, ������������ ������ �� ���.

  ���������:
  addressText                 - ����� ������
*/
function GetAddress(
  addressText varchar2
)
return varchar2
is

--GetAddress
begin
  return GetAddressJava( addressText);
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( '������ ��� ��������� ���������������� ��������� ������ ('
      || ' address_text="' || addressText || '"'
      || ').' )
    , true
  );
end GetAddress;
/* func: GetMailboxAddressJava
  ���������� ����� ��������� ����� �� URL.
*/
function GetMailboxAddressJava(
  url varchar2
)
return varchar2
is
language java name '
Mail.getMailboxAddress(
  java.lang.String
)
return java.lang.String
';
/* func: GetMailboxAddress
  ���������� ����� ��������� ����� �� URL ( � ������ ������������� - �����������
  ����������).

  ���������:
  url                         - URL ��������� ����� � URL-encoded �������
                                ( pop3://user:passwd@server.domen)
*/
function GetMailboxAddress(
  url varchar2
)
return varchar2
is

  mailboxAddress ml_message.recipient_address%type;
                                        --URL � ��������� �������
  clearUrl TUrlString;

--GetMailboxAddress
begin
  clearUrl := ChangeUrlPassword( url, null);
  mailboxAddress := GetMailboxAddressJava( url);
  if mailboxAddress is null then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '�� ������� ���������� �����.'
    );
  end if;
  return mailboxAddress;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( '������ ��� ����������� ������ ��������� ����� �� URL'
      || case when clearUrl is not null then
          ' "' || clearUrl || '"'
        end
      || '.' )
    , true
  );
end GetMailboxAddress;
/* func: GetEncodedAddressListJava
  ���������� ������������ ������ �������
  ( ������� ��� <Mail.getEncodedAddressList>).
*/
function GetEncodedAddressListJava(
  textAddressList varchar2
)
return varchar2
is
language java name '
Mail.getEncodedAddressList(
  java.lang.String
)
return java.lang.String
';
/* func: GetEncodedAddressList
  ���������� ������������ ������ �������.

  ���������:
  textAddressList             - ����� ������ ( ����� ������ � ������������ ","
                                ��� ";")
*/
function GetEncodedAddressList(
  textAddressList varchar2
)
return varchar2
is

--GetEncodedAddressList
begin
  return GetEncodedAddressListJava( textAddressList);
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( '������ ��� ��������� ������������� ������ ������� ('
      || ' textAddressList="' || textAddressList || '"'
      || ').' )
    , true
  );
end GetEncodedAddressList;
/* func: GetTextAddressListJava
  ���������� ��������� ������ �������
  ( ������� ��� <Mail.getTextAddressList>).
*/
function GetTextAddressListJava(
  addressList varchar2
)
return varchar2
is
language java name '
Mail.getTextAddressList(
  java.lang.String
)
return java.lang.String
';
/* func: GetTextAddressList
  ���������� ��������� ������ �������.

  ���������:
  addressList             - ������ �������
*/
function GetTextAddressList(
  addressList varchar2
)
return varchar2
is

--GetTextAddressList
begin
  return GetTextAddressListJava( addressList);
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( '������ ��� ��������� ���������� ������ ������� ('
      || ' addressList="' || addressList || '"'
      || ').' )
    , true
  );
end GetTextAddressList;

/* proc: SetDeleteErrorMessageUid
  ��������� �������� �������������� ���������,
  ������� ����� ������� �� ����� � ������ ������
  ��������� � ������ ������ (��. <pkg_Mail.FetchMessageImmediate>)
  ��� null, ��������� ��������� ������ ��� ���������.

  ���������:
    messageUid               - �������� ��������������
                               ��������� ��� ��������
*/
procedure SetDeleteErrorMessageUid(
  messageUid varchar2
)
is
begin
  pkg_MailUtility.deleteErrorMessageUid :=
    SetDeleteErrorMessageUid.messageUid;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack(
        '������ ��������� �������������� ��������� ��� ��������'
      )
    , true
  );
end SetDeleteErrorMessageUid;

/* func: GetDeleteErrorMessageUid
  ��������� �������������� �������������� ���������,
  ������� ����� ������� �� ����� � ������ ������
  ��������� � ������ ������ (��. <pkg_Mail.FetchMessageImmediate>)

  �������:
    - �������� �������������� ��������� ��� ��������
*/
function GetDeleteErrorMessageUid
return varchar2
is
begin
  return
    deleteErrorMessageUid;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack(
        '������ ��������� �������������� ��������� ��� ��������'
      )
    , true
  );
end GetDeleteErrorMessageUid;


/* func: isEmailValid
   ��������� �������� ������������ ������ ����������� �����

   ���������:
     emailAddress                   - ����� ����������� �����

   �������:
     - ���� ����� email ���������, �� 1, ����� 0
*/
function isEmailValid (
  emailAddress in varchar2
  )
return integer
is
  -- ����� ������ ������
  Email_GeneralFormat constant varchar2(100) := '^(.*)@(.*)$';
  -- ������������ ����� ������
  Email_MaxLength constant pls_integer := 254;
  -- ������ ��������� ����� ������
  Email_LocalPartFormat constant varchar2(100) :=
      '^[[:alnum:]!#\$%&''\*\+\/=\?\^_`\.\{\|\}~-]+$'
  ;
  -- ������������ ����� ��������� ����� ������
  Email_LocalPartLength constant pls_integer := 64;
  -- ������ �������� ����� ������
  Email_DomainPartFormat constant varchar2(100) :=
      '^[[:alnum:]-\.]+$'
  ;
  -- ������������ ����� �������� ����� ������
  Email_DomainPartLength constant pls_integer := 253;
  -- ������ ����� ������, ��� ������� ���� ����� ���������� ������������
  Email_IllegalPartFormat constant varchar2(100) := '(^\.)|(\.$)|([\.]{2,})';

  -- ��������� ����� ������
  localPart varchar2(255);
  -- �������� ����� ������
  domainPart varchar2(255);


  /*
    ��������� ����� �� ��������� � �������� �����
  */
  procedure splitAddress (
      emailAddress     in varchar2
    , localPart        out varchar2
    , domainPart       out varchar2
    )
  is
  -- splitAddress
  begin
    localPart  := regexp_substr( emailAddress, Email_GeneralFormat, 1, 1, 'i', 1 );
    domainPart := regexp_substr( emailAddress, Email_GeneralFormat, 1, 1, 'i', 2 );

  end splitAddress;


  /*
    ��������� ����� ������
  */
  function checkLength (
    emailAddress in varchar2
    )
  return boolean
  is
  -- checkLength
  begin
    if length( emailAddress ) between 3 and Email_MaxLength then
      return true;
    else
      return false;
    end if;

  end checkLength;


  /*
     ��������� ��������� ����� ������
  */
  function checkLocalPart (
    localPart in varchar2
    )
  return boolean
  is
  -- checkLocalPart
  begin
    if length( localPart ) between 1 and Email_LocalPartLength then
      return regexp_like( localPart, Email_LocalPartFormat )
         and not regexp_like( localPart, Email_IllegalPartFormat )
      ;
    else
      return false;
    end if;

  end checkLocalPart;


  /*
     ��������� �������� ����� ������
  */
  function checkDomainPart (
    domainPart in varchar2
    )
  return boolean
  is
  -- checkDomainPart
  begin
    if length( domainPart ) between 1 and Email_DomainPartLength then
      return regexp_like( domainPart, Email_DomainPartFormat )
         and not regexp_like( domainPart, Email_IllegalPartFormat )
      ;
    else
      return false;
    end if;

  end checkDomainPart;


-- isEmailValid
begin
  -- ��������� ����� �� ��������� � �������� �����
  splitAddress(
      emailAddress => emailAddress
    , localPart    => localPart
    , domainPart   => domainPart
    );

  -- �������� ������ ������
  if (
         checkLength( emailAddress )
     and checkLocalPart( localPart )
     and checkDomainPart( domainPart )
     )
  then
    return 1;
  else
    return 0;
  end if;

end isEmailValid;


end pkg_MailUtility;
/
