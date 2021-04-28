create or replace package body pkg_TaskHandler is
/* package body: pkg_TaskHandler::body */



/* group: ��������� */

/* iconst: Task_ModulePrefix
  ������� ����� ������ ( v$session.module) ��� ������ ( �����������).
*/
Task_ModulePrefix constant varchar2(50) := 'TASK';

/* iconst: CommandPipe_NamePrefix
  ������� ����� ������������ ������ ��� �����������.
*/
CommandPipe_NamePrefix constant varchar2(50) := 'pkg_TaskHandler.CommandPipe_';

/* iconst: Initialize_Action
  �������� ��������, ������������������� ��� ������������� ���������.
*/
Initialize_Action constant varchar2(32) := 'initialize';



/* group: ���������� */

/* ivar: logger
  ����� ������.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => Module_Name
  , objectName  => 'pkg_TaskHandler'
);

/* ivar: currentCommandPipeName
  ��� ���������� ������ ��� ������� ������.
*/
currentCommandPipeName varchar2(128);



/* group: ������� */



/* group: �������� � ��������� ������� */

/* func: toSecond
  ���������� ������������ ��������� � ��������.

  ���������:
  timeInterval                - �������� ��������� ��������
*/
function toSecond(
  timeInterval interval day to second
)
return number
is
begin
  return
    extract( SECOND   from timeInterval)
    + extract( MINUTE from timeInterval) * 60
    + extract( HOUR   from timeInterval) * 60 * 60
    + extract( DAY    from timeInterval) * 60 * 60 * 24
  ;
end toSecond;

/* func: getTimeout
  ���������� �������� �������� ( � ��������) �� ������ �������� ��������
  � ���������� ������� ( � ������, ���� ��������� ����� ��������� ��
  �� ��������� �������� ��������, �� ������������ ������� �� ����������
  �������).

  ���������:
  baseTimeout               - ������� ������� ( � ��������)
  limitTime                 - ��������� �����

  ���������:
  ���� ��������� ����� ���������� ��� null, ������������ null.
*/
function getTimeout(
  baseTimeout number
  , limitTime timestamp with time zone
)
return number
is

  -- ������������ �������
  timeout number := null;

  -- ������� �����
  sysTime timestamp with time zone := systimestamp;

begin
  if limitTime > ( sysTime + numtodsinterval( baseTimeout, 'SECOND')) then
    timeout := baseTimeout;
  elsif limitTime >= sysTime then
    timeout := pkg_TaskHandler.toSecond( limitTime - sysTime);
  end if;
  return timeout;
end getTimeout;

/* func: getTime
  ��������� ������� ����� � �������� ( � ������������� ������� � ��������� ��
  ����� ����� �������).

  ���������: ������� ����� ������������ ����� ������������ �������� �������
  ( ��������� ���� - �������).
*/
function getTime
return number
is
begin
  return dbms_utility.get_time() / 100;
end getTime;

/* func: timeDiff
  ���������� ������������ ���������� ������� � ��������.

  ���������:
  newTime                     - ��������� ������ �������
                                ( � �������� �� getTime())
  oldTime                     - ���������� ������ �������
                                ( � �������� �� getTime())

  ���������:
  � ������, ���� ����������� ������� getTime() ( �.�. newTime < oldTime)
  ������������ null.
*/
function timeDiff(
  newTime number
  , oldTime number
)
return number
is
begin
  return
    case when newTime >= oldTime then
      newTime - oldTime
    end
  ;
end timeDiff;

/* func: nextTime
  � ������ ��������� �������� � ���������� ������� ������� ��������� ��������
  ������� ������� �� ������� � ���������� ������ ����� ���������� ����.

  ���������:
  checkTime                   - ������� ������ �������
                                ( � �������� �� ������� getTime())
  timeout                     - ������� �������� ( � ��������)

  ���������:
    - � ������ ������ �������� � getTime() ������������ ������, �� �������
      �������� ������� ����� ���� ������ ���������;
    - � ������, ���� checkTime is null ������������ ������;
    - � ������, ���� timeout is null ������������ ������;
*/
function nextTime(
  checkTime in out nocopy number
  , timeout number
)
return boolean
is

  -- ������������ ��������
  isOk boolean;

  -- ������� �����
  currentTime number := getTime();

