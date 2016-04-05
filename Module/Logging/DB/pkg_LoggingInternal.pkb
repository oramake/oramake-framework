create or replace package body pkg_LoggingInternal is
/* package body: pkg_LoggingInternal::body */



/* group: ���� */

/* itype: TLoggerUid
  ���������� ������������� ������.
  ������������� ������������� ����� ".[<loggerName>.]", ��� loggerName
  ������������ ����� ����������������� ������������� ��� ������, � �������
  ����� ������������ � �������� ����������� ( ��� ���� ���������/�������� �����
  � ��� ����� ������ �����������). ��� ��������� ������ ������������
  ������������� ".".
  ��������� ����� ������������ ���������� ������������� ������������������
  ������� ��� ���������� �� �������������� � ������� �������� ������������.
*/
subtype TLoggerUid is varchar2(250);

/* itype: TLogger
  ������ ������.
*/
type TLogger is record
(
                                        --��� ������������ ������ �����������
  levelCode lg_level.level_code%type
                                        --������� ������������ ������
  , additive boolean
                                        --Uid ������������� ������
  , parentUid TLoggerUid
);

/* itype: TColLogger
  ��������� �������.
*/
type TColLogger is table of TLogger index by TLoggerUid;

/* itype: TColLevelOrder
  ���������� �������� ��� ������� �����������.
*/
type TColLevelOrder is table of lg_level.level_order%type
  index by lg_level.level_code%type
;



/* group: ��������� */

/* iconst: Root_LoggerUid
  ������������� ��������� ������.
*/
Root_LoggerUid constant varchar2(1) := '.';



/* group: ���������� */

/* ivar: lg
  ����� ������.
*/
lg lg_logger_t := null;

/* ivar: isAccessOperatorFound
  ������� ����������� ������ AccessOperator.
*/
isAccessOperatorFound boolean := null;

/* ivar : previousDebugTimeStamp
  ���������� ��� �������� ��������� ���� ������ ���������� ���������
*/
previousDebugTimeStamp timestamp := null;

/* ivar: forcedDestinationCode
  ��������������� ���������� ��� ������ ���������.
*/
forcedDestinationCode varchar2(10) := null;

/* ivar: colLogger
  ������.
*/
colLogger TColLogger;

/* ivar: colLevelOrder
  ���������� �������� ��� ������� �����������.
  ����������� ��� ������ ��������� � ������.
*/
colLevelOrder TColLevelOrder;

/* ivar: lastParentLogId
  �������� ���� parent_log_id ��������� ����������� � ������� <lg_log>
  ������
*/
lastParentLogId integer := null;




/* group: ������� */



/* group: ������� ������� */

/* ifunc: getLoggerUidByName
  ���������� ������������� �� ����� ������.

  ���������:
  loggerName                  - ��� ������ ( null ������������ ��������� ������)

  �������:
  - ������������� ������, ��������������� �����
*/
function getLoggerUidByName(
  loggerName varchar2
)
return varchar2
is
begin
  if loggerName like '.%' or loggerName like '%.' or loggerName like '%..%'
      then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '������������ ��� ������ ( ����� � ������/����� ����� ���� ��� ����� ������).'
    );
  end if;
  return
    case when loggerName is null then
      Root_LoggerUid
    else
      Root_LoggerUid || loggerName || '.'
    end;
end getLoggerUidByName;

/* ifunc: getLoggerEffectiveLevel
  ���������� ����������� ������� �����������.
  � �������� ������������ ������ ����������� ������� �����������
  ������� ����������� ������ ������, � � ������ ��� ���������� �������
  ���������� ������ � ����������� �������.

  ���������:
  loggerUid                   - ������������� ������

  �������:
  - ��� ������ �����������
*/
function getLoggerEffectiveLevel(
  loggerUid varchar2
)
return varchar2
is

                                        --Uid ������� � ������������� �������
  lu TLoggerUid := loggerUid;

