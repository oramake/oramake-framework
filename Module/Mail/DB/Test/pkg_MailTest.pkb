create or replace package body pkg_MailTest
as
/* package body: pkg_MailTest::body */


/* group: Переменные */


/* ivar: logger
  Логер пакета.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => pkg_Mail.Module_Name
  , objectName  => 'pkg_MailTest'
);

/* ivar: opt
  Параметры тестирования
*/
opt opt_plsql_object_option_t :=
  opt_plsql_object_option_t(
    moduleName        => pkg_Mail.Module_Name
    , objectName      => 'pkg_MailTest'
  )
;



/* group: Функции */

/* iproc: smtpsendJava
  Отправляет письмо ( немедленно).
*/
procedure smtpsendJava(
  recipient varchar2
  , copyRecipient varchar2
  , subject varchar2
  , messageText varchar2
  , sender varchar2
  , smtpServer varchar2
  , username varchar2
  , password varchar2
)
is
language java name '
MailTest.smtpsend(
  java.lang.String
  , java.lang.String
  , java.lang.String
  , java.lang.String
  , java.lang.String
  , java.lang.String
  , java.lang.String
  , java.lang.String
)
';

/* proc: smtpsend
  Отправляет письмо ( немедленно).
*/
procedure smtpsend(
  recipient varchar2 := null
  , copyRecipient varchar2 := null
  , subject varchar2 := null
  , messageText varchar2 := null
  , sender varchar2 := null
  , smtpServer varchar2 := null
  , username varchar2 := null
  , password varchar2 := null
)
is
begin
  smtpsendJava(
    recipient               =>
        coalesce(
          recipient
          , opt.getString( TestRecipient_OptSName)
          , pkg_Common.getMailAddressDestination()
        )
    , copyRecipient         => copyRecipient
    , subject               =>
        coalesce(
          subject
          , 'Mail test: smtpsend: uid=' || dbms_utility.get_time()
        )
    , messageText           => coalesce( messageText, 'Test message text')
    , sender                =>
        coalesce(
          sender
          , opt.getString( TestSmtpUsername_OptSName)
          , opt.getString( TestSender_OptSName)
          , pkg_Common.getMailAddressSource( pkg_Mail.Module_Name)
        )
    , smtpServer            =>
        coalesce( smtpServer, opt.getString( TestSmtpServer_OptSName))
    , username              =>
        coalesce( userName, opt.getString( TestSmtpUsername_OptSName))
    , password              =>
        coalesce( password, opt.getString( TestSmtpPassword_OptSName))
  );
end smtpsend;

/* proc: testEmailValidation
   Выполняет тестовые сценарии для проверки работы валидатора email адресов
*/
procedure testEmailValidation
is
  /*
    Выполняет проверку email адреса

    Параметры:
      testName                       - наименование теста
      expectedCheckResult            - ожидаемый результат
      emailAddress                   - адрес email
      ...
      [список параметров <pkg_MailUtility.isEmailValid>]
      ...
  */
  procedure checkEmailAddress (
      testName                in varchar2
    , expectedCheckResult     in pls_integer
    , emailAddress            in varchar2
    )
  is
    checkResult pls_integer;

  -- checkEmailAddress
  begin
    pkg_TestUtility.beginTest( testName );
    begin
      checkResult := pkg_MailUtility.isEmailValid( emailAddress );
      pkg_TestUtility.compareChar(
          actualString    => to_char( checkResult )
        , expectedString  => to_char( expectedCheckResult )
        , failMessageText => 'The result of email validation is incorrect'
        );

    exception
      when others then
        pkg_TestUtility.failTest( 'Exception: ' || pkg_Logging.getErrorStack() );
    end;
    pkg_TestUtility.endTest();

  end checkEmailAddress;


