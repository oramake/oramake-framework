create or replace package body pkg_LoggingErrorStack is
/* package body: pkg_LoggingErrorStack::body

  ���������� ��������� ������.

  - ����������� "�����" �����, ���������� � ����������
    � ����� ����� ��� ��� ��������� � ���������� ����������
    ( ��. <LogErrorStackElement>, <ResolveStack>, <GetErrorStack>)
    � ������� <pkg_Logging.Trace_LevelCode> 

  - ������������ ���������� ����
    ��� ������������� ����������, ��������, ��� �������
    ����������� ���������� ��� ��������� c ������� <GetErrorStack>,
    ��� ��� ������������ ����������� �����
    ( ��. <ClearLastStack>, <ResolveStack>)
    � ������� <pkg_Logging.Debug_LevelCode> 

  - ����������� ����������� ��������
    �����, ��������� � ����� ���������
    ���������� ( <LogErrorStack>)
    � ������� <pkg_Logging.Error_LevelCode> 

  - ������ ��� ������������� ��������� ������ �����
    �� �������� �� ( ��. <GetRemoteStack>)
    � ������� <pkg_Logging.Warning_LevelCode> 
*/

/* group: ���� */

/* itype: TMaxVarchar2
  ��� ��� varchar2 ������������ �����
*/
subtype TMaxVarchar2 is varchar2( 32767);

/* itype: TStack 
  ������ ����� ������.

  raisedText                 - ��������� ��� ��������� ����������,
                               ������������ �������� <ProcessStackElement>
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

/* group: ���������� � ���������� ��������� ����� */

/* ivar: lastStack
  ��������� ������ ����� ������
  ( ������� ������ ���������� �������� �����)
*/
  lastStack TStack;

/* ivar: lastClearedStack
  ������ �� ���������� ����������� �����
  ( �� ���������� ������ ������� <InitializeStack>)
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
  logger lg_logger_t := lg_logger_t.GetLogger(
    moduleName => pkg_Logging.Module_Name
    , objectName => 'pkg_LoggingErrorStack'
  );

/* group: ��������� � ������� */

/* func: GetNextStackUid
  ��������� ������ ��� �������� ���������� ���������
  �� ������
*/
function GetNextStackUid
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
end GetNextStackUid;

/* proc: InitializeStack
  ������������� ���������� � �����
  � ���������� <lastClearedStack>.
*/
procedure InitializeStack
is
begin
  logger.Trace( 'InitializeStack: start');
  lastClearedStack := lastStack;
  lastStack.callStack := dbms_utility.format_call_stack;
  lastStack.raisedText := null;
  lastStack.oracleMessage := null;
  lastStack.messageText := null;
  lastStack.resolvedStack := null;
  lastStack.isRemote := null;
  logger.Trace( 'InitializeStack: end');
end InitializeStack;

/* proc: ClearLastStack(messageText)
  �������� � ���������� �
  ���������� � ���������� ����� ������

  ���������:
  messageText                 - ��������� ��� �����������
                                ���� �� ������, ����������
                                ��������� ��-���������.

  ����������:
    - ����� ���� ������� ��� � ����� ��������� ����������,
      ��� � ��� ���.
*/
procedure ClearLastStack(
  messageText varchar2
)
is
begin
  logger.Trace( 
    'Stack saved ( lastClearedStack.raisedText="' || lastClearedStack.raisedText || '")'
  );
                                       -- ���� ���������� ����
                                       -- ������
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
  InitializeStack;
end ClearLastStack;

/* proc: ClearLastStack
  ���������� ���������� � ���������� ����� ������

  ����������:
    - ����� ���� ������� ��� � ����� ��������� ����������,
      ��� � ��� ���.
    - �������� <ClearLastStack(messageText)>
      � ���������� "����� �����"
*/
procedure ClearLastStack
is
begin
  ClearLastStack(
    messageText => '����� �����'
  );
end ClearLastStack;


/* proc: LogCurrentStack
  �������� ���������� � ������� �����

  ���������:
  messageText                 - ����� ��������������� ���������
  levelCode                   - ������� �����������

  ����������:
    - ������ ���������� ����� ������ <ResolveStack>
*/
procedure LogCurrentStack(
  messageText varchar2
  , levelCode varchar2
)
is
begin
  logger.Trace( 'LogCurrentStack');
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
end LogCurrentStack;