begin
  isOk :=
    checkTime is null
    or timeout is null
    or currentTime < checkTime
    or currentTime - checkTime >= timeout
  ;
  if isOk then
    checkTime := currentTime;
  end if;
  return isOk;
end nextTime;



/* group: �������������� � ��������� */

/* iproc: setAction( INTERNAL)
  ������������� ���������� � ����������� ��������.

  ���������:
  action                      - �������� ��������
  actionInfo                  - ���������� � ����������� ��������
  limitTime                   - ����������� ���� ���������� ��������
  limitSecond                 - ������������ ����� ���������� ( � ��������)
*/
procedure setAction(
  action varchar2
  , actionInfo varchar2
  , limitTime timestamp with time zone
  , limitSecond integer
)
is

  -- ������� �����
  tm timestamp with time zone := systimestamp;

  -- �����, ����������� ����� ��������
  actionTime varchar2( 100);

  -- ����� �������������� �����
  infoLength integer;

begin
  actionTime :=
    substr( to_char( tm, 'yy-mm-dd hh24:mi:ss.ff'), 1, 20)
    || to_char( tm, ' TZH:TZM')
  ;
  if limitSecond is not null or limitTime is not null then
    actionTime := actionTime || ';'
      || to_char( ceil(
          coalesce( limitSecond, toSecond( limitTime - tm)) * 100
        ));
  end if;
  infoLength := 64 - length( actionTime) - 1;

  -- ������������� �������� ��������
  dbms_application_info.set_action( action);

  -- ������������� ��������� ��������
  dbms_application_info.set_client_info(
    case when infoLength > 0 and length( actionInfo) > 0 then
      substr( actionInfo, 1, infoLength) || ','
    end
    || actionTime
  );
end setAction;

/* proc: setAction
  ������������� ���������� � ����������� ��������.

  ���������:
  action                      - �������� ��������
  actionInfo                  - ���������� � ����������� ��������
  limitTime                   - ����������� ���� ���������� ��������
*/
procedure setAction(
  action varchar2
  , actionInfo varchar2 := null
  , limitTime timestamp with time zone := null
)
is
begin
  setAction(
    action            => action
    , actionInfo      => actionInfo
    , limitTime       => limitTime
    , limitSecond     => null
  );
end setAction;

/* proc: setAction( LIMIT_SECOND)
  ������������� ���������� � ����������� ��������.

  ���������:
  action                      - �������� ��������
  actionInfo                  - ���������� � ����������� ��������
  limitSecond                 - ������������ ����� ���������� ( � ��������)
*/
procedure setAction(
  action varchar2
  , actionInfo varchar2 := null
  , limitSecond integer
)
is
begin
  setAction(
    action            => action
    , actionInfo      => actionInfo
    , limitTime       => null
    , limitSecond     => limitSecond
  );
end setAction;

/* proc: initTask
  �������������� ������.

  ���������:
  moduleName                  - ��� ������
  processName                 - ��� ��������
*/
procedure initTask(
  moduleName varchar2
  , processName varchar2
)
is
begin

  -- ������������� ��� ������ � ��������
  dbms_application_info.set_module(
    Task_ModulePrefix || ':' || moduleName || ':' || processName
    , Initialize_Action
  );
  setAction( Initialize_Action);
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ������������� ������.'
      )
    , true
  );
end initTask;

/* proc: cleanTask
  ��������� ������� ��� ���������� ������.

  ���������:
  riseException               - ����������� ������� ������ ���������� � ������
                                ������, ��-��������� ��� ������ �����������
                                � ������� ���������� �� �������������
*/
procedure cleanTask(
  riseException boolean := null
)
is
begin

  -- ������� ���������� � ���������
  setAction( null);
  dbms_application_info.set_module( null, null);
exception when others then
  if riseException then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ������� �� ���������� ������ ������.'
        )
      , true
    );
  else
    null;
  end if;
end cleanTask;



/* group: ������ � �������� */

/* proc: createPipe
  ������� �����.

  ���������:
  pipeName                    - ��� ������
*/
procedure createPipe(
  pipeName varchar2
)
is

  -- ��������� �������� � �������
  pipeStatus number;

