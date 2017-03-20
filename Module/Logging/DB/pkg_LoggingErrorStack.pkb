create or replace package body pkg_LoggingErrorStack is
/* package body: pkg_LoggingErrorStack::body

  Логируемые сообщения пакета.

  - соединяемые "куски" стека, информация о соединении
    и сброс стека при его получении и отладочная информация
    ( см. <logErrorStackElement>, <resolveStack>, <getErrorStack>)
    с уровнем <pkg_Logging.Trace_LevelCode>

  - сбрасываемый предыдущий стек
    при невозможности соединения, например, при гашении
    предыдущего исключения без получения c помощью <getErrorStack>,
    или при принудельном сбрасывании стека
    ( см. <clearLastStack>, <resolveStack>)
    с уровнем <pkg_Logging.Debug_LevelCode>

  - логирование содержимого текущего
    стека, вызванное в блоке обработки
    исключения ( <logErrorStack>)
    с уровнем <pkg_Logging.Error_LevelCode>

  - ошибка при невозможности получения данных стека
    из удалённой БД ( см. <getRemoteStack>)
    с уровнем <pkg_Logging.Warn_LevelCode>
*/



/* group: Типы */

/* itype: TMaxVarchar2
  Тип для varchar2 максимальной длины
*/
subtype TMaxVarchar2 is varchar2( 32767);

/* itype: TStack
  Данные стека ошибок.

  raisedText                 - сообщение для генерации исключения,
                               возвращаемое функцией <processStackElement>
  oracleMessage              - значение <errorStack> сообщения в стеке
  messageText                - переданный текст сообщения об ошибке
  resolvedStack              - полный расшированный текст сообщения
                               об ошибке
  callStack                  - текст информации о стеке вызовов
  isRemote                   - получен ли стек из удалённой базы ( 1-да)
*/
type TStack is record(
  raisedText               TMaxVarchar2
  , oracleMessage          TMaxVarchar2
  , messageText            TMaxVarchar2
  , resolvedStack          TMaxVarchar2
  , callStack              TMaxVarchar2
  , isRemote               integer
);



/* group: Константы */

/* iconst: Max_Varchar2_Length
  Максимальная длина varchar2
*/
Max_Varchar2_Length constant integer := 32767;

/* iconst: Stack_Message_Limit
  Лимит суммы длины сообщения стека ошибок,
  при превышении которого сообщение шифруется
  Нужно учесть также сообщения с кодом 6512
  о месте возбуждения исключения.
*/
Stack_Message_Limit constant integer := 512 - 60;

/* iconst: Raised_Message_Limit
  Лимит длины генерируемого сообщения исключения
  при зашифровке
*/
Raised_Message_Limit constant integer := Stack_Message_Limit;

/* iconst: Truncated_Stack_Length
  Длина текста для стека, при котором допускается
  частичное совпадение с предыдущим стеком
*/
Truncated_Stack_Length constant integer := 1000;

/* iconst: Truncated_Remote_Stack_Length
  Длина текста для стека, при котором допускается
  частичное совпадение с предыдущим стеком
  при получении стека по линку
*/
Truncated_Remote_Stack_Length constant integer := 512;



/* group: Переменные */



/* group: Информация о предыдущем состоянии стека */

/* ivar: lastStack
  Последние данные стека ошибок
  ( включая данные последнего элемента стека)
*/
lastStack TStack;

/* ivar: lastClearedStack
  Данные по последнему сброшенному стеку
  ( до последнего вызова функции <initializeStack>)
*/
lastClearedStack TStack;

/* group: Информация о текущем состоянии стека */

/* ivar: errorStack
  Текущее сообщение из стека ошибок
  ( результат dbms_utility.format_error_stack)
*/
oracleErrorStack TMaxVarchar2;

/* ivar: resolvedStack
  Полный расшированный текст текущего сообщения
  об ошибке
*/
resolvedStack TMaxVarchar2;



/* group: Прочие переменные */

/* ivar: errorStackSessionId
  Id для метки сообщения при шифровке,
  использущийся в данной сессии
*/
errorStackSessionId varchar2(50) := null;

/* ivar: errorStackId
  Id для метки сообщения при шифровке,
  значения которого уникальны в пределах
  данной сессии
*/
errorStackId integer := 0;

