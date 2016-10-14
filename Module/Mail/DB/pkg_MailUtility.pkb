create or replace package body pkg_MailUtility is
/* package body: pkg_MailUtility::body */



/* group: ���� */

/* itype: TUrlString
  ��� ��� ������ � URL.
*/
subtype TUrlString is varchar2(1000);



/* group: ���������� */

/* ivar: logger
  ������������ ������ � ������ Logging
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName => pkg_Mail.Module_Name
  , objectName => 'pkg_MailUtility'
);

/* ivar: deleteErrorMessageUid
  ������������� ��������� ��� �������� �� �����
*/
deleteErrorMessageUid ml_message.message_uid%type := null;



/* group: ������� */

/* ifunc: changeUrlPasswordJava
  ���������� URL � ���������� �������.
*/
function changeUrlPasswordJava(
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

/* func: changeUrlPassword
  ���������� URL � ���������� �������.

  ���������:
  url                         - URL ��������� ����� � URL-encoded �������
                                ( pop3://user:passwd@server.domen)
  newPassword                 - ����� ������
*/
function changeUrlPassword(
  url varchar2
  , newPassword varchar2
)
return varchar2
is
begin
  return
    changeUrlPasswordJava(
      url           => url
      , newPassword => newPassword
    )
  ;
end changeUrlPassword;

/* ifunc: getAddressJava
  ���������� ��������������� �������� �����.
*/
function getAddressJava(
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

/* func: getAddress
  ���������� ��������������� �������� �����.
  ��� ������� ���������� �������, ������������ ������ �� ���.

  ���������:
  addressText                 - ����� ������
*/
function getAddress(
  addressText varchar2
)
return varchar2
is
begin
  return getAddressJava( addressText);
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ��������� ���������������� ��������� ������ ('
        || ' address_text="' || addressText || '"'
        || ').'
      )
    , true
  );
end getAddress;

/* ifunc: getMailboxAddressJava
  ���������� ����� ��������� ����� �� URL.
*/
function getMailboxAddressJava(
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

/* func: getMailboxAddress
  ���������� ����� ��������� ����� �� URL ( � ������ ������������� -
  ����������� ����������).

  ���������:
  url                         - URL ��������� ����� � URL-encoded �������
                                ( pop3://user:passwd@server.domen)
*/
function getMailboxAddress(
  url varchar2
)
return varchar2
is

  mailboxAddress ml_message.recipient_address%type;

  -- URL � ��������� �������
  clearUrl TUrlString;

begin
  clearUrl := changeUrlPassword( url, null);
  mailboxAddress := getMailboxAddressJava( url);
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
    , logger.errorStack(
        '������ ��� ����������� ������ ��������� ����� �� URL'
        || case when clearUrl is not null then
            ' "' || clearUrl || '"'
          end
        || '.'
      )
    , true
  );
end getMailboxAddress;

/* ifunc: getEncodedAddressListJava
  ���������� ������������ ������ �������
  ( ������� ��� <Mail.getEncodedAddressList>).
*/
function getEncodedAddressListJava(
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

/* func: getEncodedAddressList
  ���������� ������������ ������ �������.

  ���������:
  textAddressList             - ����� ������ ( ����� ������ � ������������ ","
                                ��� ";")
*/
function getEncodedAddressList(
  textAddressList varchar2
)
return varchar2
is
begin
  return getEncodedAddressListJava( textAddressList);
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ��������� ������������� ������ ������� ('
        || ' textAddressList="' || textAddressList || '"'
        || ').'
      )
    , true
  );
end getEncodedAddressList;

/* ifunc: getTextAddressListJava
  ���������� ��������� ������ �������
  ( ������� ��� <Mail.getTextAddressList>).
*/
function getTextAddressListJava(
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

/* func: getTextAddressList
  ���������� ��������� ������ �������.

  ���������:
  addressList                 - ������ �������
*/
function getTextAddressList(
  addressList varchar2
)
return varchar2
is
begin
  return getTextAddressListJava( addressList);
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ��������� ���������� ������ ������� ('
        || ' addressList="' || addressList || '"'
        || ').'
      )
    , true
  );
end getTextAddressList;

/* proc: setDeleteErrorMessageUid
  ��������� �������� �������������� ���������,
  ������� ����� ������� �� ����� � ������ ������
  ��������� � ������ ������ (��. <pkg_Mail.fetchMessageImmediate>)
  ��� null, ��������� ��������� ������ ��� ���������.

  ���������:
  messageUid                  - �������� �������������� ��������� ��� ��������
*/
procedure setDeleteErrorMessageUid(
  messageUid varchar2
)
is
begin
  pkg_MailUtility.deleteErrorMessageUid :=
    setDeleteErrorMessageUid.messageUid;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��������� �������������� ��������� ��� ��������.'
      )
    , true
  );
end setDeleteErrorMessageUid;

/* func: getDeleteErrorMessageUid
  ��������� �������������� �������������� ���������,
  ������� ����� ������� �� ����� � ������ ������
  ��������� � ������ ������ (��. <pkg_Mail.fetchMessageImmediate>)

  �������:
  �������� �������������� ��������� ��� ��������.
*/
function getDeleteErrorMessageUid
return varchar2
is
begin
  return
    deleteErrorMessageUid;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��������� �������������� ��������� ��� ��������'
      )
    , true
  );
end getDeleteErrorMessageUid;

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