begin
  pipeStatus := dbms_pipe.create_pipe( pipeName);
  logger.trace(
    'create_pipe: ' || pipeName || ', result: ' || pipeStatus
  );
  if pipeStatus <> 0 then
    raise_application_error(
      pkg_Error.PipeError
      , '�������� ������ ����������� ��������� ('
        || ' ��� ������: ' || to_char( pipeStatus)
        || ').'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������� ������ ('
        || ' pipeName="' || pipeName || '"'
        || ').'
      )
    , true
  );
end createPipe;

/* proc: removePipe
  ������� �����.

  ���������:
  pipeName                    - ��� ������
*/
procedure removePipe(
  pipeName varchar2
)
is

  -- ��������� �������� � �������
  pipeStatus number;

begin
  pipeStatus := dbms_pipe.remove_pipe( pipeName);
  logger.trace(
    'remove_pipe: ' || pipeName || ', result: ' || pipeStatus
  );
  if pipeStatus <> 0 then
    raise_application_error(
      pkg_Error.PipeError
      , '�������� ������ ����������� ��������� ('
        || ' ��� ������: ' || to_char( pipeStatus)
        || ').'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������� ������ ('
        || ' pipeName="' || pipeName || '"'
        || ').'
      )
    , true
  );
end removePipe;

/* ifunc: sendMessage( INTERNAL)
  �������� ��������� � �����.

  ���������:
  pipeName                    - ��� ������
  timeout                     - ������� �������� ( � ��������, �� ���������
                                ����������� ���������, dbms_pipe.maxwait)
  maxPipeSize                 - ������������ ������ ������ ( �� ���������
                                8192)
  isCheckResult               - ��������� ��������� �������� � �����������
                                ���������� � ������ �������������� ����������
                                ( 1 ��, 0 ��� ( �� ���������))
  isIgnoreTimeoutError        - ��� ���������� �������� ( ���� isCheckResult
                                ����� 1) ������� ������ �� �������� ( ���
                                1, ��. ����) ���������� ����������� ( 1 ��,
                                0 ���, �� ��������� 0)

  �������:
  ��� �������� �������� ���������.

  ���� ����������:
  0   - �������� ����������
  1   - ��������� �������� ���� �������� ����� �� ����������� ( ���� ����
        ������� ����������� ����� �������� maxPipeSize, �������� 1)
  ... - ������ ������ �������� ������������ � dbms_pipe.send_message

  ���������:
  - � ������, ���� ������� ����������� � ����������� ( � �.�.
    ��������� ���������� �������� ���������� ��������) �����������
    ������� ������ ��������� � ������� ������ dbms_pipe.reset_buffer;
*/
function sendMessage(
  pipeName varchar2
  , timeout integer
  , maxPipeSize integer
  , isCheckResult pls_integer
  , isIgnoreTimeoutError pls_integer := null
)
return integer
is

  -- ��������� �������� � �������
  pipeStatus integer := null;

--sendMessage
begin
  pipeStatus := dbms_pipe.send_message(
    pipename      => pipeName
    , timeout     => coalesce( timeout, dbms_pipe.maxwait)
    , maxpipesize => coalesce( maxPipeSize, 8192)
  );
  logger.trace(
    'send_message: ' || pipeName || ', result: ' || pipeStatus
  );
  if coalesce( pipeStatus <> 0, true) then
    if isCheckResult = 1 then
      if isIgnoreTimeoutError = 1 and pipeStatus = 1 then
        null;
      else
        raise_application_error(
          pkg_Error.PipeError
          , '���������� ��������� �������� ��������� ('
            || ' ��� ������: ' || to_char( pipeStatus)
            || ').'
        );
      end if;
    end if;
  end if;
  return pipeStatus;
exception when others then
  -- ������� ����� � ������� ��������� ����� �������� ����������
  dbms_pipe.reset_buffer;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������� ��������� � ����� ('
        || ' pipeName="' || pipeName || '"'
        || ', timeout=' || to_char( timeout)
        || ', maxPipeSize=' || to_char( maxPipeSize)
        || ', isCheckResult=' || to_char( isCheckResult)
        || ', isIgnoreTimeoutError=' || to_char( isIgnoreTimeoutError)
        || ').'
      )
    , true
  );
