create or replace package body pkg_LoggingErrorStack is
/* package body: pkg_LoggingErrorStack::body

  ���������� ��������� ������.

  - ����������� "�����" �����, ���������� � ����������
    � ����� ����� ��� ��� ��������� � ���������� ����������
    ( ��. <logErrorStackElement>, <resolveStack>, <getErrorStack>)
    � ������� <pkg_Logging.Trace_LevelCode>

  - ������������ ���������� ����
    ��� ������������� ����������, ��������, ��� �������
    ����������� ���������� ��� ��������� c ������� <getErrorStack>,
    ��� ��� ������������ ����������� �����
    ( ��. <clearLastStack>, <resolveStack>)
    � ������� <pkg_Logging.Debug_LevelCode>

  - ����������� ����������� ��������
    �����, ��������� � ����� ���������
    ���������� ( <logErrorStack>)
    � ������� <pkg_Logging.Error_LevelCode>

  - ������ ��� ������������� ��������� ������ �����
    �� �������� �� ( ��. <getRemoteStack>)
    � ������� <pkg_Logging.Warn_LevelCode>
*/



/* group: ���� */

/* itype: TMaxVarchar2
  ��� ��� varchar2 ������������ �����
*/
subtype TMaxVarchar2 is varchar2( 32767);

/* itype: TStack
  ������ ����� ������.

  raisedText                 - ��������� ��� ��������� ����������,
                               ������������ �������� <processStackElement>
  oracleMessage              - �������� <errorStack> ��������� � �����
  messageText                - ���������� ����� ��������� �� ������
  resolvedStack              - ������ ������������� ����� ���������
                               �� ������
  callStack                  - ����� ���������� � ����� �������
  isRemote                   - ������� �� ���� �� �������� ���� ( 1-��)
*/
type TStack is record(
  raisedText               TMaxVarchar2
  , oracleMessage          TMaxVarchar2
  , messageText            TMaxVarchar2
  , resolvedStack          TMaxVarchar2
  , callStack              TMaxVarchar2
  , isRemote               integer
);



/* group: ��������� */

/* iconst: Max_Varchar2_Length
  ������������ ����� varchar2
*/
Max_Varchar2_Length constant integer := 32767;

/* iconst: Stack_Message_Limit
  ����� ����� ����� ��������� ����� ������,
  ��� ���������� �������� ��������� ���������
  ����� ������ ����� ��������� � ����� 6512
  � ����� ����������� ����������.
*/
Stack_Message_Limit constant integer := 512 - 60;

/* iconst: Raised_Message_Limit
  ����� ����� ������������� ��������� ����������
  ��� ����������
*/
Raised_Message_Limit constant integer := Stack_Message_Limit;

/* iconst: Truncated_Stack_Length
  ����� ������ ��� �����, ��� ������� �����������
  ��������� ���������� � ���������� ������
*/
Truncated_Stack_Length constant integer := 1000;

/* iconst: Truncated_Remote_Stack_Length
  ����� ������ ��� �����, ��� ������� �����������
  ��������� ���������� � ���������� ������
  ��� ��������� ����� �� �����
*/
Truncated_Remote_Stack_Length constant integer := 512;



/* group: ���������� */



/* group: ���������� � ���������� ��������� ����� */

/* ivar: lastStack
  ��������� ������ ����� ������
  ( ������� ������ ���������� �������� �����)
*/
lastStack TStack;

/* ivar: lastClearedStack
  ������ �� ���������� ����������� �����
  ( �� ���������� ������ ������� <initializeStack>)
*/
lastClearedStack TStack;

/* group: ���������� � ������� ��������� ����� */

/* ivar: errorStack
  ������� ��������� �� ����� ������
  ( ��������� dbms_utility.format_error_stack)
*/
oracleErrorStack TMaxVarchar2;

/* ivar: resolvedStack
  ������ ������������� ����� �������� ���������
  �� ������
*/
resolvedStack TMaxVarchar2;



/* group: ������ ���������� */

/* ivar: errorStackSessionId
  Id ��� ����� ��������� ��� ��������,
  ������������� � ������ ������
*/
errorStackSessionId varchar2(50) := null;

/* ivar: errorStackId
  Id ��� ����� ��������� ��� ��������,
  �������� �������� ��������� � ��������
  ������ ������
*/
errorStackId integer := 0;

/* ivar: logger
  ������������ ������ � ������ Logging
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName => pkg_Logging.Module_Name
  , objectName => 'pkg_LoggingErrorStack'
);



/* group: ������� */