--GetLoggerEffectiveLevel
begin
  while colLogger( lu).levelCode is null and lu <> Root_LoggerUid loop
    lu := colLogger( lu).parentUid;
  end loop;
  return colLogger( lu).levelCode;
end getLoggerEffectiveLevel;

/* ifunc: isMessageEnabled
  ����������, ����� �� ������������ ���������.

  ���������:
  loggerUid                   - ������������� ������
  levelCode                   - ��� ������ ���������

  �������:
  - ������, ���� ��������� ����� ������������
*/
function isMessageEnabled(
  loggerUid varchar2
  , levelCode varchar2
)
return boolean
is
--IsMessageEnabled
begin
  return
    colLevelOrder( levelCode) >=
      colLevelOrder( getLoggerEffectiveLevel( loggerUid))
  ;
end isMessageEnabled;

/* iproc: initialize
  ��������� ������������� ��� ������ ��������� � ������.
*/
procedure initialize
is



  procedure LoadLevelOrder is
  --��������� ���������� �������� ������� �����������.

    cursor curLevel is
      select
        lv.level_code
        , lv.level_order
      from
        lg_level lv
    ;

    type TColLevel is table of curLevel%rowtype;
    colLevel TColLevel;
                                        --������ � ���������
    i pls_integer;

  --LoadLevelOrder
  begin
    open curLevel;
    fetch curLevel bulk collect into colLevel;
    close curLevel;
    i := colLevel.first;
    while i is not null loop
      colLevelOrder( colLevel( i).level_code) := colLevel( i).level_order;
      i := colLevel.next( i);
    end loop;
  end LoadLevelOrder;



  procedure CreateLogger
  is
  --������� �������� � ���������� ������.
  --����� ���������� ��������� ����� �������� ������� ������, ������������
  --��������� �����������.

                                        --��� ����������� ������ ������
    Package_LoggerName constant varchar2(100)
      := pkg_Logging.Module_Name || '.' || 'pkg_LoggingInternal'
    ;
                                        --������ ������
    r TLogger;
  --CreateLogger
  begin
                                        --��������� �������� �����
    r.levelCode := pkg_Logging.Off_LevelCode;
    r.additive := null;
    r.parentUid := null;
    colLogger( Root_LoggerUid) := r;
                                        --��������� ���������� �����
    r.levelCode := null;
    r.additive := true;
    r.parentUid := Root_LoggerUid;
    colLogger( getLoggerUidByName( Package_LoggerName)) := r;
                                        --�������������� ���������� �����
                                        --( ������ ���������� getLoggerUid)
    lg := lg_logger_t.GetLogger( Package_LoggerName);
  end CreateLogger;



  procedure ConfigLogger is
  --��������� ��������� �������.

                                        --������������� �����
    logger lg_logger_t;

  --ConfigLogger
  begin
                                        --������������� ����������� �������
                                        --����������� ��� ������ �� ���������
    logger := lg_logger_t.GetLogger( pkg_Logging.Module_Name);
    logger.setLevel( pkg_Logging.Info_LevelCode);
                                        --����������� �������� �����
    logger := lg_logger_t.GetRootLogger();
    logger.setLevel(
      case when pkg_Common.IsProduction = 1 then
        pkg_Logging.Info_LevelCode
      else
        pkg_Logging.Debug_LevelCode
      end
    );
  end ConfigLogger;



--Initialize
begin
                                        --��������� ������� �������
  LoadLevelOrder;
                                        --������� ������
  CreateLogger;
                                        --��������� �������
  ConfigLogger;
end initialize;



/* group: ������������� ������ AccessOperator */

/* func: getCurrentOperatorId
  ���������� Id �������� ������������������� ��������� ��� ����������� ������
  AccessOperator.

  �������:
  Id �������� ��������� ���� null � ������ ������������� ������ AccessOperator
  ��� ���������� �������� ������������������� ���������.
*/
function getCurrentOperatorId
return integer
is

  -- Id �������� ���������
  operatorId integer := null;