/* proc: ResolveStack
  ����������� �������� <oracleErrorStack>.
  �������� ������� ���������� � ���������� ��������� �����
  � ���������� �������� �����, ���� ��� ����. ���� ��� �� ������,
  �������� <ClearLastStack>.
  ����������� �������� <resolvedStack>.

  ����������:
    - ��� ���������� �����
      ������ ���������� � ����� ��������� ����������.
      ��� ������ ��� ����� ��������� ����������,
      ������� <ClearLastStack>
*/
procedure ResolveStack
is
                                       -- �������� sqlerrm
  sqlErrorMessage TMaxVarchar2;

  procedure ResolveRegularStack
  is
  -- ��������� ������������ ���� � ����������
                                       -- ������ ������ ����������� �����
                                       -- � ������� ������
    previousStackStart integer;
                                       -- ����� ������ ����������� �����
    previousStackEnd integer;
  begin
    previousStackStart := instr( oracleErrorStack, lastStack.oracleMessage);
    if previousStackStart > 0 then
                                       -- �������� ����� ����� �����������
                                       -- �����
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
                                       -- ���� ���������� ���� �� ������
                                       -- � �������, �� ������ �����
                                       -- ����������
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
  end ResolveRegularStack;

  procedure ResolveLargeStack
  is
  -- ��������� ���������� ���� � ����������
                                       -- ������ ������ ����������� �����
                                       -- � ������� ������
    previousStackStart integer;
                                       -- "�����" � ����������� �����
                                       -- �����
    leftTag TMaxVarchar2;
                                       -- ����������� �����
                                       -- "�����" � ����������� �����
                                       -- �����
    resolvedLeftTag TMaxVarchar2;
                                       -- ����������� ����� ������
                                       -- ������ ��� ����������
                                       -- ����������� ����� � ���������� �������
    Min_Stack_Coincidence_Length constant integer := 300;
                                       -- ����� ������ ��� ������ ������
                                       -- Oracle
    Ora_Error_Mask varchar2( 50 ) := 'ORA-_____:';

    procedure CheckRaisedText
    is
    -- ����� � ������ ������
    -- ����������� ���������������� ��������� ( lastStack.raisedText)
    -- �� ��������� ����������� ����� (lastStack.messageText)
    -- � ����� "������" ����� ( leftTag)
                                       -- ������ � ����� �������� ����������
                                       -- ������ �����������
                                       -- ���������������� ���������
      raisedTextStart integer;
      raisedTextEnd integer;
                                       -- ������� ������� ����� ������
      triedEnd integer;
                                       -- ���������� ��� ������ �� ������������
      safeCycle integer := 0;
    begin
      logger.Trace(
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
        logger.Trace( 'ReplaceRaisedText: raisedTextStart='
          || to_char( raisedTextStart)
        );

        raisedTextEnd := raisedTextStart -1;
        loop
                                       -- ������� �������������
                                       -- � ����� ������� ������
          triedEnd :=
            instr(
              leftTag
              , chr(10)
              , raisedTextEnd + 2
            ) - 1;
                                       -- �������, ����
                                       -- ������ �����
                                       -- raisedTextStart � triedEnd
                                       -- ��� �� ���������� � lastStack.raisedText
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
                                       -- ���������� ����������
                                       -- �� ��������� ������
          raisedTextEnd := triedEnd;
          logger.Trace( 'ReplaceRaisedText: raisedTextEnd= '
            || to_char( raisedTextEnd)
          );
        end loop;
        if safeCycle > 20 then
          logger.Debug( 'ResolveLargeStack: ReplaceRaisedText: safeCycle worked' );
        end if;
      end if;
      logger.Trace( 'ReplaceRaisedText: remains='
        || '"' || substr( leftTag, raisedTextEnd +1 ) || '"'
      );
                                       -- ���� ������������
                                       -- ���������� ������
                                       -- ���������� ( �������� ������),
                                       -- �� �������� �
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
                                       -- ���� ��������� �����
                                       -- ��������� ��� ������������� ��������� �����
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
        logger.Trace( 'ReplaceRaisedText: resolvedLeftTag='
          || resolvedLeftTag
        );
      end if;
    end CheckRaisedText;

  begin
                                       -- ���� ������ �����������
                                       -- ����������� �����
    previousStackStart :=
      instr(
        oracleErrorStack
        , substr( lastStack.oracleMessage, 1, Min_Stack_Coincidence_Length)
      );
    logger.Trace( 'ResolveStack: previousStackStart='
      || to_char( previousStackStart)
    );
                                       -- ���� ���� ��� ������� ������
                                       -- ���� ��������� ������� ������ ������ �����
    if previousStackStart > 0
       and lastStack.oracleMessage
         like rtrim(
           substr( oracleErrorStack, previousStackStart)
           , chr(10) || chr(13)
         ) || '%'
    then
                                       -- �������� ����� "�����"
                                       -- � ����������� �����
      leftTag := substr( oracleErrorStack, 1, previousStackStart-1);
      logger.Trace( 'ResolveStack: leftTag='
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
                                       -- ��������� �����������
                                       -- ���������������� ����������
        CheckRaisedText;
      end if;
                                       -- ���� ������������
                                       -- "�����" ��� ����� �����
                                       -- �����
      if resolvedLeftTag is not null then
        resolvedStack := substr(
          resolvedLeftTag || lastStack.resolvedStack
          , 1
          , Max_Varchar2_Length
        );
      end if;
    end if;
  end ResolveLargeStack;
  
  procedure ResolveRemoteLargeStack
  is
                                       -- ������ ������ ���������������� 
                                       -- ���������
    raisedTextStart integer;
                                       -- ����� ������ ���������������� 
                                       -- ���������
    raisedTextEnd integer;
                                       -- ������ ������ ����������� �����
                                       -- � ������� ������
    previousStackStart integer;
                                       -- ����������� ����� ������
                                       -- ������ ��� ����������
                                       -- ����������� ����� � ���������� �������
    Min_Remote_Coincidence_Length constant integer := 100;
  begin
                                       -- ���� ��������������� ���������
    raisedTextStart := 
      instr( oracleErrorStack, lastStack.raisedText);
    logger.Trace( 'ResolveRemoteLargeStack: raisedTextStart='
      || to_char( raisedTextStart)
    );       
    raisedTextEnd := 
      raisedTextStart + length( lastStack.raisedText) -1;  
                                       -- ���� ����� ��������������� ���������
    if raisedTextStart > 0 
    then 
                                       -- ���� ������ �����������
                                       -- ����������� �����
      previousStackStart :=
        instr(
          substr( oracleErrorStack, raisedTextEnd + 1)
          , substr( lastStack.oracleMessage, 1, Min_Remote_Coincidence_Length)
        )
        + raisedTextEnd;
      logger.Trace( 'ResolveRemoteLargeStack: previousStackStart='
        || to_char( previousStackStart)
      );       
                                       -- ���� ���� ��� ������� ������
                                       -- ���� ��������� ������� ������ ������ �����
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
  end ResolveRemoteLargeStack;

begin
  sqlErrorMessage := sqlerrm;
  oracleErrorStack := dbms_utility.format_error_stack;
  logger.Trace( 'ResolveStack: start');
  logger.Trace( 'ResolveStack: oracleErrorStack="' || oracleErrorStack || '"');
  logger.Trace( 'ResolveStack: sqlErrorMessage="' || sqlErrorMessage || '"');
                                       -- ���� ������ ���
  if sqlErrorMessage like 'ORA-000%' then
    sqlErrorMessage := null;
  end if;
  resolvedStack := null;
                                       -- ���� ���� ���������� ����������
  if lastStack.raisedText is not null then
    logger.Trace( 'ResolveStack: previous stack exists');
    logger.Trace( 'ResolveStack: lastStack.raisedText=' || lastStack.raisedText);
    logger.Trace( 'ResolveStack: lastStack.oracleMessage=' || lastStack.oracleMessage);
    if oracleErrorStack like
      '%'
      || lastStack.raisedText
                                       -- ��������� ��������� � �����
                                       -- ������
      || '%'
      || lastStack.oracleMessage
      || '%'
    then
      ResolveRegularStack;
    elsif
                                       -- ���� ���������� ������� �����
      length( oracleErrorStack) >= Truncated_Stack_Length
    then
      ResolveLargeStack;
    elsif
                                       -- ���� ������� �� �������� ����
                                       -- � ���������� ������� �����
      lastStack.isRemote = 1 
      and length( oracleErrorStack) >= Truncated_Remote_Stack_Length
    then
      ResolveRemoteLargeStack;  
                                       -- ������� ��������� ���������
                                       -- �� ���� �� ��������� ��� � ���
                                       -- �������� ���������� �����
      if resolvedStack is null then 
        ResolveLargeStack;
      end if;
    else
      logger.Trace( 'ResolveStack: Not regular or large stack');  
    end if;
                                       -- ���� �� ������ ���������
                                       -- ����
    if resolvedStack is null then
      ClearLastStack(
        messageText => '����� ����������� ����� ��� ����� ������'
      );
      resolvedStack := oracleErrorStack;
    end if;
                                       -- ���� ����������� ����� �� ����
  else
    InitializeStack;
    resolvedStack := oracleErrorStack;
  end if;
  logger.Trace( 'ResolveStack: finish');
end ResolveStack;

/* func: SaveLastStack
  ��������� ���������� �����
  ����������� �������� ��������� ������ <lastStack>.
  � ������ ���� ����� <lastStack.raisedText> || <lastStack.resolvedStack> ���������
  <Stack_Message_Limit>, �� ��������� ���������.

  ���������:
  messageText                - ��������� �����
*/
procedure SaveLastStack(
  messageText varchar2
)
is
  nextStackId TMaxVarchar2;
begin
  logger.Trace( 'SaveLastStack');
                                       -- ���������� ��������� �����
  lastStack.raisedText := messageText;
  lastStack.oracleMessage := oracleErrorStack;
  lastStack.messageText := messageText;
  lastStack.resolvedStack := resolvedStack;
  lastStack.isremote := 0;
                                       -- ���� ��������� �����
                                       -- �����������
  if length( lastStack.raisedText || lastStack.oracleMessage) > Stack_Message_Limit then
    nextStackId := GetNextStackUid;
                                      -- ��������� � nextStackId
                                      -- ����� �������� ����������
                                      -- ����� ��������� �����
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
  logger.Trace( 'SaveLastStack: lastStack.raisedText=' || lastStack.raisedText);
end SaveLastStack;

/* proc: LogErrorStackElement
  �������� ���������� �� �������� ����� � �������
  <pkg_Logging.Trace_LevelCode> �� ����� ������
  ������ <logger>.

  ���������:
  messageText                - ��������� ��� �����������
*/
procedure LogErrorStackElement(
  messageText varchar2
)
is
begin
  logger.Log(
    levelCode => pkg_Logging.Trace_LevelCode
    , messageText =>
        'MESSAGE: ' || LogErrorStackElement.messageText
        || chr(10) || 'ORACLE_ERROR_STACK: ' || oracleErrorStack
        ||
        case when messageText <> lastStack.raisedText then
          chr(10) || 'RAISED: ' || lastStack.raisedText
        end
  );
end LogErrorStackElement;

/* func: ProcessStackElement
  �������� � ���������� ��������� �������� �����.
  ���������� ������ ��� ��������� ����������.

  ���������:
  messageText                - ����� ���������

  �������:
    - ����� ��� ��������� ����������, ��� ��������� �����
      ����� �� ���������� �� messageText

  ����������:
    - ����� ���� ������� ��� � ����� ��������� ����������,
      ��� � ��� ���.  ��� ������ ��� ����� ����������,
      ��������� ���� �� ������ ���� ������� � ����������,
      ���� �� �� �������.
*/
function ProcessStackElement(
  messageText varchar2
)
return varchar2
is
begin
  ResolveStack;
  SaveLastStack( messageText => messageText);
  LogErrorStackElement(
    messageText => messageText
  );
  logger.Trace( 'ProcessStackElement: finish');
  return lastStack.raisedText;
exception when others then
  logger.Error(
    '������ ���������� �����: ('
    || 'message=' || messageText
    || ', sqlerrm=' || sqlerrm
    || ')'
  );
  return messageText;
end ProcessStackElement;

/* proc: LogErrorStack
  ������� ���� ������. �������� ����������
  � ����� � ������� <pkg_Logging.Error_LevelCode>,
  ���� ������� ������� ���� � ���������� �����������.

  ���������:
  messageText                - ����� ��������������� ���������
*/
procedure LogErrorStack(
  messageText varchar2
)
is
begin
  ResolveStack;
                                       -- ���� ���� ���������� ����
                                       -- � �� �� ������ 
                                       -- ( ������� � ����������)
  if lastStack.raisedText is not null then 
    LogCurrentStack(
      messageText => messageText
      , levelCode => pkg_Logging.Error_LevelCode
    );
  end if;  
  InitializeStack;
  logger.Trace( 'LogErrorStack: finish');  
exception when others then
  logger.Error(
    '������ ����������� �����: ('
    || ', messageText="' || messageText || '"'
    || ', sqlerrm="' || sqlerrm || '"'
    || ')'
  );
end LogErrorStack;

/* proc: GetRemoteStack
  �������� ��������� ���� ������ �� �������� ����
  � ������� <GetLastStack> � ��������� ������ � <lastStack>.
  � ������ ������ ��� ��������� �����, ��������
  � � ������� <pkg_Logging.Error_LevelCode>.

  ���������:
  dbLink                     - ��� ����� � ��
*/
procedure GetRemoteStack( 
  dbLink varchar2
)
is
begin
  logger.Trace( 'GetRemoteStack: start(' || dblink || ')');
  execute immediate
'begin
  pkg_LoggingErrorStack.GetLastStack@' || dbLink || '( 
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
  logger.Trace( 'GetRemoteStack: finish');
exception when others then
  logger.Warn( 
    '�� ������� �������� ���� ������ �� �������� ���� ('  
    || 'dbLink="' || dbLink || '"'
    || ', sqlerrm="' || sqlerrm || '"'
    || ', dbms_utility.format_error_stack="' || dbms_utility.format_error_stack || '"'
    || ')'
  );  
end GetRemoteStack;

/* func: ProcessRemoteStackElement
  �������� � ���������� ��������� �������� �����,
  �������� ���� �� �������� ����. � ������
  ������� ���������� � <body::lastStack>, ������� ��������
  ���������� ��������� ����

  ���������:
  messageText                - ����� ���������
  dbLink                     - ��� ����� � ��  

  �������:
    - ����� ��� ��������� ����������, ��� ��������� �����
      ����� �� ���������� �� messageText

  ����������:
    - ������������ ������� <GetRemoteStack>;
    - ������������� �������� � ����� ��������� ����������;
*/
function ProcessRemoteStackElement(
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
    ResolveStack;
                                       -- ���� ���� ���������� ��������� ����
                                       -- � �� ������� � ����������
    if lastStack.raisedText is not null then 
                                       -- ������������ ��������� ����
      SaveLastStack( messageText => messageText);
      LogErrorStackElement(
        messageText => messageText
      );
      isLocalStack := true;  
    end if;  
  end if;
  if isLocalStack then 
    logger.Trace( 'ProcessRemoteStackElement: LocalStack');  
    return 
      lastStack.raisedText;
  else
    logger.Trace( 'ProcessRemoteStackElement: GetRemoteStack');  
    GetRemoteStack( dbLink => dbLink);
    return
      ProcessStackElement( messageText => messageText);
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
end ProcessRemoteStackElement;

/* func: GetErrorStack
  �������� ���������� � ����� ������.
  
    isStackPreserved         - ��������� �� ������ �� �����.
                               ��-��������� ( null) �� ��������� 
                               ( �.�. �������), 
                               ����� ������� ��-��������� 
                               ����� ������ ���� �� ����� ���� 
                               ������� �����.

  �������:
    - ����� � ����������� � �����

  ����������:
    - ������������� �������� � ����� ��������� ����������;
*/
function GetErrorStack( 
  isStackPreserved integer := null
)
return varchar2
is
begin
  ResolveStack;
  if coalesce( isStackPreserved, 0) = 0 then 
    LogCurrentStack(
       messageText => '���� ������� � �������'
      , levelCode => pkg_Logging.Trace_LevelCode
    );
    InitializeStack;
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
end GetErrorStack;

/* proc: GetLastStack
  �������� ������ �� ���������� �����.
  ���� ���������� � <body::lastStack> �� ��������,
  ���������� ������ <body::lastStack>, ����� ����������
  ������ <body::lastClearedStack>.
  
  ���������:
  raisedText                 - ��������� ��� ��������� ����������,
                               ������������ �������� <ProcessStackElement>
  oracleMessage              - �������� <errorStack> ��������� � �����
  messageText                - ���������� ����� ��������� �� ������
  resolvedStack              - ������ ������������� ����� ���������
                               �� ������
  callStack                  - ����� ���������� � ����� �������
*/
procedure GetLastStack(
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
  GetLastStack.raisedText     := resultStack.raisedText;
  GetLastStack.oracleMessage  := resultStack.oracleMessage;
  GetLastStack.messageText    := resultStack.messageText;
  GetLastStack.resolvedStack  := resultStack.resolvedStack;
  GetLastStack.callStack      := resultStack.callStack;
exception when others then
  logger.Error(
    '������ ��������� ������ ���������� �����'
  );
end GetLastStack;

end pkg_LoggingErrorStack;
/