-- testEmailValidation
begin
  checkEmailAddress(
      testName            => 'Validate email (null)'
    , expectedCheckResult => 0
    , emailAddress        => null
    );
  checkEmailAddress(
      testName            => 'Validate email (a.aaaaaaa.a.a.b$@Fjd-.kfj.ru)'
    , expectedCheckResult => 1
    , emailAddress        => 'a.aaaaaaa.a.a.b$@Fjd-.kfj.ru'
    );
  checkEmailAddress(
      testName            => 'Validate email (a..b@rambler.ru)'
    , expectedCheckResult => 0
    , emailAddress        => 'a..b@rambler.ru'
    );
  checkEmailAddress(
      testName            => 'Validate email (cjdfgjdhfadf@fjdf.ffff@fjdflkjd.ru)'
    , expectedCheckResult => 0
    , emailAddress        => 'cjdfgjdhfadf@fjdf.ffff@fjdflkjd.ru'
    );
  checkEmailAddress(
      testName            => 'Validate email (.bbbbbb@fadjsfla.ru)'
    , expectedCheckResult => 0
    , emailAddress        => '.bbbbbb@fadjsfla.ru'
    );
  checkEmailAddress(
      testName            => 'Validate email (#@.a)'
    , expectedCheckResult => 0
    , emailAddress        => '#@.a'
    );
  checkEmailAddress(
      testName            => 'Validate email (a,b@a.ru)'
    , expectedCheckResult => 0
    , emailAddress        => 'a,b@a.ru'
    );
  checkEmailAddress(
      testName            => 'Validate email (a-b@a.ru)'
    , expectedCheckResult => 1
    , emailAddress        => 'a-b@a.ru'
    );

exception
  when others then
    raise_application_error(
        pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при выполнении тестовых сценариев для проверки работы валидатора email адресов'
          )
      , true
      );

end testEmailValidation;

/* proc: testSendMail
  Тестирование немедленной отправки почтовых сообщений.

  Параметры:
  testCaseNumber              - Номер проверяемого тестового случая
                                ( по умолчанию без ограничений)
*/
procedure testSendMail(
  testCaseNumber integer := null
)
is

  -- Имя выполняемого теста
  Test_Name constant varchar2(50) := 'send mail';

  -- Порядковый номер очередного тестового случая
  checkCaseNumber integer := 0;



  /*
    Проверяет тестовый случай.
  */
  procedure checkCase(
    caseDescription varchar2
    , errorMessageMask varchar2 := null
    , nextCaseUsedCount pls_integer := null
  )
  is

    -- Описание тестового случая
    cinfo varchar2(200) :=
      'CASE ' || to_char( checkCaseNumber + 1)
      || ' "' || caseDescription || '": '
    ;

    errorMessage varchar2(32000);

  -- checkCase
  begin
    checkCaseNumber := checkCaseNumber + 1;
    if pkg_TestUtility.isTestFailed()
          or testCaseNumber is not null
            and testCaseNumber
              not between checkCaseNumber
                and checkCaseNumber + coalesce( nextCaseUsedCount, 0)
        then
      return;
    end if;
    logger.info( '*** ' || cinfo);

    begin
      pkg_Mail.sendMail(
        sender                  =>
            coalesce(
              opt.getString( TestSender_OptSName)
              , pkg_Common.getMailAddressSource( pkg_Mail.Module_Name)
            )
        , recipient             =>
            coalesce(
              opt.getString( TestRecipient_OptSName)
              , pkg_Common.getMailAddressDestination()
            )
        , copyRecipient         => null
        , subject               =>
            'Mail test'
            || ': ' || Test_Name
            || ': CASE ' || checkCaseNumber
            || ', uid=' || dbms_utility.get_time()
        , messageText           =>
            'Тестовое сообщение'
        , attachmentFileName    => null
        , attachmentType        => null
        , attachmentData        => null
        , smtpServer            => opt.getString( TestSmtpServer_OptSName)
        , username              => opt.getString( TestSmtpUsername_OptSName)
        , password              => opt.getString( TestSmtpPassword_OptSName)
        , isHTML                => null
      );
      if errorMessageMask is not null then
        pkg_TestUtility.failTest(
          failMessageText   =>
            cinfo || 'Успешное выполнение вместо ошибки'
        );
      end if;
    exception when others then
      if errorMessageMask is not null then
        errorMessage := logger.getErrorStack();
        if errorMessage not like errorMessageMask then
          pkg_TestUtility.compareChar(
            actualString        => errorMessage
            , expectedString    => errorMessageMask
            , failMessageText   =>
                cinfo || 'Сообщение об ошибке не соответствует маске'
          );
        end if;
      else
        pkg_TestUtility.failTest(
          failMessageText   =>
            cinfo || 'Выполнение завершилось с ошибкой:'
            || chr(10) || logger.getErrorStack()
        );
      end if;
    end;

    -- Проверка успешного результата
    if errorMessageMask is null then
      null;
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при проверке тестового случая ('
          || ' caseNumber=' || checkCaseNumber
          || ', caseDescription="' || caseDescription || '"'
          || ').'
        )
      , true
    );
  end checkCase;



