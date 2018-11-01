create or replace package body pkg_LoggingInternal is
/* package body: pkg_LoggingInternal::body */



/* group: ���� */

/* itype: FindModuleStringT
  ������ ��� ����������� Id ������ (���).
  ������������ ����� ������ ���� �� ������, ��� � ���� module_name �������
  <lg_log>.
*/
subtype FindModuleStringT is varchar2(128);

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
  -- ��� ������, �������� ��������� ����� (null ��� ��������� ������)
  moduleName lg_log.module_name%type
  -- ��� ������� � ������, �������� ��������� ����� (null ��� ��������� ������)
  , objectName lg_log.object_name%type
  -- Id ������, �������� ��������� ����� (���� ������� ����������)
  , moduleId integer
  -- ������ ��� ����������� moduleId
  , findModuleString FindModuleStringT
  -- ����� ���������� ���������� moduleId
  -- (true - ��, false - ��� (���� �������), null - �� ���������)
  , isNeedFindModuleId boolean
  -- ��� ������������ ������ �����������
  , levelCode lg_level.level_code%type
  -- ������� ������������ ������
  , additive boolean
  -- Uid ������������� ������
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

/* itype: SetLoggerModuleIdCacheT
  ��� ����������� ����������� Id ������ (���).
*/
type SetLoggerModuleIdCacheT is table of integer index by FindModuleStringT;



/* group: ��������� */

/* iconst: Root_LoggerUid
  ������������� ��������� ������.
*/
Root_LoggerUid constant varchar2(1) := '.';



/* group: ���������� */

/* ivar: logger
  ���������� ����� ������ (���������������� � ��������� <initialize>).
*/
logger lg_logger_t := null;

/* ivar: internalLoggerUid
  ������������� ����������� ������ ������ (���������������� � ���������
  <initialize>).
*/
internalLoggerUid TLoggerUid := null;


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

/* ivar: lastSessionid
  �������� ���� sessionid ��������� ����������� � ������� <lg_log>
  ������
*/
lastSessionid number := null;

/* ivar: setLoggerModuleIdCache
  ��� ����������� ����������� Id ������ (���).
*/
setLoggerModuleIdCache SetLoggerModuleIdCacheT;



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
      , '������������ ��� ������'
        || ' (����� � ������/����� ����� ���� ��� ����� ������).'
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

  -- Uid ������� � ������������� �������
  lu TLoggerUid := loggerUid;

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



  /*
    ��������� ���������� �������� ������� �����������.
  */
  procedure loadLevelOrder is

    cursor curLevel is
      select
        lv.level_code
        , lv.level_order
      from
        lg_level lv
    ;

    type TColLevel is table of curLevel%rowtype;
    colLevel TColLevel;

    -- ������ � ���������
    i pls_integer;

  begin
    open curLevel;
    fetch curLevel bulk collect into colLevel;
    close curLevel;
    i := colLevel.first;
    while i is not null loop
      colLevelOrder( colLevel( i).level_code) := colLevel( i).level_order;
      i := colLevel.next( i);
    end loop;
  end loadLevelOrder;



  /*
    ������� �������� � ���������� ������.
    ����� ���������� ��������� ����� �������� ������� ������, ������������
    ��������� �����������.
  */
  procedure createInitialLogger
  is

    -- ������ ������
    r TLogger;

    -- ��� ����������� ������ ������
    loggerName varchar2(200);

  begin

    -- ��������� �������� �����
    r.levelCode := pkg_Logging.Off_LevelCode;
    r.additive := null;
    r.parentUid := null;
    colLogger( Root_LoggerUid) := r;

    -- ��������� ���������� �����
    r.moduleName := pkg_Logging.Module_Name;
    r.objectName := 'pkg_LoggingInternal';
    r.findModuleString := pkg_Logging.Module_InitialPath;
    r.isNeedFindModuleId := true;
    r.levelCode := null;
    r.additive := true;
    r.parentUid := Root_LoggerUid;
    loggerName := r.moduleName || '.' || r.objectName;
    internalLoggerUid := getLoggerUidByName( loggerName);
    colLogger( internalLoggerUid) := r;

    -- �������������� ���������� ����� ( ������ ���������� getLoggerUid)
    logger := lg_logger_t.getLogger( loggerName);
  end createInitialLogger;



  /*
    ��������� ��������� �������.
  */
  procedure configLogger is

    -- ������������� �����
    lgr lg_logger_t;

  begin

    -- ������������� ����������� ������� ����������� ��� ������ �� ���������
    lgr := lg_logger_t.getLogger(
      moduleName          => pkg_Logging.Module_Name
      , findModuleString  => pkg_Logging.Module_InitialPath
    );
    lgr.setLevel( pkg_Logging.Info_LevelCode);

    -- ����������� �������� �����
    lgr := lg_logger_t.getRootLogger();
    lgr.setLevel(
      case when pkg_Common.isProduction = 1 then
        pkg_Logging.Info_LevelCode
      else
        pkg_Logging.Debug_LevelCode
      end
    );
  end configLogger;