/* ifunc: getNextStackUid
  ��������� ������ ��� �������� ���������� ���������
  �� ������
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
  ������������� ���������� � �����
  � ���������� <lastClearedStack>.
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
  �������� � ���������� �
  ���������� � ���������� ����� ������

  ���������:
  messageText                 - ��������� ��� �����������
                                ���� �� ������, ����������
                                ��������� ��-���������.

  ����������:
  - ����� ���� ������� ��� � ����� ��������� ����������, ��� � ��� ���.
*/
procedure clearLastStack(
  messageText varchar2
)
is
begin
  logger.trace(
    'Stack saved ( lastClearedStack.raisedText="' || lastClearedStack.raisedText || '")'
  );

  -- ���� ���������� ���� ������
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
  ���������� ���������� � ���������� ����� ������

  ����������:
  - ����� ���� ������� ��� � ����� ��������� ����������,
    ��� � ��� ���.
  - �������� <clearLastStack(messageText)>
    � ���������� "����� �����"
*/
procedure clearLastStack
is
begin
  clearLastStack(
    messageText => '����� �����'
  );
end clearLastStack;

/* iproc: logCurrentStack
  �������� ���������� � ������� �����

  ���������:
  messageText                 - ����� ��������������� ���������
  levelCode                   - ������� �����������

  ����������:
  - ������ ���������� ����� ������ <resolveStack>
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
  ����������� �������� <oracleErrorStack>.
  �������� ������� ���������� � ���������� ��������� �����
  � ���������� �������� �����, ���� ��� ����. ���� ��� �� ������,
  �������� <clearLastStack>.
  ����������� �������� <resolvedStack>.

  ����������:
  - ��� ���������� �����
    ������ ���������� � ����� ��������� ����������.
    ��� ������ ��� ����� ��������� ����������,
    ������� <clearLastStack>
*/
procedure resolveStack
is

  -- �������� sqlerrm
  sqlErrorMessage TMaxVarchar2;



  /*
    ��������� ������������ ���� � ����������
  */
  procedure resolveRegularStack
  is

    -- ������ ������ ����������� ����� � ������� ������
    previousStackStart integer;

    -- ����� ������ ����������� �����
    previousStackEnd integer;

  begin
    previousStackStart := instr( oracleErrorStack, lastStack.oracleMessage);
    if previousStackStart > 0 then

      -- �������� ����� ����� ����������� �����
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

      -- ���� ���������� ���� �� ������ � �������, �� ������ ����� ����������
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
    ��������� ���������� ���� � ����������
  */
  procedure resolveLargeStack
  is

    -- ������ ������ ����������� ����� � ������� ������
    previousStackStart integer;

    -- "�����" � ����������� ����� �����
    leftTag TMaxVarchar2;

    -- ����������� ����� "�����" � ����������� ����� �����
    resolvedLeftTag TMaxVarchar2;

    -- ����������� ����� ������ ������ ��� ���������� ����������� ����� �
    -- ���������� �������
    Min_Stack_Coincidence_Length constant integer := 300;

    -- ����� ������ ��� ������ ������ Oracle
    Ora_Error_Mask varchar2( 50 ) := 'ORA-_____:';



    /*
      ����� � ������ ������ ����������� ���������������� ���������
      ( lastStack.raisedText) �� ��������� ����������� �����
      (lastStack.messageText) � ����� "������" ����� ( leftTag)
    */
    procedure checkRaisedText
    is

      -- ������ � ����� �������� ���������� ������ �����������
      -- ���������������� ���������
      raisedTextStart integer;
      raisedTextEnd integer;

      -- ������� ������� ����� ������
      triedEnd integer;

      -- ���������� ��� ������ �� ������������
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

          -- ������� ������������� � ����� ������� ������
          triedEnd :=
            instr(
              leftTag
              , chr(10)
              , raisedTextEnd + 2
            ) - 1;

          -- �������, ���� ������ ����� raisedTextStart � triedEnd ��� ��
          -- ���������� � lastStack.raisedText
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

          -- ���������� ���������� �� ��������� ������
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

      -- ���� ������������ ���������� ������ ���������� ( �������� ������), ��
      -- �������� �
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
        -- ���� ��������� ����� ��������� ��� ������������� ��������� �����
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

    -- ���� ������ ����������� ����������� �����
    previousStackStart :=
      instr(
        oracleErrorStack
        , substr( lastStack.oracleMessage, 1, Min_Stack_Coincidence_Length)
      );
    logger.trace( 'resolveStack: previousStackStart='
      || to_char( previousStackStart)
    );

    -- ���� ���� ��� ������� ������ ���� ��������� ������� ������ ������
    -- �����
    if previousStackStart > 0
       and lastStack.oracleMessage
         like rtrim(
           substr( oracleErrorStack, previousStackStart)
           , chr(10) || chr(13)
         ) || '%'
    then

      -- �������� ����� "�����" � ����������� �����
      leftTag := substr( oracleErrorStack, 1, previousStackStart-1);
      logger.trace( 'resolveStack: leftTag='
        || '"' || to_char( leftTag) || '"'
      );

      -- ���� ���� �� �����
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

        -- ��������� ����������� ���������������� ����������
        checkRaisedText;
      end if;

      -- ���� ������������ "�����" ��� ����� ����� �����
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

    -- ������ ������ ���������������� ���������
    raisedTextStart integer;

    -- ����� ������ ���������������� ���������
    raisedTextEnd integer;

    -- ������ ������ ����������� ����� � ������� ������
    previousStackStart integer;

    -- ����������� ����� ������ ������ ��� ���������� ����������� ����� �
    -- ���������� �������
    Min_Remote_Coincidence_Length constant integer := 100;

  begin

    -- ���� ��������������� ���������
    raisedTextStart :=
      instr( oracleErrorStack, lastStack.raisedText);
    logger.trace( 'resolveRemoteLargeStack: raisedTextStart='
      || to_char( raisedTextStart)
    );
    raisedTextEnd :=
      raisedTextStart + length( lastStack.raisedText) -1;

    -- ���� ����� ��������������� ���������
    if raisedTextStart > 0
    then

      -- ���� ������ ����������� ����������� �����
      previousStackStart :=
        instr(
          substr( oracleErrorStack, raisedTextEnd + 1)
          , substr( lastStack.oracleMessage, 1, Min_Remote_Coincidence_Length)
        )
        + raisedTextEnd;
      logger.trace( 'resolveRemoteLargeStack: previousStackStart='
        || to_char( previousStackStart)
      );

      -- ���� ���� ��� ������� ������ ���� ��������� ������� ������ ������
      -- �����
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

  -- ���� ������ ���
  if sqlErrorMessage like 'ORA-000%' then
    sqlErrorMessage := null;
  end if;
  resolvedStack := null;

  -- ���� ���� ���������� ����������
  if lastStack.raisedText is not null then
    logger.trace( 'resolveStack: previous stack exists');
    logger.trace( 'resolveStack: lastStack.raisedText=' || lastStack.raisedText);
    logger.trace( 'resolveStack: lastStack.oracleMessage=' || lastStack.oracleMessage);
    if oracleErrorStack like
      '%'
      || lastStack.raisedText
      -- ��������� ��������� � ����� ������
      || '%'
      || lastStack.oracleMessage
      || '%'
    then
      resolveRegularStack;
    elsif
      -- ���� ���������� ������� �����
      length( oracleErrorStack) >= Truncated_Stack_Length
    then
      resolveLargeStack;
    elsif
      -- ���� ������� �� �������� ���� � ���������� ������� �����
      lastStack.isRemote = 1
      and length( oracleErrorStack) >= Truncated_Remote_Stack_Length
    then
      resolveRemoteLargeStack;

      -- ������� ��������� ��������� �� ���� �� ��������� ��� � ��� ��������
      -- ���������� �����
      if resolvedStack is null then
        resolveLargeStack;
      end if;
    else
      logger.trace( 'resolveStack: Not regular or large stack');
    end if;

    -- ���� �� ������ ��������� ����
    if resolvedStack is null then
      clearLastStack(
        messageText => '����� ����������� ����� ��� ����� ������'
      );
      resolvedStack := oracleErrorStack;
    end if;
  -- ���� ����������� ����� �� ����
  else
    initializeStack;
    resolvedStack := oracleErrorStack;
  end if;
  logger.trace( 'resolveStack: finish');
