declare



subtype maxVarchar2 is varchar2( 32767);
  Max_Varchar2_Length constant integer := 32767;

lastRaisedText maxVarchar2 := '___DSD';


lastMessageText maxVarchar2 := '___';

sqlErrorMessage maxVarchar2 := '___';

resolvedStack maxVarchar2;

lastResolvedStack  maxVarchar2;


/* ivar: logger
  Интерфейсный объект к модулю Logging
*/
  logger lg_logger_t := lg_logger_t.getLogger(
    moduleName => pkg_Mail.Module_Name
    , objectName => 'pkg_LoggingErrorStack'
  );
  errorStack varchar2( 32767) :=
'ORA-20015:' || chr(32) || '
ORA-06512: на  line
ORA-20014: Error ____________________________________________________________________________________________________14
ORA-06512: на  line
ORA-20013: Error ____________________________________________________________________________________________________13
ORA-06512: на  "DOCUMENT.DROP_ME_TMP13", line 5
ORA-20012: Error ____________________________________________________________________________________________________12
ORA-06512: на  "DOCUMENT.DROP_ME_TMP12", line 5
ORA-20011: Error ____________________________________________________________________________________________________11
ORA-06512: на  "DOCUMENT.DROP_ME_TMP11", line 5
ORA-20010: Error ____________________________________________________________________________________________________10
ORA-06512: на  "DOCUMENT.DROP_ME_TMP10", line 5
ORA-20009: Error ____________________________________________________________________________________________________9
ORA-06512: на  "DOCUMENT.DROP_ME_TMP9", line 5
ORA-20008: Error ____________________________________________________________________________________________________8
ORA-06512: на  "DOCUMENT.DROP_ME_TMP8", line 5
ORA-20007: Error ____________________________________________________________________________________________________7
ORA-06512: на  "DOCUMENT.DROP_ME_TMP7", line 5
ORA-20006: Error ____________________________________________________________________________________________________6
ORA-06512: на  "DOCUMENT.DROP_ME_TMP6", line 5
ORA-20005: Error ____________________________________________________________________________________________________5
ORA-06512: на  "DOCUMENT.DROP_ME_TMP5", line 5
ORA-20004: Error ____________________________________________________________________________________________________4
ORA-06512: на  "DOCUMENT.DROP_ME_TMP4", line 5
ORA-20003: Error _______________________________________
';
  lastErrorStack  varchar2( 32767) :=