end sendMessage;

/* proc: sendMessage
  �������� ��������� � �����.

  ���������:
  pipeName                    - ��� ������
  timeout                     - ������� �������� ( � ��������, �� ���������
                                ����������� ���������, dbms_pipe.maxwait)
  maxPipeSize                 - ������������ ������ ������ ( �� ��������� 8192)

  ���������:
  ������������ ����� ������� ��� ������� <sendMessage( INTERNAL)> ��� ��������
  � �������� ���������� ��� ���������� ���������� ( isCheckResult = 1).
*/
procedure sendMessage(
  pipeName varchar2
  , timeout integer := null
  , maxPipeSize integer := null
)
is

  -- ��������� �������� � �������
  pipeStatus integer;

--sendMessage
begin
  pipeStatus := sendMessage(
    pipename        => pipeName
    , timeout       => timeout
    , maxPipeSize   => maxPipeSize
    , isCheckResult => 1
  );
end sendMessage;

/* func: sendMessage( STATUS)
  �������� ��������� � ����� � ���������� ���������.

  ���������:
  pipeName                    - ��� ������
  timeout                     - ������� �������� ( � ��������, �� ���������
                                ����������� ���������, dbms_pipe.maxwait)
  maxPipeSize                 - ������������ ������ ������ ( �� ��������� 8192)

  �������:
  ��� �������� �������� ��������� ( ��. <sendMessage( INTERNAL)>).

  ���������:
  ������������ ����� ������� ��� ������� <sendMessage( INTERNAL)> ��� ��������
  ��� �������� ���������� ( isCheckResult = 0).
*/
function sendMessage(
  pipeName varchar2
  , timeout integer := null
  , maxPipeSize integer := null
)
return integer
is
begin
  return
    sendMessage(
      pipename        => pipeName
      , timeout       => timeout
      , maxPipeSize   => maxPipeSize
      , isCheckResult => 0
    )
  ;
end sendMessage;

/* func: receiveMessage
  ��������� ������� ��������� � ������ � ���������� ������, ���� ��� ��������.

  ���������:
  pipeName                    - ��� ������
  timeout                     - ����� �������� � �������� ( �� ��������� ���
                                ��������)
*/
function receiveMessage(
  pipeName varchar2
  , timeout number := null
)
return boolean
is

  -- ������� ��������� �������
  retVal boolean := false;

  -- ����� ��������� (���� �������)
  sleepSecond number := 0;

  -- ����� �������� �� ������ (�������)
  receiveSecond integer := 0;



  /*
    ��������� ��������� � ������.
  */
  procedure checkPipe( waitSecond number) is

    -- ��������� ��������� ���������
    pipeStatus integer;

  begin
    -- ���� ��������� ���������
    pipeStatus := dbms_pipe.receive_message( pipeName, waitSecond);
    logger.trace(
      'receive_message: ' || pipeName || ', result: ' || pipeStatus
    );
    case pipeStatus
      when 0 then
        -- �������� ���������
        retVal := true;
      when 1 then
        -- ����� �������
        null;
      else
        -- ���������� ��� ������
        raise_application_error(
          pkg_Error.PipeError
          , '��������� ��������� �� ������ ����������� ��������� ('
            || ' ��� ������: ' || to_char( pipeStatus)
            || ').'
        );
    end case;
  end checkPipe;



--receiveMessage
begin
  if timeout > 0 then

    -- �������� �� ������ � ������ ��������
    receiveSecond := floor( timeout);

    -- ������ � ����� �������
    sleepSecond := timeout - receiveSecond;
  end if;

  -- ����� ��������� �����
  checkPipe( 0);
  if not RetVal and ( sleepSecond > 0  or receiveSecond > 0 ) then

    -- ���� ���� �������
    if sleepSecond > 0 then
      dbms_lock.sleep( sleepSecond);
    end if;

    -- ���� �� ������ ������� �������
    checkPipe( receiveSecond);
  end if;
  return retVal;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������� ������� ��������� � ������ ('
        || ' pipeName="' || pipeName || '"'
        || ').'
      )
    , true
  );
end receiveMessage;



/* group: ��������/��������� ������ */