/* ivar: logger
  Интерфейсный объект к модулю Logging
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName => pkg_Logging.Module_Name
  , objectName => 'pkg_LoggingErrorStack'
);



/* group: Функции */

/* ifunc: getNextStackUid
  Получение текста для шифровки следующего сообщения
  об ошибке
*/
function getNextStackUid
return varchar2
is
begin
  if errorStackSessionId is null then
    errorStackSessionId :=
      pkg_Common.GetSessionSid
      || '/' || pkg_Common.GetSessionSerial;
  end if;
  errorStackId := errorStackId + 1;
  return
    '$(err#='
    || to_char( errorStackSessionId)
    || '/' || to_char( errorStackId)
    || ')';
end getNextStackUid;

/* iproc: initializeStack
  Инициализация информации о стеке
  и сохранение <lastClearedStack>.
*/
procedure initializeStack
is
begin
  logger.trace( 'initializeStack: start');
  lastClearedStack := lastStack;
  lastStack.callStack := dbms_utility.format_call_stack;
  lastStack.raisedText := null;
  lastStack.oracleMessage := null;
  lastStack.messageText := null;
  lastStack.resolvedStack := null;
  lastStack.isRemote := null;
  logger.trace( 'initializeStack: end');
end initializeStack;

/* iproc: clearLastStack(messageText)
  Логирует и сбрасывает и
  информацию о предыдущем стеке ошибок

  Параметры:
  messageText                 - сообщение для логирования
                                Если не задано, логируется
                                сообщение по-умолчанию.

  Примечание:
  - может быть вызвана как в блоке обработки исключений, так и вне его.
*/
procedure clearLastStack(
  messageText varchar2
)
is
begin
  logger.trace(
    'Stack saved ( lastClearedStack.raisedText="' || lastClearedStack.raisedText || '")'
  );

  -- Если предыдущий стек непуст
  if lastStack.raisedText is not null then
    logger.Log(
      levelCode => pkg_Logging.Debug_LevelCode
      , messageText =>
          case when
            messageText is not null
          then
            messageText || chr(10)
          end
          ||
          case when
            lastStack.resolvedStack <> lastStack.oracleMessage
          then
            'LAST_PACKED_STACK: ' || lastStack.oracleMessage || chr(10)
          end
          || 'LAST_ERROR_STACK: ' || lastStack.resolvedStack
          || chr(10) || 'LAST_MESSAGE_TEXT: ' || lastStack.messageText
          || chr(10) || 'LAST_CALL_STACK: ' || lastStack.callStack
    );
  end if;
  initializeStack;
end clearLastStack;

/* proc: clearLastStack
  Сбрасывает информацию о предыдущем стеке ошибок

  Примечание:
  - может быть вызвана как в блоке обработки исключений,
    так и вне его.
  - вызывает <clearLastStack(messageText)>
    с сообщением "Сброс стека"
*/
procedure clearLastStack
is
begin
  clearLastStack(
    messageText => 'Сброс стека'
  );
end clearLastStack;

/* iproc: logCurrentStack
  Логирует информацию о текущем стеке

  Параметры:
  messageText                 - текст дополнительного сообщения
  levelCode                   - уровень логирования

  Примечание:
  - должна вызываться после вызова <resolveStack>
*/
procedure logCurrentStack(
  messageText varchar2
  , levelCode varchar2
)
is
begin
  logger.trace( 'logCurrentStack');
  logger.Log(
    levelCode => levelCode
    , messageText =>
        case when
          messageText is not null
        then
          messageText || chr(10)
        end
        || 'ERROR_STACK: ' || resolvedStack
        || chr(10) || 'CALL_STACK: ' || lastStack.callStack
  );
end logCurrentStack;