-- testSendMail
begin
  pkg_TestUtility.beginTest( Test_Name);

  checkCase(
    'Без вложения'
  );

  pkg_TestUtility.endTest();
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при тестировании немедленной отправки почтовых сообщений ('
        || ' testCaseNumber=' || testCaseNumber
        || ').'
      )
    , true
  );
end testSendMail;

/* proc: testSendMessage
  Тестирование отправки почтовых сообщений.

  Параметры:
  testCaseNumber              - Номер проверяемого тестового случая
                                ( по умолчанию без ограничений)
*/
procedure testSendMessage(
  testCaseNumber integer := null
)
is

  -- Имя выполняемого теста
  Test_Name constant varchar2(50) := 'send message';

  -- Порядковый номер очередного тестового случая
  checkCaseNumber integer := 0;



  /*
    Проверяет тестовый случай.
  */
  procedure checkCase(
    caseDescription varchar2
    , addFileData blob := null
    , addFileName varchar2 := null
    , addFileType varchar2 := null
    , errorMessageMask varchar2 := null
    , nextCaseUsedCount pls_integer := null
  )
  is

    -- Описание тестового случая
    cinfo varchar2(200) :=
      'CASE ' || to_char( checkCaseNumber + 1)
      || ' "' || caseDescription || '": '
    ;

    errorMessage varchar2(32000);

    -- Id созданного сообщения
    messageId integer;

    attachmentId integer;

    nSend integer;

    msg ml_message%rowtype;

  -- checkCase
  begin
    checkCaseNumber := checkCaseNumber + 1;
    if pkg_TestUtility.isTestFailed()
          or testCaseNumber is not null
            and testCaseNumber
              not between checkCaseNumber
                and checkCaseNumber + coalesce( nextCaseUsedCount, 0)
        then
      return;
    end if;
    logger.info( '*** ' || cinfo);

    begin
      savepoint pkg_MailTestSendMessage;
      messageId := pkg_Mail.sendMessage(
        sender                  =>
            coalesce(
              opt.getString( TestSender_OptSName)
              , pkg_Common.getMailAddressSource( pkg_Mail.Module_Name)
            )
        , recipient             =>
            coalesce(
              opt.getString( TestRecipient_OptSName)
              , pkg_Common.getMailAddressDestination()
            )
        , copyRecipient         => null
        , subject               =>
            'Mail test'
            || ': ' || Test_Name
            || ': CASE ' || checkCaseNumber
            || ', uid=' || dbms_utility.get_time()
        , messageText           =>
            'Тестовое сообщение'
        , attachmentFileName    => null
        , attachmentType        => null
        , attachmentData        => null
        , smtpServer            => opt.getString( TestSmtpServer_OptSName)
        , expireDate            => add_months( sysdate, 1)
      );
      if addFileData is not null then
        attachmentId := pkg_Mail.addAttachment(
          messageId             => messageId
          , attachmentFileName  => addFileName
          , attachmentType      => addFileType
          , attachmentData      => addFileData
        );
      end if;
      commit;
      if errorMessageMask is not null then
        pkg_TestUtility.failTest(
          failMessageText   =>
            cinfo || 'Успешное выполнение вместо ошибки'
        );
      end if;
    exception when others then
      rollback to pkg_MailTestSendMessage;
      if errorMessageMask is not null then
        errorMessage := logger.getErrorStack();
        if errorMessage not like errorMessageMask then
          pkg_TestUtility.compareChar(
            actualString        => errorMessage
            , expectedString    => errorMessageMask
            , failMessageText   =>
                cinfo || 'Сообщение об ошибке не соответствует маске'
          );
        end if;
      else
        pkg_TestUtility.failTest(
          failMessageText   =>
            cinfo || 'Выполнение завершилось с ошибкой:'
            || chr(10) || logger.getErrorStack()
        );
      end if;
    end;

    -- Проверка успешного результата
    if errorMessageMask is null then

      if messageId is null then
        pkg_TestUtility.failTest(
          failMessageText   =>
            cinfo || 'Функция вернула null вместо Id сообщения'
        );
      else
        pkg_TestUtility.compareRowCount(
          tableName           => 'ml_message'
          , filterCondition   => 'message_id =' || messageId
          , expectedRowCount  => 1
          , failMessageText   =>
              cinfo || 'Сообщение не найдено в ml_message'
              || ' ( message_id=' || messageId || ')'
        );
      end if;

      if not coalesce( pkg_TestUtility.isTestFailed(), false) then

        -- Отправляем все ожидающие отправки сообщения
        nSend := pkg_MailHandler.sendMessage(
          smtpServer    => opt.getString( TestSmtpServer_OptSName)
          , username    => opt.getString( TestSmtpUsername_OptSName)
          , password    => opt.getString( TestSmtpPassword_OptSName)
        );

        select
          t.*
        into msg
        from
          ml_message t
        where
          t.message_id = messageId
        ;

        if msg.error_message is not null then
          pkg_TestUtility.failTest(
            failMessageText   =>
              cinfo || 'Ошибка при отправке сообщения:'
              || msg.error_message
              || ' ( message_id=' || messageId || ')'
          );
        end if;

        pkg_TestUtility.compareChar(
          actualString        => msg.incoming_flag
          , expectedString    => 0
          , failMessageText   =>
              cinfo || 'Некорректное значение incoming_flag'
        );
        pkg_TestUtility.compareChar(
          actualString        => msg.message_state_code
          , expectedString    => pkg_Mail.Send_MessageStateCode
          , failMessageText   =>
              cinfo || 'Некорректное значение message_state_code'
        );
      end if;
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при проверке тестового случая ('
          || ' caseNumber=' || checkCaseNumber
          || ', caseDescription="' || caseDescription || '"'
          || ').'
        )
      , true
    );
  end checkCase;