-- initialize
begin

  -- ��������� ������� �������
  loadLevelOrder;

  -- ������� ��������� ������ (�������� � ���������� ������)
  createInitialLogger;

  -- ��������� �������
  configLogger;
end initialize;

/* iproc: setLoggerModuleId
  �������� ��������� Id ������, � �������� ��������� �����
  (���� moduleId ������ ������ <TLogger>).

  ���������:
  loggerUid                   - ������������� ������������� ������
*/
procedure setLoggerModuleId(
  loggerUid varchar2
)
is

  findModuleString FindModuleStringT;

  moduleId integer;

begin
  if colLogger( loggerUid).isNeedFindModuleId then

    -- ������ ������ ���� �������
    colLogger( loggerUid).isNeedFindModuleId := false;

    findModuleString := coalesce(
      colLogger( loggerUid).findModuleString
      , colLogger( loggerUid).moduleName
    );

    -- ����������� ����� ������ isNeedFindModuleId ����� �������� ������������
    -- ����������� ������
    logger.trace(
      'setLoggerModuleId: loggerUid="' || loggerUid || '"'
      || ', for: "' || findModuleString || '"'
    );

    if setLoggerModuleIdCache.exists( findModuleString) then
      moduleId := setLoggerModuleIdCache( findModuleString);
      logger.trace( 'setLoggerModuleId: cached moduleId=' || moduleId);
    else
      moduleId := pkg_ModuleInfo.getModuleId(
        findModuleString      => findModuleString
          -- ������������ ���� Id ������ �� ������ (������ ���������� ��������)
        , raiseExceptionFlag  => 0
      );
      setLoggerModuleIdCache( findModuleString) := moduleId;
      logger.trace( 'setLoggerModuleId: found moduleId=' || moduleId);
    end if;

    colLogger( loggerUid).moduleId := moduleId;
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ����������� Id ������ ��� ������ ('
        || ' loggerUid="' || loggerUid || '"'
        || ').'
      )
    , true
  );
end setLoggerModuleId;



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

/* ifunc: logDbOut
  ������� ��������� ����� dbms_output.
  ������ ���������, ����� ������� ������ 255 ��������, ��� ������ �������������
  ����������� �� ������ ����������� ������� ( � ����� ������������ dbms_output).

  ���������:
  messageText                 - ����� ���������

  ���������:
  - �������� ��� ������ ������� ������� ����� ��������� �� �����������
    ������������ �� ������� ����� ������ ( 0x0A) ���� ����� ��������;
*/
procedure logDbOut(
  messageText varchar2
)
is

  -- ������������ ����� ������
  Max_OutputLength constant pls_integer:= 255;

  -- ����� ������
  len pls_integer := coalesce( length( messageText), 0);

  -- ��������� ������� ��� �������� ������
  i pls_integer := 1;

  -- ��������� ������� ��� ���������� ������
  i2 pls_integer;

  -- �������� ������� ��� �������� ������ ( �� �������)
  k pls_integer := null;