/* iproc: resolveStack
  Присваивает значение <oracleErrorStack>.
  Пытается связать информацию о предыдущем состоянии стека
  и информацию текущего стека, если она есть. Если это не удаётся,
  вызывает <clearLastStack>.
  Присваивает значение <resolvedStack>.

  Примечание:
  - для соединения стека
    должна вызываться в блоке обработки исключений.
    При вызове вне блока обработки исключений,
    вызовет <clearLastStack>
*/
procedure resolveStack
is

  -- Значение sqlerrm
  sqlErrorMessage TMaxVarchar2;



  /*
    Соединяет необрезанный стек с предыдущим
  */
  procedure resolveRegularStack
  is

    -- Начало текста предыдущего стека в текущем тексте
    previousStackStart integer;

    -- Конец текста предыдущего стека
    previousStackEnd integer;

  begin
    previousStackStart := instr( oracleErrorStack, lastStack.oracleMessage);
    if previousStackStart > 0 then

      -- Пытаемся найти конец предыдущего стека
      previousStackEnd := previousStackStart + length( lastStack.oracleMessage)-1;
      resolvedStack :=
        substr(
          replace(
            substr( oracleErrorStack, 1, previousStackStart-1)
            , lastStack.raisedText
            , lastStack.messageText
          )
          || lastStack.resolvedStack
          || substr( oracleErrorStack, previousStackEnd+1)
          , 1
          , Max_Varchar2_Length
        );
    else

      -- Если предыдущий стек не найден в текущем, но найден текст исключения
      resolvedStack :=
        substr(
          replace(
            oracleErrorStack
            , lastStack.raisedText
            , lastStack.messageText
          )
          || lastStack.resolvedStack
          , 1
          , Max_Varchar2_Length
        );
    end if;
  end resolveRegularStack;



  /*
    Соединяет обрезанный стек с предыдущим
  */
  procedure resolveLargeStack
  is

    -- Начало текста предыдущего стека в текущем тексте
    previousStackStart integer;

    -- "Хвост" к предыдущему стеку слева
    leftTag TMaxVarchar2;

    -- Формируемый новый "хвост" к предыдущему стеку слева
    resolvedLeftTag TMaxVarchar2;

    -- Минимальная длина начала строки для совпадения предыдущего стека с
    -- обрезанным текущим
    Min_Stack_Coincidence_Length constant integer := 300;

    -- Маска строки для номера ошибки Oracle
    Ora_Error_Mask varchar2( 50 ) := 'ORA-_____:';



    /*
      Поиск и замена строки предыдущего сгенерированного сообщения
      ( lastStack.raisedText) на сообщение предыдущего стека
      (lastStack.messageText) в левом "хвосте" стека ( leftTag)
    */
    procedure checkRaisedText
    is

      -- Начало и конец возможно обрезанной строки предыдущего
      -- сгенерированного сообщения
      raisedTextStart integer;
      raisedTextEnd integer;

      -- Пробная позиция конца строки
      triedEnd integer;

      -- Переменная для защиты от зацикливания
      safeCycle integer := 0;

    begin
      logger.trace(
        'ReplaceRaisedText: leftTagMask2= '
        || '"' || Ora_Error_Mask || ' ' || '%' || chr(10) || '"'
      );
      if leftTag like
         Ora_Error_Mask || ' ' || '%' || chr(10)
         || Ora_Error_Mask || '%' || 'line' || '%' || chr(10)
         or
         leftTag like
         Ora_Error_Mask || ' ' || '%' || chr(10)
      then
        raisedTextStart :=
          length( Ora_Error_Mask || ' ') + 1;
        logger.trace( 'ReplaceRaisedText: raisedTextStart='
          || to_char( raisedTextStart)
        );

        raisedTextEnd := raisedTextStart -1;
        loop

          -- Пробуем передвинуться к концу текущей строки
          triedEnd :=
            instr(
              leftTag
              , chr(10)
              , raisedTextEnd + 2
            ) - 1;

          -- Выходим, если строка между raisedTextStart и triedEnd уже не
          -- содержится в lastStack.raisedText
          exit when
            coalesce( triedEnd, 0) <= 0
          or
            lastStack.raisedText
              not like
            substr(
              leftTag
              , raisedTextStart
              , triedEnd - raisedTextStart + 1
            ) || '%';
          safeCycle := safeCycle + 1;
          exit when safeCycle > 20;

          -- Получилось сместиться до следующей строки
          raisedTextEnd := triedEnd;
          logger.trace( 'ReplaceRaisedText: raisedTextEnd= '
            || to_char( raisedTextEnd)
          );
        end loop;
        if safeCycle > 20 then
          logger.Debug( 'resolveLargeStack: ReplaceRaisedText: safeCycle worked' );
        end if;
      end if;
      logger.trace( 'ReplaceRaisedText: remains='
        || '"' || substr( leftTag, raisedTextEnd +1 ) || '"'
      );

      -- Если локализована обрезанная строка исключения ( возможно пустая), то
      -- заменяем её
      if
        raisedTextStart is not null
        and raisedTextEnd is not null
        and
          lastStack.raisedText
        like
          substr(
            leftTag
            , raisedTextStart
            , raisedTextEnd - raisedTextStart + 1
          ) || '%'
        and
        -- Если остальная часть вырождена или удовлетворяет некоторой маске
        (
          substr( leftTag, raisedTextEnd +1 )
          like chr(10) || Ora_Error_Mask || '%' || 'line' || '%' || chr(10)
          or substr( leftTag, raisedTextEnd +1 ) = chr(10)
        )
      then
        resolvedLeftTag :=
          substr(
            leftTag
            , 1
            , raisedTextStart-1
          )
          || lastStack.messageText
          ||
          substr(
            leftTag
            , raisedTextEnd+1
          );
        logger.trace( 'ReplaceRaisedText: resolvedLeftTag='
          || resolvedLeftTag
        );
      end if;
    end checkRaisedText;


  -- resolveLargeStack
  begin

    -- Ищем начало обрезанного предыдущего стека
    previousStackStart :=
      instr(
        oracleErrorStack
        , substr( lastStack.oracleMessage, 1, Min_Stack_Coincidence_Length)
      );
    logger.trace( 'resolveStack: previousStackStart='
      || to_char( previousStackStart)
    );

    -- Если стек был обрезан справа либо полностью сохранён внутри нового
    -- стека
    if previousStackStart > 0
       and lastStack.oracleMessage
         like rtrim(
           substr( oracleErrorStack, previousStackStart)
           , chr(10) || chr(13)
         ) || '%'
    then

      -- Получаем левый "хвост" к предыдущему стеку
      leftTag := substr( oracleErrorStack, 1, previousStackStart-1);
      logger.trace( 'resolveStack: leftTag='
        || '"' || to_char( leftTag) || '"'
      );

      -- Если стек не вырос
      if leftTag is null then
        resolvedLeftTag :=
          case when
            sqlErrorMessage like Ora_Error_Mask || '%'
          then
            substr( sqlErrorMessage, 1, length( Ora_Error_Mask))
            || ' '
          end
          || lastStack.messageText || chr(10);
      else

        -- Проверяем соотвествие сгенерированному исключению
        checkRaisedText;
      end if;

      -- Если сформировали "хвост" для роста стека слева
      if resolvedLeftTag is not null then
        resolvedStack := substr(
          resolvedLeftTag || lastStack.resolvedStack
          , 1
          , Max_Varchar2_Length
        );
      end if;
    end if;
  end resolveLargeStack;



  procedure resolveRemoteLargeStack
  is

    -- Начало текста сгенерированного сообщения
    raisedTextStart integer;

    -- Конец текста сгенерированного сообщения
    raisedTextEnd integer;

    -- Начало текста предыдущего стека в текущем тексте
    previousStackStart integer;

    -- Минимальная длина начала строки для совпадения предыдущего стека с
    -- обрезанным текущим
    Min_Remote_Coincidence_Length constant integer := 100;

  begin

    -- Ищем сгенерированное сообщение
    raisedTextStart :=
      instr( oracleErrorStack, lastStack.raisedText);
    logger.trace( 'resolveRemoteLargeStack: raisedTextStart='
      || to_char( raisedTextStart)
    );
    raisedTextEnd :=
      raisedTextStart + length( lastStack.raisedText) -1;

    -- Если нашли сгенерированное сообщение
    if raisedTextStart > 0
    then

      -- Ищем начало обрезанного предыдущего стека
      previousStackStart :=
        instr(
          substr( oracleErrorStack, raisedTextEnd + 1)
          , substr( lastStack.oracleMessage, 1, Min_Remote_Coincidence_Length)
        )
        + raisedTextEnd;
      logger.trace( 'resolveRemoteLargeStack: previousStackStart='
        || to_char( previousStackStart)
      );

      -- Если стек был обрезан справа либо полностью сохранён внутри нового
      -- стека
      if previousStackStart > raisedTextStart
         and lastStack.oracleMessage
           like rtrim(
             substr( oracleErrorStack, previousStackStart)
             , chr(10) || chr(13)
           ) || '%'
      then
        resolvedStack :=
          substr(
            replace(
              substr( oracleErrorStack, 1, previousStackStart-1)
              , lastStack.raisedText
              , lastStack.messageText
            )
            || lastStack.resolvedStack
            , 1
            , Max_Varchar2_Length
          );
      end if;
    end if;
  end resolveRemoteLargeStack;