-- testSendMessage
begin
  pkg_TestUtility.beginTest( Test_Name);

  checkCase(
    'Без вложения'
  );

  checkCase(
    'С добавлением текстового файла'
    , addFileData   => hextoraw( '54657374')
    , addFileName   => 'add-file.txt'
  );

  checkCase(
    'С добавлением картинки'
    , addFileData   =>
        hextoraw( translate(
'
89 50 4e 47 0d 0a 1a 0a  00 00 00 0d 49 48 44 52
00 00 00 01 00 00 00 01  08 02 00 00 00 90 77 53
de 00 00 00 04 67 41 4d  41 00 00 b1 8f 0b fc 61
05 00 00 00 09 70 48 59  73 00 00 0e c3 00 00 0e
c3 01 c7 6f a8 64 00 00  00 0c 49 44 41 54 18 57
63 78 2b a3 02 00 03 27  01 2e 15 6b be e9 00 00
00 00 49 45 4e 44 ae 42  60 82
'
        , '. ' || chr(10) || chr(13), '.'))
    , addFileName   => 'red-pixel.png'
  );

  pkg_TestUtility.endTest();
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при тестировании отправки почтовых сообщений ('
        || ' testCaseNumber=' || testCaseNumber
        || ').'
      )
    , true
  );
end testSendMessage;