--getCurrentOperatorId
begin
  if coalesce( isAccessOperatorFound, true) then
    execute immediate
      'begin :operatorId := pkg_Operator.getCurrentUserId; end;'
    using
      out operatorId
    ;
  end if;
  return operatorId;
exception when others then
  if isAccessOperatorFound is null
      and (
        -- �� ��������� ����� ����� ���������, �.�. �� ������� �� �������� NLS
        SQLERRM like
          -- PLS-00201: identifier 'PKG_OPERATOR' must be declared
          '%PLS-00201: % ''PKG_OPERATOR'' %'
        or SQLERRM like
          -- PLS-00201: identifier 'PKG_OPERATOR.%' must be declared
          '%PLS-00201: % ''PKG_OPERATOR.%'' %'
        or SQLERRM like
          -- PLS-00904: insufficient privilege to access object %.PKG_OPERATOR%
          '%PLS-00904: %.PKG_OPERATOR%'
        or SQLERRM like
          -- ORA-06508: PL/SQL: could not find program unit being called:
          '%ORA-06508: PL/SQL: %:%'
      )
      then
    isAccessOperatorFound := false;
  end if;
  return null;
end getCurrentOperatorId;



/* group: ��������� ����������� */

/* proc: setDestination
  ������������� ������������ ���������� ��� ������.

  ���������:
  destinationCode             - ��� ����������
*/
procedure setDestination(
  destinationCode varchar2
)
is
begin
  if destinationCode is not null
      and destinationCode not in (
        pkg_Logging.DbmsOutput_DestinationCode
        , pkg_Logging.Table_DestinationCode
      )
  then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '����� �� ���� "' || destinationCode || '" �� ����������.'
    );
  end if;
  forcedDestinationCode := destinationCode;
end setDestination;



/* group: ����������� ��������� */

/* proc: setLastParentLogId
  ��������� �������� parent_log_id ��������� ����������� ������ � ����������
  ������.

  ���������:
  parentLogId                 - Id ������������ ������ ����
*/
procedure setLastParentLogId(
  parentLogId integer
)
is
begin
  lastParentLogId := parentLogId;
end setLastParentLogId;

/* ifunc: logDBOut
  ������� ��������� ����� dbms_output.
  ������ ���������, ����� ������� ������ 255 ��������, ��� ������ �������������
  ����������� �� ������ ����������� ������� ( � ����� ������������ dbms_output).

  ���������:
  messageText                 - ����� ���������

  ���������:
  - �������� ��� ������ ������� ������� ����� ��������� �� �����������
    ������������ �� ������� ����� ������ ( 0x0A) ���� ����� ��������;
*/
procedure logDBOut(
  messageText varchar2
)
is
                                        --������������ ����� ������
  Max_OutputLength constant pls_integer:= 255;
                                        --����� ������
  len pls_integer := coalesce( length( messageText), 0);
                                        --��������� ������� ��� �������� ������
  i pls_integer := 1;
                                        --��������� ������� ��� ����������
                                        --������
  i2 pls_integer;
                                        --�������� ������� ��� �������� ������
                                        --( �� �������)
  k pls_integer := null;

--LogDBOut
begin
  loop
    i2 := len + 1;
    if i2 - i > Max_OutputLength then
      i2 := i + Max_OutputLength;
                                        --�������� ������� ������ �� �������
                                        --����� ������
      k := instr( messageText, chr(10), i2 - len - 1);
      if k >= i then
        i2 := k + 1;
      else
        k := instr( messageText, ' ', i2 - len - 1);
        if k > i then
          i2 := k;
        else
          k := i2;
        end if;
      end if;
    elsif i > 1 then
      k := i2;
    end if;
    dbms_output.put_line(
      case when k is not null then
        substr( messageText, i, k - i)
      else
        messageText
      end
    );
    exit when i2 > len;
    i := i2;
  end loop;
end logDBOut;