-- resolveStack
begin
  sqlErrorMessage := sqlerrm;
  oracleErrorStack := dbms_utility.format_error_stack;
  logger.trace( 'resolveStack: start');
  logger.trace( 'resolveStack: oracleErrorStack="' || oracleErrorStack || '"');
  logger.trace( 'resolveStack: sqlErrorMessage="' || sqlErrorMessage || '"');

  -- Если ошибки нет
  if sqlErrorMessage like 'ORA-000%' then
    sqlErrorMessage := null;
  end if;
  resolvedStack := null;

  -- Если есть предыдущая информация
  if lastStack.raisedText is not null then
    logger.trace( 'resolveStack: previous stack exists');
    logger.trace( 'resolveStack: lastStack.raisedText=' || lastStack.raisedText);
    logger.trace( 'resolveStack: lastStack.oracleMessage=' || lastStack.oracleMessage);
    if oracleErrorStack like
      '%'
      || lastStack.raisedText
      -- Учитываем сообщения о месте ошибки
      || '%'
      || lastStack.oracleMessage
      || '%'
    then
      resolveRegularStack;
    elsif
      -- Стек достаточно большой длины
      length( oracleErrorStack) >= Truncated_Stack_Length
    then
      resolveLargeStack;
    elsif
      -- Стек получен из удалённой базы и достаточно большой длины
      lastStack.isRemote = 1
      and length( oracleErrorStack) >= Truncated_Remote_Stack_Length
    then
      resolveRemoteLargeStack;

      -- Пробуем разобрать сообщение по тому же алгоритму как и для большого
      -- локального стека
      if resolvedStack is null then
        resolveLargeStack;
      end if;
    else
      logger.trace( 'resolveStack: Not regular or large stack');
    end if;

    -- Если не смогли соединить стек
    if resolvedStack is null then
      clearLastStack(
        messageText => 'Сброс предыдущего стека при новой ошибке'
      );
      resolvedStack := oracleErrorStack;
    end if;
  -- Если предыдущего стека не было
  else
    initializeStack;
    resolvedStack := oracleErrorStack;
  end if;
  logger.trace( 'resolveStack: finish');