/* proc: testSendHtmlMessage
  Тестирование отправки почтовых сообщений в формате HTML.

  Параметры:
  testCaseNumber              - Номер проверяемого тестового случая
                                ( по умолчанию без ограничений)
*/
procedure testSendHtmlMessage(
  testCaseNumber integer := null
)
is

  -- Имя выполняемого теста
  Test_Name constant varchar2(50) := 'send HTML message';

  -- Порядковый номер очередного тестового случая
  checkCaseNumber integer := 0;



  /*
    Проверяет тестовый случай.
  */
  procedure checkCase(
    caseDescription varchar2
    , htmlText clob := null
    , image blob := null
    , imageFileName varchar2 := null
    , imageContentType varchar2 := null
    , errorMessageMask varchar2 := null
    , nextCaseUsedCount pls_integer := null
  )
  is

    -- Описание тестового случая
    cinfo varchar2(200) :=
      'CASE ' || to_char( checkCaseNumber + 1)
      || ' "' || caseDescription || '": '
    ;

    errorMessage varchar2(32000);

    -- Id созданного сообщения
    messageId integer;

    attachmentId integer;

    nSend integer;

    msg ml_message%rowtype;

  -- checkCase
  begin
    checkCaseNumber := checkCaseNumber + 1;
    if pkg_TestUtility.isTestFailed()
          or testCaseNumber is not null
            and testCaseNumber
              not between checkCaseNumber
                and checkCaseNumber + coalesce( nextCaseUsedCount, 0)
        then
      return;
    end if;
    logger.info( '*** ' || cinfo);

    begin
      savepoint pkg_MailTestSendHtmlMessage;
      messageId := pkg_Mail.sendHtmlMessage(
        sender                  =>
            coalesce(
              opt.getString( TestSender_OptSName)
              , pkg_Common.getMailAddressSource( pkg_Mail.Module_Name)
            )
        , recipient             =>
            coalesce(
              opt.getString( TestRecipient_OptSName)
              , pkg_Common.getMailAddressDestination()
            )
        , copyRecipient         => null
        , subject               =>
            'Mail test'
            || ': ' || Test_Name
            || ': CASE ' || checkCaseNumber
            || ', uid=' || dbms_utility.get_time()
        , htmlText              =>
            coalesce( htmlText, '<body><h1>Test message</h1></body>')
        , smtpServer            => opt.getString( TestSmtpServer_OptSName)
        , expireDate            => add_months( sysdate, 1)
      );
      if image is not null then
        attachmentId := pkg_Mail.addHtmlImageAttachment(
          messageId             => messageId
          , attachmentFileName  => imageFileName
          , contentType         => imageContentType
          , image               => image
        );
      end if;
      commit;
      if errorMessageMask is not null then
        pkg_TestUtility.failTest(
          failMessageText   =>
            cinfo || 'Успешное выполнение вместо ошибки'
        );
      end if;
    exception when others then
      rollback to pkg_MailTestSendHtmlMessage;
      if errorMessageMask is not null then
        errorMessage := logger.getErrorStack();
        if errorMessage not like errorMessageMask then
          pkg_TestUtility.compareChar(
            actualString        => errorMessage
            , expectedString    => errorMessageMask
            , failMessageText   =>
                cinfo || 'Сообщение об ошибке не соответствует маске'
          );
        end if;
      else
        pkg_TestUtility.failTest(
          failMessageText   =>
            cinfo || 'Выполнение завершилось с ошибкой:'
            || chr(10) || logger.getErrorStack()
        );
      end if;
    end;

    -- Проверка успешного результата
    if errorMessageMask is null then

      if messageId is null then
        pkg_TestUtility.failTest(
          failMessageText   =>
            cinfo || 'Функция вернула null вместо Id сообщения'
        );
      else
        pkg_TestUtility.compareRowCount(
          tableName           => 'ml_message'
          , filterCondition   => 'message_id =' || messageId
          , expectedRowCount  => 1
          , failMessageText   =>
              cinfo || 'Сообщение не найдено в ml_message'
              || ' ( message_id=' || messageId || ')'
        );
      end if;

      if not coalesce( pkg_TestUtility.isTestFailed(), false) then

        -- Отправляем все ожидающие отправки сообщения
        nSend := pkg_MailHandler.sendMessage(
          smtpServer    => opt.getString( TestSmtpServer_OptSName)
          , username    => opt.getString( TestSmtpUsername_OptSName)
          , password    => opt.getString( TestSmtpPassword_OptSName)
        );

        select
          t.*
        into msg
        from
          ml_message t
        where
          t.message_id = messageId
        ;

        if msg.error_message is not null then
          pkg_TestUtility.failTest(
            failMessageText   =>
              cinfo || 'Ошибка при отправке сообщения:'
              || msg.error_message
              || ' ( message_id=' || messageId || ')'
          );
        end if;

        pkg_TestUtility.compareChar(
          actualString        => msg.incoming_flag
          , expectedString    => 0
          , failMessageText   =>
              cinfo || 'Некорректное значение incoming_flag'
        );
        pkg_TestUtility.compareChar(
          actualString        => msg.message_state_code
          , expectedString    => pkg_Mail.Send_MessageStateCode
          , failMessageText   =>
              cinfo || 'Некорректное значение message_state_code'
        );
      end if;
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при проверке тестового случая ('
          || ' caseNumber=' || checkCaseNumber
          || ', caseDescription="' || caseDescription || '"'
          || ').'
        )
      , true
    );
  end checkCase;