/* ifunc: logDebugDBOut
  ������� ���������� ��������� ����� dbms_output c ��������� ������� �
  ��������� �� ����������, � ����� ��������� ����� � ������������ � �������
  ������ ����������� ���������.

  ���������:
  messageText                 - ����� ���������
*/
procedure logDebugDBOut(
  messageText varchar2
)
is
  --������� ����� ( �� ����������)
  curTime timestamp:= systimestamp;

  -- �������� ����� ���������� �����������
  timeInterval interval day to second :=
    curTime - previousDebugTimeStamp;

--logDebugDBOut
begin
  logDBOut(
    substr( to_char( curTime), 10, 12) || ': '
    || lpad(
         coalesce(
           case when
             extract ( HOUR from timeInterval) = 0
           then
             to_char(
                extract( SECOND from timeInterval) * 1000
                + extract( MINUTE from timeInterval) * 60000
             )
           -- ���� ������ ������ ���� ���������� ����� � �����
           when
             timeInterval is not null
           then
             to_char(
               extract ( HOUR from timeInterval)
               + extract ( DAY from timeInterval) * 24
               , 'FM9999990D00'
               , 'NLS_NUMERIC_CHARACTERS = ''. '''
             ) || 'h.'
           end
           , ' '
         )
         , 5
       )
    || ': ' || messageText
  );
  -- ���������� ����� ������ ���������
  previousDebugTimeStamp := curTime;
end logDebugDBOut;

/* ifunc: logTable
  ��������� ��������� � ������� ����.

  ���������:
  levelCode                   - ��� ������ ���������
  messageText                 - ����� ���������
*/
procedure logTable(
  levelCode varchar2
  , messageText varchar2
)
is

  pragma autonomous_transaction;

  truncMessageText varchar2(4000);

begin
  -- ��������� ������ �� 4000 �������� � ��������� ���������� �� ��������� ������
  -- ORA-01461: can bind a LONG value only for insert into a LONG column
  truncMessageText := substr( messageText, 1, 4000);
  insert into
    lg_log
  (
    parent_log_id
    , message_type_code
    , message_text
  )
  values
  (
    -- ��������� ������� ��� �����-����� ���������� ��������� �������������
    -- �������������� ���� � ������ Scheduler
    lastParentLogId
    , case levelCode
        when pkg_Logging.Fatal_LevelCode then
          Error_MessageTypeCode
        when pkg_Logging.Error_LevelCode then
          Error_MessageTypeCode
        when pkg_Logging.Warning_LevelCode then
          Warning_MessageTypeCode
        when pkg_Logging.Info_LevelCode then
          Info_MessageTypeCode
        when pkg_Logging.Debug_LevelCode then
          Debug_MessageTypeCode
        when pkg_Logging.Trace_LevelCode then
          Debug_MessageTypeCode
      end
    , truncMessageText
  );
  commit;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '������ ��� ������ � ��������� � ������� ����:'
        || chr( 10)
        || ' parent_log_id=' || lastParentLogId
        || ' , levelCode=' || levelCode
        || ' , length(messageText)=' || length( messageText)
        || ' , messageText ( first 200 char):'
          || chr( 10) || substr( messageText, 1, 200)
    , true
  );
end logTable;

/* proc: logMessage
  �������� ���������.

  ���������:
  levelCode                   - ��� ������ ���������
  messageText                 - ����� ���������
  loggerUid                   - ������������� ������, ����� ������� ������
                                ��������� ( �� ��������� �������� �����)

  ���������:
  - ������� ���������� �� ��������� ������� ��������� �� ������������ ��
    � ������� <lg_log>, � �� �������� �� ����� ����� dbms_output
*/
procedure logMessage(
  levelCode varchar2
  , messageText varchar2
  , loggerUid varchar2 := null
)
is

  -- ������ logDebugDBOut
  dbOutError varchar2( 4000);