end resolveStack;

/* iproc: saveLastStack
  Сохраняет содержимое стека
  Присваивает значения элементам записи <lastStack>.
  В случае если длина <lastStack.raisedText> || <lastStack.resolvedStack>
  превышает <Stack_Message_Limit>, то сообщение шифруется.

  Параметры:
  messageText                 - сообщение стека
*/
procedure saveLastStack(
  messageText varchar2
)
is

  nextStackId TMaxVarchar2;

begin
  logger.trace( 'saveLastStack');

  -- Запоминаем состояние стека
  lastStack.raisedText := messageText;
  lastStack.oracleMessage := oracleErrorStack;
  lastStack.messageText := messageText;
  lastStack.resolvedStack := resolvedStack;
  lastStack.isremote := 0;

  -- Если сообщение нужно зашифровать
  if length( lastStack.raisedText || lastStack.oracleMessage) > Stack_Message_Limit then
    nextStackId := getNextStackUid;

    -- Добавляем к nextStackId также возможно обрезанный текст сообщения стека
    lastStack.raisedText :=
      case when
        length(  nextStackId || '<' || messageText || '>')
          > Raised_Message_Limit
      then
        substr(
          nextStackId || '<' || messageText
          , 1
          , Raised_Message_Limit - 4
        )
        || '...>'
      else
        nextStackId || '<' || messageText || '>'
      end;
  end if;
  logger.trace( 'saveLastStack: lastStack.raisedText=' || lastStack.raisedText);
end saveLastStack;