end resolveStack;

/* iproc: saveLastStack
  ��������� ���������� �����
  ����������� �������� ��������� ������ <lastStack>.
  � ������ ���� ����� <lastStack.raisedText> || <lastStack.resolvedStack>
  ��������� <Stack_Message_Limit>, �� ��������� ���������.

  ���������:
  messageText                 - ��������� �����
*/
procedure saveLastStack(
  messageText varchar2
)
is

  nextStackId TMaxVarchar2;

begin
  logger.trace( 'saveLastStack');

  -- ���������� ��������� �����
  lastStack.raisedText := messageText;
  lastStack.oracleMessage := oracleErrorStack;
  lastStack.messageText := messageText;
  lastStack.resolvedStack := resolvedStack;
  lastStack.isremote := 0;

  -- ���� ��������� ����� �����������
  if length( lastStack.raisedText || lastStack.oracleMessage) > Stack_Message_Limit then
    nextStackId := getNextStackUid;

    -- ��������� � nextStackId ����� �������� ���������� ����� ��������� �����
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
  �������� ���������� �� �������� ����� � �������
  <pkg_Logging.Trace_LevelCode> �� ����� ������
  ������ <logger>.

  ���������:
  messageText                - ��������� ��� �����������
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
  �������� � ���������� ��������� �������� �����.
  ���������� ������ ��� ��������� ����������.

  ���������:
  messageText                 - ����� ���������

  �������:
  - ����� ��� ��������� ����������, ��� ��������� ����� ����� �� ���������� ��
    messageText

  ����������:
  - ����� ���� ������� ��� � ����� ��������� ����������, ��� � ��� ���.  ���
    ������ ��� ����� ����������, ��������� ���� �� ������ ���� ������� �
    ����������, ���� �� �� �������.
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
    '������ ���������� �����: ('
    || 'message=' || messageText
    || ', sqlerrm=' || sqlerrm
    || ')'
  );
  return messageText;