/* ifunc: getCommandPipeName
  ���������� ��� ���������� ������ ��� ������.

  ���������:
  sessionSid                  - v$session.sid ������ ����������
  sessionSerial               - v$session.serial# ������ ����������
*/
function getCommandPipeName(
  sessionSid number
  , sessionSerial number
)
return varchar2
is
begin
  return
    CommandPipe_NamePrefix
    || to_char( sessionSid)
    || '_'
    || to_char( sessionSerial)
  ;
end getCommandPipeName;

/* func: sendCommand
  �������� ������� ��������� ������.

  ���������:
  sessionSid                  - v$session.sid ������ ����������
  sessionSerial               - v$session.serial# ������ ����������

  ������������ ��������: ������, ���� ������� ������� ���������� � ����, ����
  ������� �� ����� ���� ���������� ���� ������ �.�. ��� �� ����������.
*/
function sendCommand(
  sessionSid number
  , sessionSerial number
)
return boolean
is

  -- ������� �������� �������� �������
  isSend boolean := false;

  -- ��� ������ ��� �������� �������
  pipeName currentCommandPipeName%type :=
    getCommandPipeName( sessionSid, sessionSerial)
  ;

  -- ���� ������������� ������
  isExist integer;

begin
  if sendMessage(
        pipeName                => pipeName
        , timeout               => 0
          -- ������������ ������ ��� ���������� ������
        , maxPipeSize           => 1
        , isCheckResult         => 1
        , isIgnoreTimeoutError  => 1
      ) = 0
      then
    isSend := true;
  else
    -- ��������� ������� ������
    select
      count(1)
    into isExist
    from
      v$session ss
    where
      ss.sid = sessionSid
      and ss.serial# = sessionSerial
    ;
    if isExist = 1 then
      -- ��������� ��� �������� maxPipeSize ( ����� ���������)
      sendMessage(
        pipeName    => pipeName
        , timeout   => 0
      );
      isSend := true;
    else
      -- ������� �������������� ��������� �����
      removePipe( pipeName);
    end if;
  end if;
  return isSend;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������� ������� ��� ������ ('
        || ' sid=' || to_char( sessionSid)
        || ', serial#=' || to_char( sessionSerial)
        || ').'
      )
    , true
  );
end sendCommand;

/* proc: sendStopCommand
  �������� ������� ��������� ���������� �����������.

  ���������:
  sessionSid                  - v$session.sid ������ ����������
  sessionSerial               - v$session.serial# ������ ����������
  moduleName                  - ��� ������

  ���������:
  ���� ��������� �� ������� (null), �� ������� ��������� ���������� ����
  ���������� ������������.
*/
procedure sendStopCommand(
  sessionSid number := null
  , sessionSerial number := null
  , moduleName varchar2 := null
)
is

  cursor curSession is
    select
      ss.sid
      , ss.serial#
      , cp.name as pipe_name
    from
      v_th_session ss
      inner join v_th_command_pipe cp
        on cp.sid = ss.sid
        and cp.serial# = ss.serial#
    where
      nullif( sessionSid, ss.sid) is null
      and nullif( sessionSerial, ss.serial#) is null
      and nullif( moduleName, ss.module_name) is null
  ;

  -- ����� ������������ ������ ���������
  nSend integer := 0;

--sendStopCommand
begin
  for rec in curSession loop

    -- �������� ������� ���������
    dbms_pipe.pack_message( Stop_Command);
    sendMessage(
      pipeName => rec.pipe_name
      , timeout => 0
    );
    nSend := nSend + 1;
  end loop;

  -- ������ ��� ���������� ������
  if nSend = 0 and coalesce( sessionSid, sessionSerial) is not null then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '�� ������� ������ ��� ��������� ('
        || substr(
            case when sessionSid is not null then
                ', sid=' || to_char( sessionSid)
            end
            || case when sessionSerial is not null then
                ', serial#=' || to_char( sessionSerial)
              end
            , 3)
        || ').'
    );
  end if;
end sendStopCommand;

/* func: getCommand
  �������� �������� ��������� ������� � ������� ���������� ��������.
  ���������� ������, ���� ������� ���� ��������.

  ���������:
  command                     - ���������� �������
  timeout                     - ����� �������� � �������� ( �� ��������� ���
                                ��������)
*/
function getCommand(
  command out varchar2
  , timeout number := null
)
return boolean
is

  -- ������� ��������� ���������
  isReceive boolean;

