-- script: Test/Data/opt_option.sql
-- ������� ��� ������ �������� ���������� ������������, ������������� �
-- <pkg_MailTest::��������� ������������>.
--
-- ���������:
-- - ��������������� �������� ������� �� ����������� ���������� SQL*Plus,
--  ������� ����� ���� ������ � ������� <SQL_DEFINE>.
--


-- ������������ ���������������
@oms-default TestSender ""
@oms-default TestRecipient ""
@oms-default TestSmtpServer ""
@oms-default TestSmtpUsername ""
@oms-default TestSmtpPassword ""
@oms-default TestFetchUrl ""
@oms-default TestFetchPassword ""
@oms-default TestFetchSendAddress ""



declare

  opt opt_plsql_object_option_t :=
    opt_plsql_object_option_t(
      moduleName      => pkg_MailBase.Module_Name
      , objectName    => 'pkg_MailTest'
    )
  ;



  /*
    ��������� ��� ������������� �������� ���������.
  */
  procedure addString(
    optionShortName varchar2
    , optionName varchar2
    , encryptionFlag integer := null
    , stringValue varchar2
  )
  is
  begin
    opt.addString(
      optionShortName   => optionShortName
      , optionName      => optionName
      , encryptionFlag  => encryptionFlag
      , stringValue     => stringValue
      , changeValueFlag =>
          case when stringValue is not null then 1 end
    );
    if stringValue is not null then
      dbms_output.put_line(
        rpad( optionShortName, 30) || ' := "' || stringValue || '"'
      );
    end if;
  end addString;



-- main
begin
  addString(
    optionShortName   => pkg_MailTest.TestSender_OptSName
    , optionName      => '�����: ����� �����������'
    , stringValue     => '&TestSender'
  );
  addString(
    optionShortName   => pkg_MailTest.TestRecipient_OptSName
    , optionName      => '�����: ������ �����������'
    , stringValue     => '&TestRecipient'
  );
  addString(
    optionShortName   => pkg_MailTest.TestSmtpServer_OptSName
    , optionName      => '�����: SMTP ������'
    , stringValue     => '&TestSmtpServer'
  );
  addString(
    optionShortName   => pkg_MailTest.TestSmtpUsername_OptSName
    , optionName      => '�����: ������������ ��� ����������� �� SMTP-�������'
    , stringValue     => '&TestSmtpUsername'
  );
  addString(
    optionShortName   => pkg_MailTest.TestSmtpPassword_OptSName
    , optionName      => '�����: ������ ��� ����������� �� SMTP-�������'
    , stringValue     => '&TestSmtpPassword'
    , encryptionFlag  => 1
  );
  addString(
    optionShortName   => pkg_MailTest.TestFetchUrl_OptSName
    , optionName      =>
        '�����: URL ��������� ����� � URL-encoded ������� ( pop3://user@server.domen)'
    , stringValue     => '&TestFetchUrl'
  );
  addString(
    optionShortName   => pkg_MailTest.TestFetchPassword_OptSName
    , optionName      => '�����: ������ ��� ����������� � ��������� �����'
    , encryptionFlag  =>
        -- ��������� ������ ���� ���������� ����������
        pkg_OptionCrypto.isCryptoAvailable()
    , stringValue     => '&TestFetchPassword'
  );
  addString(
    optionShortName   => pkg_MailTest.TestFetchSendAddress_OptSName
    , optionName      =>
        '�����: ����� ��� �������� ��������� �� �������� ���� ( � ������, ���� �� ���������� �� ������, ����������� �� URL ��������� �����)'
    , stringValue     => '&TestFetchSendAddress'
  );
  commit;
end;
/