/* iproc: logErrorStackElement
  Логирует информацию об элементе стека с уровнем
  <pkg_Logging.Trace_LevelCode> от имени логера
  пакета <logger>.

  Параметры:
  messageText                - сообщение для логирования
*/
procedure logErrorStackElement(
  messageText varchar2
)
is
begin
  logger.Log(
    levelCode => pkg_Logging.Trace_LevelCode
    , messageText =>
        'MESSAGE: ' || logErrorStackElement.messageText
        || chr(10) || 'ORACLE_ERROR_STACK: ' || oracleErrorStack
        ||
        case when messageText <> lastStack.raisedText then
          chr(10) || 'RAISED: ' || lastStack.raisedText
        end
  );
end logErrorStackElement;

/* func: processStackElement
  Логирует и запоминает параметры элемента стека.
  Возвращает строку для генерации исключения.

  Параметры:
  messageText                 - текст сообщения

  Возврат:
  - текст для генерации исключения, при небольшой длине стека не отличается от
    messageText

  Примечание:
  - может быть вызвана как в блоке обработки исключений, так и вне его.  При
    вызове вне блока исключения, вероятнее стек не сможет быть соединён с
    предыдущим, если он не сброшен.
*/
function processStackElement(
  messageText varchar2
)
return varchar2
is
begin
  resolveStack;
  saveLastStack( messageText => messageText);
  logErrorStackElement(
    messageText => messageText
  );
  logger.trace( 'processStackElement: finish');
  return lastStack.raisedText;
exception when others then
  logger.Error(
    'Ошибка сохранения стека: ('
    || 'message=' || messageText
    || ', sqlerrm=' || sqlerrm
    || ')'
  );
  return messageText;
end processStackElement;

/* proc: logErrorStack
  Очищает стек ошибок. Логирует информацию о стеке с уровнем
  <pkg_Logging.Error_LevelCode>, если удалось связать стек с предыдущей
  информацией.

  Параметры:
  messageText                 - текст дополнительного сообщения
*/
procedure logErrorStack(
  messageText varchar2
)
is
begin
  resolveStack;

  -- Если есть предыдущий стек и он не очищен ( соединён с предыдущим)
  if lastStack.raisedText is not null then
    logCurrentStack(
      messageText => messageText
      , levelCode => pkg_Logging.Error_LevelCode
    );
  end if;
  initializeStack;
  logger.trace( 'logErrorStack: finish');
exception when others then
  logger.Error(
    'Ошибка логирования стека: ('
    || ', messageText="' || messageText || '"'
    || ', sqlerrm="' || sqlerrm || '"'
    || ')'
  );
end logErrorStack;

/* iproc: getRemoteStack
  Получает последний стек ошибок из удалённой базы с помощью <getLastStack> и
  сохраняет данные в <lastStack>.  В случае ошибки при получении стека,
  логирует её с уровнем <pkg_Logging.Error_LevelCode>.

  Параметры:
  dbLink                      - имя линка к БД
*/
procedure getRemoteStack(
  dbLink varchar2
)
is
begin
  logger.trace( 'getRemoteStack: start(' || dblink || ')');
  execute immediate
'begin
  pkg_LoggingErrorStack.getLastStack@' || dbLink || '(
    raisedText => :raisedText
    , oracleMessage => :oracleMessage
    , messageText => :messageText
    , resolvedStack => :resolvedStack
    , callStack => :callStack
  );
end;'
  using
    out lastStack.raisedText
    , out lastStack.oracleMessage
    , out lastStack.messageText
    , out lastStack.resolvedStack
    , out lastStack.callStack
  ;
  lastStack.isremote := 1;
  logger.trace( 'getRemoteStack: finish');
exception when others then
  logger.Warn(
    'Не удалось получить стек ошибок из удалённой базы ('
    || 'dbLink="' || dbLink || '"'
    || ', sqlerrm="' || sqlerrm || '"'
    || ', dbms_utility.format_error_stack="' || dbms_utility.format_error_stack || '"'
    || ')'
  );
end getRemoteStack;