begin
  loop
    i2 := len + 1;
    if i2 - i > Max_OutputLength then
      i2 := i + Max_OutputLength;

      -- �������� ������� ������ �� ������� ����� ������
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
end logDbOut;

/* ifunc: logDebugDbOut
  ������� ���������� ��������� ����� dbms_output c ��������� ������� �
  ��������� �� ����������, � ����� ��������� ����� � ������������ � �������
  ������ ����������� ���������.

  ���������:
  messageText                 - ����� ���������
*/
procedure logDebugDbOut(
  messageText varchar2
)
is

  -- ������� ����� ( �� ����������)
  curTime timestamp:= systimestamp;

  -- �������� ����� ���������� �����������
  timeInterval interval day to second :=
    curTime - previousDebugTimeStamp;

begin
  logDbOut(
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
end logDebugDbOut;

/* iproc: prepareLogRow
  ��������� ��������� ���� ������ ������� <lg_log> ����� ��������.

  ���������:
  logRec                      - ������ ������ ������� <lg_log>
                                (�����������)
*/
procedure prepareLogRow(
  logRec in out nocopy lg_log%rowtype
)
is
begin
  if logRec.log_id is null then
    logRec.log_id := lg_log_seq.nextval;
  end if;
  if logRec.operator_id is null then
    logRec.operator_id := getCurrentOperatorId();
  end if;
  if logRec.date_ins is null then
    logRec.date_ins := sysdate;
  end if;

  if lastSessionid is null then
    lastSessionid := sys_context('USERENV','SESSIONID');
    if nullif( lastSessionid, 0) is null then
      lastSessionid := - logRec.log_id;
    end if;
  end if;
  logRec.sessionid := lastSessionid;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '������ ��� ���������� ��������� ����� ������.'
    , true
  );
end prepareLogRow;

/* ifunc: logTable
  ��������� ��������� � ������� ����.

  ���������:
  levelCode                   - ��� ������ ���������
  messageText                 - ����� ���������
  loggerUid                   - ������������� ������������� ������
*/
procedure logTable(
  levelCode varchar2
  , messageText varchar2
  , loggerUid varchar2
)
is

  pragma autonomous_transaction;

  lgr lg_log%rowtype;

  truncMessageText varchar2(4000);

begin
  lgr.level_code := levelCode;
  lgr.message_text := substr( messageText, 1, 4000);
  if loggerUid is not null then
    lgr.module_name := colLogger( loggerUid).moduleName;
    lgr.object_name := colLogger( loggerUid).objectName;
    if colLogger( loggerUid).isNeedFindModuleId then
      begin
        setLoggerModuleId( loggerUid => loggerUid);
      exception when others then
        logTable(
          levelCode     => pkg_Logging.Error_LevelCode
          , messageText => logger.getErrorStack()
          , loggerUid   => internalLoggerUid
        );
      end;
    end if;
    lgr.module_id := colLogger( loggerUid).moduleId;
  end if;

  prepareLogRow( lgr);

  -- ��������� ������������� � Scheduler
  lgr.parent_log_id := lastParentLogId;
  lgr.message_type_code :=
    case levelCode
      when pkg_Logging.Fatal_LevelCode then
        Error_MessageTypeCode
      when pkg_Logging.Error_LevelCode then
        Error_MessageTypeCode
      when pkg_Logging.Warn_LevelCode then
        Warning_MessageTypeCode
      when pkg_Logging.Info_LevelCode then
        Info_MessageTypeCode
      when pkg_Logging.Debug_LevelCode then
        Debug_MessageTypeCode
      when pkg_Logging.Trace_LevelCode then
        Debug_MessageTypeCode
    end
  ;

  insert into
    lg_log
  values
    lgr
  ;
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

  -- ������ logDebugDbOut
  dbOutError varchar2( 4000);