begin
  if isMessageEnabled( coalesce( loggerUid, Root_LoggerUid), levelCode) then

    -- ����� ����� dbms_output
    if forcedDestinationCode = pkg_Logging.DbmsOutput_DestinationCode
       or nullif( pkg_Common.IsProduction, 0) is null
    then
      begin
        logDebugDBOut(
          rpad( levelCode, 5) || ': ' || messageText
        );
      exception when others then
        dbOutError := sqlerrm;
      end;
    end if;

    -- ����� � ������� ����
    if nullif( forcedDestinationCode, pkg_Logging.Table_DestinationCode)
      is null
    then

      -- ���� ���������� ����� logDebugDBOut
      if dbOutError is not null then
        logTable( levelCode
          , '������ ������ � ����� dbms_output: '
            || '"'  || dbOutError || '"' || ' ���������: '
            || '"' || messageText || '"'
        );
      end if;
      logTable(
        levelCode
        , messageText
      );
    end if;
  end if;
end logMessage;



/* group: ���������� ������� ������ */

/* func: getLoggerUid
  ���������� ���������� ������������� ������ �� �����.
  ��� ���������� ���������������� ������ ������� �����.

  ���������:
  loggerName                  - ��� ������ ( null ������������ ��������� ������)

  �������:
  - ������������� ������������� ������
*/
function getLoggerUid(
  loggerName varchar2
)
return varchar2
is

                                        --Uid ������
  loggerUid TLoggerUid;



  procedure CreateLogger is
  --������� ���������� �����.
                                        --������ ������
    r TLogger;
                                        --Uid �������
    childUid TLoggerUid;

  --CreateLogger
  begin
                                        --������������� ������
    r.levelCode := null;
    r.additive := true;
    colLogger( loggerUid) := r;
                                        --����� ������������ ��������
    r.parentUid := loggerUid;
    loop
      r.parentUid := colLogger.prior( r.parentUid);
      exit when loggerUid like r.parentUid || '%' or r.parentUid is null;
    end loop;
    colLogger( loggerUid).parentUid := r.parentUid;
    lg.trace( 'getLoggerUid: parentUid="' || r.parentUid || '"');
                                        --������������� �������� � ������������
                                        --������ ��������
    childUid := loggerUid;
    loop
      childUid := colLogger.next( childUid);
      exit when childUid is null or childUid not like loggerUid || '%';
      if colLogger( childUid).parentUid = r.parentUid then
        colLogger( childUid).parentUid := loggerUid;
        lg.trace( 'getLoggerUid: set parent: childUid="' || childUid || '"');
      end if;
    end loop;
  end CreateLogger;



--GetLoggerUid
begin
                                        --���������� �����������, ���� ��������
  if lg is not null then
    lg.debug( 'getLoggerUid: loggerName="' || loggerName || '"');
  end if;
                                        --���������� Uid
  loggerUid := getLoggerUidByName( loggerName);
                                        --������� �����, ���� ��� ���
  if not colLogger.exists( loggerUid) then
    CreateLogger;
  end if;
                                        --���������� �����������, ���� ��������
  if lg is not null then
    lg.trace( 'getLoggerUid: return: "' || loggerUid || '"');
  end if;
  return loggerUid;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , lg.errorStack(
      '������ ��� ��������� �������������� ������ �� ����� ('
      || ' loggerName="' || loggerName || '"'
      || ').'
      )
    , true
  );
end getLoggerUid;

/* func: getAdditivity
  ���������� ���� ������������.
*/
function getAdditivity(
  loggerUid varchar2
)
return boolean
is
                                        --���� ������������
  additive boolean;

--GetAdditivity
begin
  additive := colLogger( loggerUid).additive;
  lg.debug( 'getAdditivity: loggerUid="' || loggerUid || '"' || ', result='
    || case additive when true then 'true' when false then 'false' end
  );
  return additive;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , lg.errorStack(
      '������ ��� ��������� ����� ������������ ('
      || ' loggerUid="' || loggerUid || '"'
      || ').'
      )
    , true
  );
end getAdditivity;