-- testSendHtmlMessage
begin
  pkg_TestUtility.beginTest( Test_Name);

  checkCase(
    'Без вложения'
  );

  checkCase(
    'HTML c использованием фоновой картинки'
    , htmlText =>
        '<body background="red-pixel.png"><h1>Test message</h1></body>'
    , image             =>
        hextoraw( translate(
'
89 50 4e 47 0d 0a 1a 0a  00 00 00 0d 49 48 44 52
00 00 00 01 00 00 00 01  08 02 00 00 00 90 77 53
de 00 00 00 04 67 41 4d  41 00 00 b1 8f 0b fc 61
05 00 00 00 09 70 48 59  73 00 00 0e c3 00 00 0e
c3 01 c7 6f a8 64 00 00  00 0c 49 44 41 54 18 57
63 78 2b a3 02 00 03 27  01 2e 15 6b be e9 00 00
00 00 49 45 4e 44 ae 42  60 82
'
        , '. ' || chr(10) || chr(13), '.'))
    , imageFileName     => 'red-pixel.png'
  );

  pkg_TestUtility.endTest();
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при тестировании отправки почтовых сообщений в формате HTML ('
        || ' testCaseNumber=' || testCaseNumber
        || ').'
      )
    , true
  );
end testSendHtmlMessage;