begin
  if isMessageEnabled( coalesce( loggerUid, Root_LoggerUid), levelCode) then

    -- ����� ����� dbms_output
    -- (���� ���� ������ ���� ���� �� ������ � �������� ��)
    if forcedDestinationCode = pkg_Logging.DbmsOutput_DestinationCode
      or forcedDestinationCode is null and pkg_Common.isProduction() = 0
    then
      begin
        logDebugDbOut(
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

      -- �������� ������ ���������� dbms_output
      if dbOutError is not null then
        logTable(
          levelCode     => pkg_Logging.Error_LevelCode
          , messageText =>
              '������ ������ � ����� dbms_output: "'  || dbOutError || '".'
              || ' ���������: levelCode="' || levelCode || '"'
                || ', messageText="' || messageText || '".'
          , loggerUid   => internalLoggerUid
        );
      end if;
      logTable(
        levelCode       => levelCode
        , messageText   => messageText
        , loggerUid     => loggerUid
      );
    end if;
  end if;
end logMessage;



/* group: ���������� ������� ������ */

/* func: getLoggerUid
  ���������� ���������� ������������� ������.
  ��� ���������� ���������������� ������ ������� �����.

  ���������:
  loggerName                  - ��� ������
                                (�� ��������� ����������� �� moduleName �
                                objectName)
  moduleName                  - ��� ������
                                (�� ��������� ���������� �� loggerName)
  objectName                  - ��� ������� � ������ (������, ����, �������)
                                (�� ��������� ���������� �� loggerName)
  findModuleString            - ������ ��� ����������� Id ������ � ModuleInfo
                                (����� ��������� � ����� �� ���� ���������
                                ������: ���������, ����� � ��������� ��������,
                                �������������� ����� � ��������� �������� �
                                Subversion)
                                (�� ��������� ������������ moduleName)

  �������:
  - ������������� ������������� ������
*/
function getLoggerUid(
  loggerName varchar2
  , moduleName varchar2
  , objectName varchar2
  , findModuleString varchar2
)
return varchar2
is

  -- Uid ������
  loggerUid TLoggerUid;



  /*
    ���������� logger.errorStack ���� �������� ���������� �����.
  */
  function errorStack(
    errorMessage varchar2
  )
  return varchar2
  is
  begin
    return
      case when logger is not null then
        logger.errorStack( errorMessage)
      else
        errorMessage
      end
    ;
  end errorStack;



  /*
    ������� ���������� �����.
  */
  procedure createLogger
  is

    -- ������ ������������ ������
    r TLogger;

    -- ������� ����������� ����� ����� ������ � loggerName
    -- (����� ���� �� ������ ������)
    sepPos integer;

    -- Uid �������
    childUid TLoggerUid;

  begin

    -- ������������� ������
    if loggerName is null then
      r.moduleName := moduleName;
      r.objectName := objectName;
    else
      sepPos := instr( loggerName || '.', '.');
      r.moduleName := substr( loggerName, 1, sepPos - 1);
      r.objectName := substr( loggerName, sepPos + 1);
    end if;
    r.findModuleString := findModuleString;
    r.isNeedFindModuleId := true;
    r.levelCode := null;
    r.additive := true;
    colLogger( loggerUid) := r;

    -- ����� ������������ ��������
    r.parentUid := loggerUid;
    loop
      r.parentUid := colLogger.prior( r.parentUid);
      exit when loggerUid like r.parentUid || '%' or r.parentUid is null;
    end loop;
    colLogger( loggerUid).parentUid := r.parentUid;
    logger.trace( 'getLoggerUid: parentUid="' || r.parentUid || '"');

    -- ������������� �������� � ������������ ������ ��������
    childUid := loggerUid;
    loop
      childUid := colLogger.next( childUid);
      exit when childUid is null or childUid not like loggerUid || '%';
      if colLogger( childUid).parentUid = r.parentUid then
        colLogger( childUid).parentUid := loggerUid;
        logger.trace( 'getLoggerUid: set parent: childUid="' || childUid || '"');
      end if;
    end loop;
  end createLogger;



-- getLoggerUid
begin

  -- ���������� �����������, ���� ��������
  if logger is not null and logger.isDebugEnabled() then
    logger.debug(
      'getLoggerUid: loggerName="' || loggerName || '"'
      || ', moduleName="' || moduleName || '"'
      || ', objectName="' || objectName || '"'
      || ', findModuleString="' || findModuleString || '"'
    );
  end if;

  if loggerName is not null
        and ( moduleName is not null or objectName is not null)
      then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '������������� �������� ����� ������'
        || ' � ����� ������/������� �����������.'
    );
  end if;

  -- ���������� Uid
  loggerUid := getLoggerUidByName( coalesce(
    loggerName
    , moduleName
      || case when objectName is not null then
          '.' || objectName
        end
  ));

  -- ������� �����, ���� ��� ���
  if not colLogger.exists( loggerUid) then
    createLogger();
  end if;

  -- ���������� �����������, ���� ��������
  if logger is not null and logger.isDebugEnabled() then
    logger.trace( 'getLoggerUid: return: "' || loggerUid || '"');
  end if;
  return loggerUid;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
      -- ���������� ����� ����� �������������, ������� ���������� errorStack
    , errorStack(
        '������ ��� ��������� �������������� ������ ('
        || ' loggerName="' || loggerName || '"'
        || ', moduleName="' || moduleName || '"'
        || ', objectName="' || objectName || '"'
        || ', findModuleString="' || findModuleString || '"'
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

  -- ���� ������������
  additive boolean;

begin
  additive := colLogger( loggerUid).additive;
  logger.debug( 'getAdditivity: loggerUid="' || loggerUid || '"' || ', result='
    || case additive when true then 'true' when false then 'false' end
  );
  return additive;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
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
  logger.debug( 'setAdditivity: loggerUid="' || loggerUid || '"' || ', additive='
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
    , logger.errorStack(
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

  -- ��� ������ �����������
  levelCode lg_level.level_code%type;

begin
  levelCode := colLogger( loggerUid).levelCode;
  logger.debug( 'getLevel: loggerUid="' || loggerUid || '"'
    || ', result="' || levelCode || '"'
  );
  return levelCode;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
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
  logger.debug( 'setLevel: loggerUid="' || loggerUid || '"'
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
    , logger.errorStack(
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

  -- ��� ������ �����������
  levelCode lg_level.level_code%type;

begin
  levelCode := getLoggerEffectiveLevel( loggerUid);
  logger.debug( 'getEffectiveLevel: loggerUid="' || loggerUid || '"'
    || ', result="' || levelCode || '"'
  );
  return levelCode;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
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
    , logger.errorStack(
        '������ ��� �������� ����������� ��������� ('
        || ' loggerUid="' || loggerUid || '"'
        || ', levelCode="' || levelCode || '"'
        || ').'
      )
    , true
  );
end isEnabledFor;




/* group: ������������� � Scheduler */

/* proc: beforeInsertLogRow
  ���������� ��� ���������������� ������� ������� �� ������ ������� �� ��������
  �� ������� <lg_log>.

  ���������:
  logRec                      - ������ ������ ������� <lg_log>
                                (�����������)
*/
procedure beforeInsertLogRow(
  logRec in out nocopy lg_log%rowtype
)
is
begin
  logRec.level_code :=
    case logRec.message_type_code
      when Error_MessageTypeCode then
        pkg_Logging.Error_LevelCode
      when Warning_MessageTypeCode then
        pkg_Logging.Warn_LevelCode
      when Info_MessageTypeCode then
        pkg_Logging.Info_LevelCode
      when Debug_MessageTypeCode then
        pkg_Logging.Debug_LevelCode
      else
        pkg_Logging.Info_LevelCode
    end
  ;

  prepareLogRow( logRec);

  -- ��������� ������������� � Scheduler
  lastParentLogId :=
    case
      when logRec.message_type_code in (
            'BSTART'
            , 'JSTART'
          )
          then
        logRec.log_id
      else
        logRec.parent_log_id
    end
  ;
end beforeInsertLogRow;



-- pkg_LoggingInternal
begin
  initialize();
end pkg_LoggingInternal;
/