/* func: processRemoteStackElement
  Логирует и запоминает параметры элемента стека, учитывая стек на удалённой
  базе. В случае наличия информации в <body::lastStack>, сначала пытается
  обработать локальный стек

  Параметры:
  messageText                 - текст сообщения
  dbLink                      - имя линка к БД

  Возврат:
  - текст для генерации исключения, при небольшой длине стека не отличается от
    messageText

  Примечание:
  - используется функция <getRemoteStack>;
  - рекомендуется вызывать в блоке обработки исключений;
*/
function processRemoteStackElement(
  messageText varchar2
  , dbLink varchar2
)
return varchar2
is

  isLocalStack boolean := false;

begin

  -- Если есть предыдущий локальный стек
  if lastStack.raisedText is not null then

    -- Пытаемся разрешить локальный стек
    resolveStack;

    -- Если есть предыдущий локальный стек и он соединён с предыдущим
    if lastStack.raisedText is not null then

      -- Обрабатываем локальный стек
      saveLastStack( messageText => messageText);
      logErrorStackElement(
        messageText => messageText
      );
      isLocalStack := true;
    end if;
  end if;
  if isLocalStack then
    logger.trace( 'processRemoteStackElement: LocalStack');
    return
      lastStack.raisedText;
  else
    logger.trace( 'processRemoteStackElement: getRemoteStack');
    getRemoteStack( dbLink => dbLink);
    return
      processStackElement( messageText => messageText);
  end if;
exception when others then
  logger.Error(
    'Ошибка сохранения стека: ('
    || 'message="' || messageText || '"'
    || ', sqlerrm="' || sqlerrm || '"'
    || ', dbms_utility.format_error_stack="' || dbms_utility.format_error_stack || '"'
    || ', dbLink="' || dbLink || '"'
    || ')'
  );
  return messageText;
end processRemoteStackElement;

/* func: getErrorStack
  Получает информацию о стеке ошибок.

  isStackPreserved            - оставлять ли данные по стеку.
                                По-умолчанию ( null) не оставлять ( т.е.
                                очищать), таким образом по-умолчанию после
                                вызова стек не может быть соединён далее.

  Возврат:
  - текст с информацией о стеке

  Примечание:
  - рекомендуется вызывать в блоке обработки исключения;
*/
function getErrorStack(
  isStackPreserved integer := null
)
return varchar2
is
begin
  resolveStack;
  if coalesce( isStackPreserved, 0) = 0 then
    logCurrentStack(
       messageText => 'Стек получен и сброшен'
      , levelCode => pkg_Logging.Trace_LevelCode
    );
    initializeStack;
  end if;
  return
    resolvedStack;
exception when others then
  logger.Error(
    'Ошибка получения стека: ('
    || 'sqlerrm="' || sqlerrm || '"'
    || ', dbms_utility.format_error_stack="' || dbms_utility.format_error_stack || '"'
    || ')'
  );
  return sqlerrm;
end getErrorStack;

/* proc: getLastStack
  Получает данные по последнему стеку.
  Если информация в <body::lastStack> не сброшена,
  возвращает данные <body::lastStack>, иначе возвращает
  данные <body::lastClearedStack>.

  Параметры:
  raisedText                 - сообщение для генерации исключения,
                               возвращаемое функцией <processStackElement>
  oracleMessage              - значение <errorStack> сообщения в стеке
  messageText                - переданный текст сообщения об ошибке
  resolvedStack              - полный расшированный текст сообщения
                               об ошибке
  callStack                  - текст информации о стеке вызовов
*/
procedure getLastStack(
  raisedText               out varchar2
  , oracleMessage          out varchar2
  , messageText            out varchar2
  , resolvedStack          out varchar2
  , callStack              out varchar2
)
is
  resultStack TStack;
begin
  if pkg_LoggingErrorStack.lastStack.raisedText is not null then
    resultStack := pkg_LoggingErrorStack.lastStack;
  else
    resultStack := pkg_LoggingErrorStack.lastClearedStack;
  end if;
  getLastStack.raisedText     := resultStack.raisedText;
  getLastStack.oracleMessage  := resultStack.oracleMessage;
  getLastStack.messageText    := resultStack.messageText;
  getLastStack.resolvedStack  := resultStack.resolvedStack;
  getLastStack.callStack      := resultStack.callStack;
exception when others then
  logger.Error(
    'Ошибка получения данных последнего стека'
  );
end getLastStack;

end pkg_LoggingErrorStack;
/