begin
  isReceive := receiveMessage(
    pipeName => currentCommandPipeName
    , timeout =>
        case when timeout > 0 and timeout < 0.01 then
          0.01
        else
          timeout
        end
  );
  if isReceive then

    -- �������� ��� �������
    dbms_pipe.unpack_message( command);
  end if;
  return isReceive;
end getCommand;

/* func: isStopCommandReceived
  ��������� ��������� ������� ���������.

  ���������:
  timeout                     - ����� �������� � ��������
                                (�� ��������� ��� ��������)

  �������:
  ������, ���� ������� ��������� ���� ��������.
*/
function isStopCommandReceived(
  timeout number := null
)
return boolean
is

  -- ������� ��������� �������
  isReceived boolean;

  -- ��� ���������� �������
  command varchar2(50);

begin
  isReceived := getCommand(
    command   => command
    , timeout => timeout
  );
  if command != Stop_Command then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '�������� ����������� ����������� ������� "' || command || '".'
    );
  end if;
  return coalesce( command = Stop_Command, false);
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������� ��������� ������� ��������� ('
        || 'timeout=' || timeout
        || ').'
      )
    , true
  );
end isStopCommandReceived;

/* proc: initHandler
  �������������� ����������.

  ���������:
  moduleName                  - ��� ������
  processName                 - ��� ��������
*/
procedure initHandler(
  moduleName varchar2
  , processName varchar2
)
is
begin

  -- ������������� ��� ������ � ��������
  initTask( moduleName, processName);
  currentCommandPipeName := getCommandPipeName(
    sessionSid => pkg_Common.GetSessionSid
    , sessionSerial => pkg_Common.GetSessionSerial
  );
  createPipe( currentCommandPipeName);
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ������������� �����������.'
      )
    , true
  );
end initHandler;

/* proc: cleanHandler
  ��������� ������� ��� ���������� ������ �����������.

  ���������:
  riseException               - ����������� ������� ������ ���������� � ������
                                ������, ��-��������� ��� ������ �����������
                                � ������� ���������� �� �������������

*/
procedure cleanHandler(
  riseException boolean := null
)
is
begin

  -- ������� ����������� ����
  if currentCommandPipeName is not null then
    removePipe( currentCommandPipeName);
    currentCommandPipeName := null;
  end if;
  cleanTask();
exception when others then
  if riseException then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ������� �� ���������� ������ �����������.'
        )
      , true
    );
  else
    null;
  end if;
end cleanHandler;



/* group: ���������� */

/* proc: setLock
  ������������� ������������ ���������� ��� ������������ ����������.

  ���������:
  lockName                    - ��� ����������
  waitSecond                  - ������� �������� � ������� ( null -
                                ���c������� ��������� �����)
*/
procedure setLock(
  lockName varchar2
  , waitSecond integer := null
)
is

  lockHandle varchar2( 128);
  lockError integer;

  /*
    ��������� ����������� ����������.
  */
  procedure getHandle
  is
    pragma autonomous_transaction;
  begin
    -- �������� � ���������� ����������, ��� ��� ��������� commit
    dbms_lock.allocate_unique(
      lockName  =>
        sys_context ( 'USERENV', 'CURRENT_USER')
        || '.' || lockName
      , lockhandle => lockHandle
    );
    commit;
  end getHandle;

-- setLock
begin
  getHandle();
  lockError := dbms_lock.request(
    lockhandle => lockHandle
    , lockmode => dbms_lock.x_mode
    , timeout => coalesce( waitSecond, dbms_lock.maxwait)
    , release_on_commit => true
  );
  -- �� �������� ��������� � �� ����������� ����������
  if lockError not in ( 0, 4) then
    raise_application_error(
      pkg_Error.ProcessError
      , logger.errorStack(
          '�� ������� ���������� ���������� ('
          || ' lockError=' || to_char( lockError)
          || ')'
        )
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ��������� ���������� ('
        || ' lockName="' || lockName || '"'
        || ', ��� ������: ' || to_char( lockError)
        || ').'
      )
    , true
  );
end setLock;

end pkg_TaskHandler;
/