'ORA-20014: Error ____________________________________________________________________________________________________14
ORA-06512: на  line
ORA-20013: Error ____________________________________________________________________________________________________13
ORA-06512: на  "DOCUMENT.DROP_ME_TMP13", line 5
ORA-20012: Error ____________________________________________________________________________________________________12
ORA-06512: на  "DOCUMENT.DROP_ME_TMP12", line 5
ORA-20011: Error ____________________________________________________________________________________________________11
ORA-06512: на  "DOCUMENT.DROP_ME_TMP11", line 5
ORA-20010: Error ____________________________________________________________________________________________________10
ORA-06512: на  "DOCUMENT.DROP_ME_TMP10", line 5
ORA-20009: Error ____________________________________________________________________________________________________9
ORA-06512: на  "DOCUMENT.DROP_ME_TMP9", line 5
ORA-20008: Error ____________________________________________________________________________________________________8
ORA-06512: на  "DOCUMENT.DROP_ME_TMP8", line 5
ORA-20007: Error ____________________________________________________________________________________________________7
ORA-06512: на  "DOCUMENT.DROP_ME_TMP7", line 5
ORA-20006: Error ____________________________________________________________________________________________________6
ORA-06512: на  "DOCUMENT.DROP_ME_TMP6", line 5
ORA-20005: Error ____________________________________________________________________________________________________5
ORA-06512: на  "DOCUMENT.DROP_ME_TMP5", line 5
ORA-20004: Error ____________________________________________________________________________________________________4
ORA-06512: на  "DOCUMENT.DROP_ME_TMP4", line 5
ORA-20003: Error ________________________________________________________________________';


  procedure ResolveLargeStack
  is
  -- Соединяет обрезанный стек с предыдущим
                                       -- Начало текста предыдущего стека
                                       -- в текущем тексте
    previousStackStart integer;
                                       -- "Хвост" к предыдущему стеку
                                       -- слева
    leftTag maxVarchar2;
                                       -- Формируемый новый
                                       -- "хвост" к предыдущему стеку
                                       -- слева
    resolvedLeftTag maxVarchar2;

    Ora_Error_Mask varchar2( 50 ) := 'ORA-_____:';
  begin
                                       -- Ищем начало обрезанного
                                       -- предыдущего стека
    previousStackStart :=
      instr(
        errorStack
        , substr( lastErrorStack, 1, 300)
      );
    logger.Debug( 'ResolveStack: previousStackStart='
      || to_char( previousStackStart)
    );
    logger.Debug( 'ResolveStack: substr( errorStack, previousStackStart)='
      || substr( errorStack, previousStackStart)
    );
    logger.Debug( 'ResolveStack: lastErrorStack='
      || lastErrorStack
    );
    logger.Debug( 'ResolveStack: errorStack='
      || replace( to_char( errorStack), chr(10), '\\10\\')
    );
    logger.Debug( 'ResolveStack: errorStack='
      || errorStack
    );
    if lastErrorStack like substr( errorStack, previousStackStart) || '%' then
      logger.Debug('true');
    end if;
                                       -- Если стек был обрезан справа
                                       -- либо полностью сохранён внутри нового стека
    if previousStackStart > 0
       and lastErrorStack like rtrim( substr( errorStack, previousStackStart),chr(10) || chr(13)) || '%'
    then
                                       -- Получаем левый "хвост"
                                       -- к предыдущему стеку
      leftTag := substr( errorStack, 1, previousStackStart-1);
      logger.Debug( 'ResolveStack: leftTag='
        || replace( to_char( leftTag), chr(10), '\\10\\')
      );
      logger.Debug( 'ResolveStack: mask='
        ||
        replace( Ora_Error_Mask || ' ' || chr(10)
        || Ora_Error_Mask || '%' || 'line' || '%' || chr(10)
          , chr(10) , '\\10\\'
        )
      );
      if leftTag like
          Ora_Error_Mask || ' ' || chr(10)
          || Ora_Error_Mask || '%' || 'line' || '%' || chr(10)
        and length( leftTag) < 50
      then
        outputmessage( 'like true');
      end if;
                                       -- сгенерированного исключения,
      if leftTag like '%' || lastRaisedText || '%' then
                                       -- то заменяем её на предыдущее сообщение
        resolvedLeftTag :=
          replace( leftTag, lastRaisedText, lastMessageText);
        outputmessage( 'like 1');
                                       -- Если стек не вырос
      elsif leftTag is null then
        resolvedLeftTag :=
          case when
            sqlErrorMessage like Ora_Error_Mask || '%'
          then
            substr( sqlErrorMessage, 1, length( Ora_Error_Mask))
            || ' '
          end
          || lastMessageText || chr(10);
        outputmessage( 'like 2');
      elsif
                                       -- Если стек вырос слева
                                       -- на вырожденные сообщения
        leftTag like
          Ora_Error_Mask || ' ' || chr(10)
          || Ora_Error_Mask || '%' || 'line' || '%' || chr(10)
        and length( leftTag) < 50
      then
        outputmessage( 'leftTag like');
        resolvedLeftTag :=
          substr( leftTag, 1, length( Ora_Error_Mask)) || ' '
          || lastMessageText || chr(10);
      else
        resolvedLeftTag := null;
      end if;
                                       -- Если сформировали
                                       -- "хвост" для роста стека
                                       -- слева
      if resolvedLeftTag is not null then
        resolvedStack := substr(
          resolvedLeftTag || lastResolvedStack
          , 1
          , Max_Varchar2_Length
        );
      end if;
    end if;
  end ResolveLargeStack;

begin
  ResolveLargeStack;
end;
/
select length('ORA-20015: \\10\\ORA-06512: на  line\\10\\') from dual
/
select case when  'ORA-20015: \\10\\ORA-06512: на  line\\10\\' like 'ORA-_____: \\10\\ORA-_____:%line%\\10\\' then 1 else 0 end from dual