/* proc: testFetchMessage
  Тестирование получения почтовых сообщений.

  Параметры:
  testCaseNumber              - Номер проверяемого тестового случая
                                ( по умолчанию без ограничений)
*/
procedure testFetchMessage(
  testCaseNumber integer := null
)
is

  -- Имя выполняемого теста
  Test_Name constant varchar2(50) := 'fetch message';

  -- Порядковый номер очередного тестового случая
  checkCaseNumber integer := 0;

  -- Адрес тестового ящика
  mailboxAddress varchar2(100);

  -- Id последнего проверявшегося сообщения
  lastMessageId integer;



  /*
    Проверяет тестовый случай.
  */
  procedure checkCase(
    caseDescription varchar2
    , isGotMessageDeleted integer
    , deleteMailboxMessageId integer := null
    , existsMailboxMessageId integer := null
    , errorMessageMask varchar2 := null
    , nextCaseUsedCount pls_integer := null
    , skipCheckCountFlag pls_integer := null
  )
  is

    -- Описание тестового случая
    cinfo varchar2(200) :=
      'CASE ' || to_char( checkCaseNumber + 1)
      || ' "' || caseDescription || '": '
    ;

    errorMessage varchar2(32000);

    -- Число полученных сообщений
    nFetch integer;

    -- Тема тестового сообщения
    testSubject varchar2(100);

    -- Id полученного сообщения
    messageId integer;

    msg ml_message%rowtype;



    /*
      Поиск полученного тестового сообщения.
    */
    function findMessage
    return boolean
    is
    begin
      select
        max( t.message_id)
      into messageId
      from
        ml_message t
      where
        t.recipient_address = mailboxAddress
        and t.subject = testSubject
      ;
      return messageId is not null;
    end findMessage;



  -- checkCase
  begin
    checkCaseNumber := checkCaseNumber + 1;
    if pkg_TestUtility.isTestFailed()
          or testCaseNumber is not null
            and testCaseNumber
              not between checkCaseNumber
                and checkCaseNumber + coalesce( nextCaseUsedCount, 0)
        then
      return;
    end if;
    logger.info( '*** ' || cinfo);

    testSubject :=
      'Mail test'
      || ': ' || Test_Name
      || ': CASE ' || checkCaseNumber
      || ', uid=' || dbms_utility.get_time()
    ;
    begin

      if deleteMailboxMessageId is not null then
        pkg_Mail.deleteMailboxMessage(
          messageId => deleteMailboxMessageId
        );
        commit;
      end if;

      -- Отправка письма для тестового ящика
      pkg_Mail.sendMail(
        sender                  =>
            coalesce(
              opt.getString( TestSender_OptSName)
              , pkg_Common.getMailAddressSource( pkg_Mail.Module_Name)
            )
        , recipient             =>
            coalesce(
              opt.getString( TestFetchSendAddress_OptSName)
              , mailboxAddress
            )
        , subject               => testSubject
        , messageText           =>
            'Тестовое сообщение'
        , attachmentFileName    => null
        , attachmentType        => null
        , attachmentData        => null
        , smtpServer            => opt.getString( TestSmtpServer_OptSName)
        , username              => opt.getString( TestSmtpUsername_OptSName)
        , password              => opt.getString( TestSmtpPassword_OptSName)
      );

      -- Получение отправленного письма
      for i in 1 .. 3 loop
        nFetch := pkg_Mail.fetchMessage(
          url                     => opt.getString( TestFetchUrl_OptSName)
          , password              => opt.getString( TestFetchPassword_OptSName)
          , recipientAddress      => null
          , isGotMessageDeleted   => isGotMessageDeleted
        );
        exit when findMessage() or coalesce( nFetch != 0, true);
      end loop;
      if errorMessageMask is not null then
        pkg_TestUtility.failTest(
          failMessageText   =>
            cinfo || 'Успешное выполнение вместо ошибки'
        );
      end if;
    exception when others then
      if errorMessageMask is not null then
        errorMessage := logger.getErrorStack();
        if errorMessage not like errorMessageMask then
          pkg_TestUtility.compareChar(
            actualString        => errorMessage
            , expectedString    => errorMessageMask
            , failMessageText   =>
                cinfo || 'Сообщение об ошибке не соответствует маске'
          );
        end if;
      else
        pkg_TestUtility.failTest(
          failMessageText   =>
            cinfo || 'Выполнение завершилось с ошибкой:'
            || chr(10) || logger.getErrorStack()
        );
      end if;
    end;

    -- Проверка успешного результата
    if errorMessageMask is null then

      if messageId is null then
        pkg_TestUtility.failTest(
          failMessageText   =>
            cinfo || 'Тестовое письмо не было получено'
            || ' ( testSubject="' || testSubject || '")'
        );
      else
        pkg_TestUtility.compareRowCount(
          tableName           => 'ml_message'
          , filterCondition   => 'message_id =' || messageId
          , expectedRowCount  => 1
          , failMessageText   =>
              cinfo || 'Сообщение не найдено в ml_message'
              || ' ( message_id=' || messageId || ')'
        );
      end if;

      if not coalesce( pkg_TestUtility.isTestFailed(), false) then

        if coalesce( skipCheckCountFlag, 0) = 0 then
          pkg_TestUtility.compareChar(
            actualString        => nFetch
            , expectedString    => 1
            , failMessageText   =>
                cinfo || 'Некорректный результат выполнения fetchMessage'
          );
        end if;

        select
          t.*
        into msg
        from
          ml_message t
        where
          t.message_id = messageId
        ;

        if msg.error_message is not null then
          pkg_TestUtility.failTest(
            failMessageText   =>
              cinfo || 'Ошибка при получении сообщения:'
              || msg.error_message
              || ' ( message_id=' || messageId || ')'
          );
        end if;

        pkg_TestUtility.compareChar(
          actualString        => msg.incoming_flag
          , expectedString    => 1
          , failMessageText   =>
              cinfo || 'Некорректное значение incoming_flag'
              || ' ( message_id=' || messageId || ')'
        );
        pkg_TestUtility.compareChar(
          actualString        => msg.message_state_code
          , expectedString    => pkg_Mail.Received_MessageStateCode
          , failMessageText   =>
              cinfo || 'Некорректное значение message_state_code'
              || ' ( message_id=' || messageId || ')'
        );
        pkg_TestUtility.compareChar(
          actualString        => msg.mailbox_delete_date
          , expectedString    =>
              case when coalesce( isGotMessageDeleted, 1) = 1 then
                coalesce( msg.mailbox_delete_date, sysdate)
              end
          , failMessageText   =>
              cinfo || 'Некорректное значение mailbox_delete_date'
              || ' ( message_id=' || messageId || ')'
        );
        pkg_TestUtility.compareChar(
          actualString        => msg.mailbox_for_delete_flag
          , expectedString    =>
              case when isGotMessageDeleted = 0 then
                0
              end
          , failMessageText   =>
              cinfo || 'Некорректное значение mailbox_for_delete_flag'
              || ' ( message_id=' || messageId || ')'
        );
        if deleteMailboxMessageId is not null then
          pkg_TestUtility.compareRowCount(
            tableName           => 'ml_message'
            , filterCondition   =>
                'message_id =' || deleteMailboxMessageId
                || ' and mailbox_delete_date is not null'
                || ' and mailbox_for_delete_flag = 1'
            , expectedRowCount  => 1
            , failMessageText   =>
                cinfo || 'Некорректное заполнение mailbox_delete_date'
                || ' или mailbox_for_delete_flag удаляемого сообщения'
                || ' ( deleteMailboxMessageId=' || deleteMailboxMessageId || ')'
          );
        end if;
        if existsMailboxMessageId is not null then
          pkg_TestUtility.compareRowCount(
            tableName           => 'ml_message'
            , filterCondition   =>
                'message_id =' || existsMailboxMessageId
                || ' and mailbox_delete_date is null'
                || ' and mailbox_for_delete_flag = 0'
            , expectedRowCount  => 1
            , failMessageText   =>
                cinfo || 'Некорректное заполнение mailbox_delete_date'
                || ' или mailbox_for_delete_flag сохраняемого сообщения'
                || ' ( existsMailboxMessageId=' || existsMailboxMessageId || ')'
          );
        end if;
      end if;
    end if;
    lastMessageId := messageId;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при проверке тестового случая ('
          || ' caseNumber=' || checkCaseNumber
          || ', caseDescription="' || caseDescription || '"'
          || ').'
        )
      , true
    );
  end checkCase;



  /*
    Выполняет тест.
  */
  procedure processTest
  is

    savedMessageId integer;

  begin
    checkCase(
      'Без вложения'
    , isGotMessageDeleted       => 0
    , skipCheckCountFlag        => 1
    );

    checkCase(
      'Без удаления при получении'
      , isGotMessageDeleted     => 0
      , nextCaseUsedCount       => 2
    );
    savedMessageId := lastMessageId;

    checkCase(
      'С сохранением ранее полученного'
      , isGotMessageDeleted     => 1
      , existsMailboxMessageId  => savedMessageId
      , nextCaseUsedCount       => 1
    );

    checkCase(
      'Удаление только ранее полученого'
      , deleteMailboxMessageId  => savedMessageId
      , isGotMessageDeleted     => 0
      , nextCaseUsedCount       => 1
    );

    checkCase(
      'Удаление нового и ранее полученного'
      , deleteMailboxMessageId  => lastMessageId
      , isGotMessageDeleted     => 1
    );
  end processTest;



-- testFetchMessage
begin
  pkg_TestUtility.beginTest( Test_Name);

  if opt.getString( TestFetchUrl_OptSName) is null then
    pkg_TestUtility.failTest(
      'Необходимо задать параметры тестового почтового ящика ('
      || ' ' || TestFetchUrl_OptSName
      || ', ' || TestFetchPassword_OptSName
      || ')'
    );
  else
    mailboxAddress := pkg_MailUtility.getMailboxAddress(
      opt.getString( TestFetchUrl_OptSName)
    );
    processTest();
  end if;

  pkg_TestUtility.endTest();
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при тестировании получения почтовых сообщений ('
        || ' testCaseNumber=' || testCaseNumber
        || ').'
      )
    , true
  );
end testFetchMessage;

end pkg_MailTest;
/
