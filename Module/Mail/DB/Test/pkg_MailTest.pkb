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
      messageId := pkg_Mail.sendMessage(
        sender                  =>
            coalesce(
              opt.getString( TestSender_OptSName)
              , pkg_Common.getMailAddressSource( pkg_Mail.Module_Name)
            )
        , recipient             =>
            coalesce(
              opt.getString( TestSender_OptSName)
              , pkg_Common.getMailAddressSource( pkg_Mail.Module_Name)
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
      commit;
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
        nSend := pkg_MailHandler.sendMessage();

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
      );

      -- Получение отправленного письма
      for i in 1 .. 3 loop
        nFetch := pkg_Mail.fetchMessage(
          url         => opt.getString( TestFetchUrl_OptSName)
          , password  => opt.getString( TestFetchPassword_OptSName)
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

        pkg_TestUtility.compareChar(
          actualString        => nFetch
          , expectedString    => 1
          , failMessageText   =>
              cinfo || 'Некорректный результат выполнения fetchMessage'
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
              cinfo || 'Ошибка при получении сообщения:'
              || msg.error_message
              || ' ( message_id=' || messageId || ')'
          );
        end if;

        pkg_TestUtility.compareChar(
          actualString        => msg.message_state_code
          , expectedString    => pkg_Mail.Received_MessageStateCode
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

    checkCase(
      'Без вложения'
    );

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