/* proc: setAdditivity
  ������������� ���� ������������.

  ���������:
  loggerUid                   - ������������� ������
  additive                    - ���� ������������
*/
procedure setAdditivity(
  loggerUid varchar2
  , additive boolean
)
is
begin
  lg.debug( 'setAdditivity: loggerUid="' || loggerUid || '"' || ', additive='
    || case additive when true then 'true' when false then 'false' end
  );
  if loggerUid = Root_LoggerUid then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '���� ������������ �� �������� ��� ��������� ������.'
    );
  end if;
  colLogger( loggerUid).additive := additive;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , lg.errorStack(
      '������ ��� ��������� ����� ������������ ('
      || ' loggerUid="' || loggerUid || '"'
      || ').'
      )
    , true
  );
end setAdditivity;

/* func: getLevel
  ���������� ������� �����������.

  ���������:
  loggerUid                   - ������������� ������
*/
function getLevel(
  loggerUid varchar2
)
return varchar2
is
                                        --��� ������ �����������
  levelCode lg_level.level_code%type;

--GetLevel
begin
  levelCode := colLogger( loggerUid).levelCode;
  lg.debug( 'getLevel: loggerUid="' || loggerUid || '"'
    || ', result="' || levelCode || '"'
  );
  return levelCode;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , lg.errorStack(
      '������ ��� ��������� ������ ����������� ('
      || ' loggerUid="' || loggerUid || '"'
      || ').'
      )
    , true
  );
end getLevel;

/* proc: setLevel
  ������������� ������� �����������.

  ���������:
  loggerUid                   - ������������� ������
  levelCode                   - ��� ������ ���������� ���������
*/
procedure setLevel(
  loggerUid varchar2
  , levelCode varchar2
)
is
begin
  lg.debug( 'setLevel: loggerUid="' || loggerUid || '"'
    || ', levelCode="' || levelCode || '"'
  );
  if levelCode is not null and not colLevelOrder.exists( levelCode) then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '����������� ��� ������ �����������.'
    );
  elsif levelCode is null and loggerUid = Root_LoggerUid then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '������� ����������� ��� ��������� ������ �� ����� ���� NULL.'
    );
  end if;
  colLogger( loggerUid).levelCode := levelCode;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , lg.errorStack(
      '������ ��� ��������� ������ ����������� ('
      || ' loggerUid="' || loggerUid || '"'
      || ', levelCode="' || levelCode || '"'
      || ').'
      )
    , true
  );
end setLevel;

/* func: getEffectiveLevel
  ���������� ����������� ������� �����������.

  ���������:
  loggerUid                   - ������������� ������

  �������:
  - ��� ������ �����������

  ���������:
  - �������� ������� <getLoggerEffectiveLevel>;
*/
function getEffectiveLevel(
  loggerUid varchar2
)
return varchar2
is

                                        --��� ������ �����������
  levelCode lg_level.level_code%type;

--GetEffectiveLevel
begin
  levelCode := getLoggerEffectiveLevel( loggerUid);
  lg.debug( 'getEffectiveLevel: loggerUid="' || loggerUid || '"'
    || ', result="' || levelCode || '"'
  );
  return levelCode;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , lg.errorStack(
      '������ ��� ��������� ������������ ������ ����������� ('
      || ' loggerUid="' || loggerUid || '"'
      || ').'
      )
    , true
  );
end getEffectiveLevel;

/* func: isEnabledFor
  ���������� ������, ���� ��������� ������� ������ ����� ������������.

  ���������:
  loggerUid                   - ������������� ������
  levelCode                   - ��� ������ �����������

  ���������:
  - �������� ������� <isMessageEnabled>;
*/
function isEnabledFor(
  loggerUid varchar2
  , levelCode varchar2
)
return boolean
is
begin
  return isMessageEnabled( loggerUid, levelCode);
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , lg.errorStack(
      '������ ��� �������� ����������� ��������� ('
      || ' loggerUid="' || loggerUid || '"'
      || ', levelCode="' || levelCode || '"'
      || ').'
      )
    , true
  );
end isEnabledFor;

--pkg_LoggingInternal
begin
  initialize();
end pkg_LoggingInternal;
/
