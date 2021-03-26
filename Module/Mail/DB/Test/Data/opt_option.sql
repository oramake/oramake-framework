-- script: Test/Data/opt_option.sql
-- Создает или меняет значения параметров тестирования, перечисленных в
-- <pkg_MailTest::Параметры тестирования>.
--
-- Замечания:
-- - устанавливаемые значения берутся из одноименных переменных SQL*Plus,
--  которые могут быть заданы с помощью <SQL_DEFINE>.
--


-- Используемые макропеременные
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
    Добавляет или устанавливает значение параметра.
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
    , optionName      => 'Тесты: Адрес отправителя'
    , stringValue     => '&TestSender'
  );
  addString(
    optionShortName   => pkg_MailTest.TestRecipient_OptSName
    , optionName      => 'Тесты: Адреса получателей'
    , stringValue     => '&TestRecipient'
  );
  addString(
    optionShortName   => pkg_MailTest.TestSmtpServer_OptSName
    , optionName      => 'Тесты: SMTP сервер'
    , stringValue     => '&TestSmtpServer'
  );
  addString(
    optionShortName   => pkg_MailTest.TestSmtpUsername_OptSName
    , optionName      => 'Тесты: Пользователь для авторизации на SMTP-сервере'
    , stringValue     => '&TestSmtpUsername'
  );
  addString(
    optionShortName   => pkg_MailTest.TestSmtpPassword_OptSName
    , optionName      => 'Тесты: Пароль для авторизации на SMTP-сервере'
    , stringValue     => '&TestSmtpPassword'
    , encryptionFlag  => 1
  );
  addString(
    optionShortName   => pkg_MailTest.TestFetchUrl_OptSName
    , optionName      =>
        'Тесты: URL почтового ящика в URL-encoded формате ( pop3://user@server.domen)'
    , stringValue     => '&TestFetchUrl'
  );
  addString(
    optionShortName   => pkg_MailTest.TestFetchPassword_OptSName
    , optionName      => 'Тесты: Пароль для подключения к почтовому ящику'
    , encryptionFlag  =>
        -- Исключаем ошибку если шифрование недоступно
        pkg_OptionCrypto.isCryptoAvailable()
    , stringValue     => '&TestFetchPassword'
  );
  addString(
    optionShortName   => pkg_MailTest.TestFetchSendAddress_OptSName
    , optionName      =>
        'Тесты: Адрес для отправки сообщений на почтовый ящик ( в случае, если он отличается от адреса, выделяемого из URL почтового ящика)'
    , stringValue     => '&TestFetchSendAddress'
  );
  commit;
end;
/