end processStackElement;

/* proc: logErrorStack
  ������� ���� ������. �������� ���������� � ����� � �������
  <pkg_Logging.Error_LevelCode>, ���� ������� ������� ���� � ����������
  �����������.

  ���������:
  messageText                 - ����� ��������������� ���������
*/
procedure logErrorStack(
  messageText varchar2
)
is
begin
  resolveStack;

  -- ���� ���� ���������� ���� � �� �� ������ ( ������� � ����������)
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
    '������ ����������� �����: ('
    || ', messageText="' || messageText || '"'
    || ', sqlerrm="' || sqlerrm || '"'
    || ')'
  );
end logErrorStack;

/* iproc: getRemoteStack
  �������� ��������� ���� ������ �� �������� ���� � ������� <getLastStack> �
  ��������� ������ � <lastStack>.  � ������ ������ ��� ��������� �����,
  �������� � � ������� <pkg_Logging.Error_LevelCode>.

  ���������:
  dbLink                      - ��� ����� � ��
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
    '�� ������� �������� ���� ������ �� �������� ���� ('
    || 'dbLink="' || dbLink || '"'
    || ', sqlerrm="' || sqlerrm || '"'
    || ', dbms_utility.format_error_stack="' || dbms_utility.format_error_stack || '"'
    || ')'
  );
end getRemoteStack;

/* func: processRemoteStackElement
  �������� � ���������� ��������� �������� �����, �������� ���� �� ��������
  ����. � ������ ������� ���������� � <body::lastStack>, ������� ��������
  ���������� ��������� ����

  ���������:
  messageText                 - ����� ���������
  dbLink                      - ��� ����� � ��

  �������:
  - ����� ��� ��������� ����������, ��� ��������� ����� ����� �� ���������� ��
    messageText

  ����������:
  - ������������ ������� <getRemoteStack>;
  - ������������� �������� � ����� ��������� ����������;
*/
function processRemoteStackElement(
  messageText varchar2
  , dbLink varchar2
)
return varchar2
is

  isLocalStack boolean := false;

begin

  -- ���� ���� ���������� ��������� ����
  if lastStack.raisedText is not null then

    -- �������� ��������� ��������� ����
    resolveStack;

    -- ���� ���� ���������� ��������� ���� � �� ������� � ����������
    if lastStack.raisedText is not null then

      -- ������������ ��������� ����
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
    '������ ���������� �����: ('
    || 'message="' || messageText || '"'
    || ', sqlerrm="' || sqlerrm || '"'
    || ', dbms_utility.format_error_stack="' || dbms_utility.format_error_stack || '"'
    || ', dbLink="' || dbLink || '"'
    || ')'
  );
  return messageText;
end processRemoteStackElement;

/* func: getErrorStack
  �������� ���������� � ����� ������.

  isStackPreserved            - ��������� �� ������ �� �����.
                                ��-��������� ( null) �� ��������� ( �.�.
                                �������), ����� ������� ��-��������� �����
                                ������ ���� �� ����� ���� ������� �����.

  �������:
  - ����� � ����������� � �����

  ����������:
  - ������������� �������� � ����� ��������� ����������;
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
       messageText => '���� ������� � �������'
      , levelCode => pkg_Logging.Trace_LevelCode
    );
    initializeStack;
  end if;
  return
    resolvedStack;
exception when others then
  logger.Error(
    '������ ��������� �����: ('
    || 'sqlerrm="' || sqlerrm || '"'
    || ', dbms_utility.format_error_stack="' || dbms_utility.format_error_stack || '"'
    || ')'
  );
  return sqlerrm;
end getErrorStack;

/* proc: getLastStack
  �������� ������ �� ���������� �����.
  ���� ���������� � <body::lastStack> �� ��������,
  ���������� ������ <body::lastStack>, ����� ����������
  ������ <body::lastClearedStack>.

  ���������:
  raisedText                 - ��������� ��� ��������� ����������,
                               ������������ �������� <processStackElement>
  oracleMessage              - �������� <errorStack> ��������� � �����
  messageText                - ���������� ����� ��������� �� ������
  resolvedStack              - ������ ������������� ����� ���������
                               �� ������
  callStack                  - ����� ���������� � ����� �������
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
    '������ ��������� ������ ���������� �����'
  );
end getLastStack;

end pkg_LoggingErrorStack;
/
