create or replace package body pkg_LoggingInternal is
/* package body: pkg_LoggingInternal::body */



/* group: ���� */

/* itype: IdStrT
  ������������� ��������� �������������� (������ �����) � ���� ������ (���).
*/
subtype IdStrT is varchar2(39);

/* itype: FindModuleStringT
  ������ ��� ����������� Id ������ (���).
  ������������ ����� ������ ���� �� ������, ��� � ���� module_name �������
  <lg_log>.
*/
subtype FindModuleStringT is varchar2(128);

/* itype: LogRecT
  ������ ������� ���� (���).
*/
subtype LogRecT is lg_log%rowtype;

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



/* group: �������� ���������� */

/* itype: GetContextTypeCacheKeyT
  ��� ����� �������������� ������� <GetContextTypeCacheT>.
  ����������� ��� "<moduleId>:<contextTypeShortName>".
*/
subtype GetContextTypeCacheKeyT is varchar2(100);

/* itype: GetContextTypeCacheItemT
  ��� �������� �������������� ������� <GetContextTypeCacheT>.
*/
type GetContextTypeCacheItemT is record(
  context_type_id lg_context_type.context_type_id%type
  , nested_flag lg_context_type.nested_flag%type
);

/* itype: GetContextTypeCacheT
  ��� ����������� ����������� ���������� ���� ��������� ��������
  <getContextType> (���).
*/
type GetContextTypeCacheT is table of
  GetContextTypeCacheItemT
index by
  GetContextTypeCacheKeyT
;

/* ivar: getContextTypeCache
  ��� ����������� ����������� ���������� ���� ��������� ��������
  <getContextType>.
*/
getContextTypeCache GetContextTypeCacheT;

/* itype: OpenContextColT
  ������ �������� ���������� ���������� (���).
*/
type OpenContextColT is table of LogRecT index by IdStrT;

/* ivar: openContextCol
  ������ �������� ���������� ����������.
  ��������� ������������� ������ ���� �������� ��������� (���������� ��������
  <getIdStr>) �������� �������� ���������.
*/
openContextCol OpenContextColT;

/* itype: NestedCtxIdsColT
  ��������� �������������� �������� ��������� ���������� ���������� (���).
*/
type NestedCtxIdsColT is table of IdStrT;

/* ivar: nestedCtxIdsCol
  ��������� �������������� �������� ��������� ���������� ����������.
  ������� ����������� �������� �������� � ���������.
*/
nestedCtxIdsCol NestedCtxIdsColT := NestedCtxIdsColT();

/* itype: MappedCtxIdsColT
  ��������� �������������� �������� ������������� (�� ���������) ����������
  ���������� (���).
*/
type MappedCtxIdsColT is table of IdStrT index by pls_integer;

/* ivar: mappedCtxIdsCol
  ��������� �������������� ������������� (�� ���������) ���������� ����������.
  Id ���� ��������� (context_type_id) �������� �������� � ���������.
*/
mappedCtxIdsCol MappedCtxIdsColT;

/* itype: HiddenContextListT
  �������� ��������� ����������, ������ �� ������� �� ���� ��������� � �������
  ����.
*/
type HiddenContextListT is table of boolean index by IdStrT;

/* ivar: hiddenContextList
  �������� ��������� ����������, ������ �� ������� �� ���� ��������� � �������
  ����.
  ��������� ������������� ��������� ���������� �������� �������� ���������,
  ������� ������ ������ �� �������� ��������� ����� dbms_output ��������
  ��������� ���������.
*/
hiddenContextList HiddenContextListT;



/* group: ������� */



/* group: ��������������� ������� */

/* ifunc: getIdStr
  ���������� ������������� ��������� �������������� (������ �����) � ����
  ������.

  ���������:
  id                          - ������������� (��������)

  �������:
  ������ � ��������������� (���� <IdStrT>).

  ���������:
  - ��������� ������������� ������������ ��� �� ������� ����������, ��� �
    �������� ��������;
*/
function getIdStr(
  id integer
)
return varchar2
is
begin
  return
    to_char(
      id
      , case when id < 0 then
            's00000000000000000000000000000000000009'
        else
          'fm000000000000000000000000000000000000009'
        end
    )
  ;
end getIdStr;



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
  raiseNotFoundFlag           - ����������� �� ���������� � ������ ����������
                                ������ (1 �� , 0 ��� (�� ���������))
*/
procedure setLoggerModuleId(
  loggerUid varchar2
  , raiseNotFoundFlag integer := null
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
        , raiseExceptionFlag  => coalesce( raiseNotFoundFlag, 0)
      );
      setLoggerModuleIdCache( findModuleString) := moduleId;
      logger.trace( 'setLoggerModuleId: found moduleId=' || moduleId);
    end if;

    colLogger( loggerUid).moduleId := moduleId;
  end if;

  if raiseNotFoundFlag = 1 and colLogger( loggerUid).moduleId is null then
    raise_application_error(
      pkg_Error.ProcessError
      , '�� ������� ���������� Id ������ ('
        || ' findModuleString="'
          || coalesce(
              colLogger( loggerUid).findModuleString
              , colLogger( loggerUid).moduleName
            )
          || '"'
        || ').'
    );
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

/* ifunc: getLoggerModuleId
  ���������� Id ������, � �������� ��������� �����, ��� �������������
  ���������� Id ������ ����������� ����������.

  ���������:
  loggerUid                   - ������������� ������������� ������

  �������:
  Id ������, � �������� ��������� �����.
*/
function getLoggerModuleId(
  loggerUid varchar2
)
return integer
is
begin
  if loggerUid = Root_LoggerUid then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '���������� ���������� Id ������ ��� ��������� ������.'
    );
  end if;
  if colLogger( loggerUid).moduleId is null then
    setLoggerModuleId(
      loggerUid             => loggerUid
      , raiseNotFoundFlag   => 1
    );
  end if;
  return colLogger( loggerUid).moduleId;
end getLoggerModuleId;

/* iproc: getContextType
  ���������� ��������� ���� ��������� ����������.

  ���������:
  contextTypeId               - Id ���� ���������
                                (�������)
  nestedFlag                  - ���� ���������� ��������� (1 ��, 0 ���)
                                (�������)
  moduleId                    - Id ������, � �������� ��������� ��� ���������
  contextTypeShortName        - ������� ������������ ���� ���������
  raiseNotFoundFlag           - ����������� �� ���������� � ������ ����������
                                ������ (1 �� ( �� ���������), 0 ���)
*/
procedure getContextType(
  contextTypeId out integer
  , nestedFlag out integer
  , moduleId integer
  , contextTypeShortName varchar2
  , raiseNotFoundFlag integer := null
)
is

  ckey GetContextTypeCacheKeyT;
  citem GetContextTypeCacheItemT;

begin
  ckey := substr( moduleId || ':'  || contextTypeShortName, 1, 100);
  if not getContextTypeCache.exists( ckey) then
    select
      min( t.context_type_id)
      , min( t.nested_flag)
    into contextTypeId, nestedFlag
    from
      lg_context_type t
    where
      t.module_id = moduleId
      and t.context_type_short_name = contextTypeShortName
      and t.deleted = 0
    ;
    if contextTypeId is not null then
      citem.context_type_id := contextTypeId;
      citem.nested_flag := nestedFlag;
      getContextTypeCache( ckey) := citem;
    end if;
  else
    contextTypeId := getContextTypeCache( ckey).context_type_id;
    nestedFlag := getContextTypeCache( ckey).nested_flag;
  end if;
  if contextTypeId is null and coalesce( raiseNotFoundFlag, 1) != 0 then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '��� ��������� �� ������.'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� ����������� ���������� ���� ��������� ('
        || ' moduleId=' || moduleId
        || ', contextTypeShortName="' || contextTypeShortName || '"'
        || ', raiseNotFoundFlag=' || raiseNotFoundFlag
        || ').'
      )
    , true
  );
end getContextType;



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

/* iproc: fillCommonField
  ��������� ����� ���� ���������.

  ���������:
  logRec                      - ������ ������ ����
                                (�����������)
  levelCode                   - ��� ������ ���������
  messageText                 - ����� ���������
  messageValue                - ������������� ��������, ��������� � ����������
  messageLabel                - ��������� ��������, ��������� � ����������
  loggerUid                   - ������������� ������
  disableDboutFlag            - ������ ������ ��������� ����� dbms_output
                                (� �.�. ����������� ��������� �� �������)
                                (1 ��, 0 ���)
*/
procedure fillCommonField(
  logRec in out nocopy LogRecT
  , levelCode varchar2
  , messageText varchar2
  , messageValue integer
  , messageLabel varchar2
  , loggerUid varchar2
  , disableDboutFlag integer
)
is
begin
  logRec.level_code := levelCode;
  logRec.message_text := substr( messageText, 1, 4000);
  logRec.message_value := messageValue;
  logRec.message_label := substr( messageLabel, 1, 128);

  if loggerUid is not null then
    logRec.module_name := colLogger( loggerUid).moduleName;
    logRec.object_name := colLogger( loggerUid).objectName;
    if colLogger( loggerUid).isNeedFindModuleId then
      begin
        setLoggerModuleId( loggerUid => loggerUid);
      exception when others then
        logMessage(
          levelCode           => pkg_Logging.Error_LevelCode
          , messageText       => logger.getErrorStack()
          , loggerUid         => internalLoggerUid
          , disableDboutFlag  => disableDboutFlag
        );
      end;
    end if;
    logRec.module_id := colLogger( loggerUid).moduleId;
  end if;

  -- ��������� ������������� � Scheduler
  logRec.parent_log_id := lastParentLogId;
  logRec.message_type_code :=
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
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '������ ��� ���������� ����� ����� ������ ����.'
    , true
  );
end fillCommonField;

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
    if logRec.open_context_flag in ( 1, -1)
          and logRec.open_context_log_id is null
        then
      logRec.open_context_log_id := logRec.log_id;
    end if;
  end if;
  if logRec.log_time is null then
    logRec.log_time := current_timestamp;
    if logRec.open_context_flag in ( 1, -1)
          and logRec.open_context_log_time is null
        then
      logRec.open_context_log_time := logRec.log_time;
    end if;
  end if;
  if logRec.operator_id is null then
    logRec.operator_id := getCurrentOperatorId();
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
  logRec                         - ������ � ����������
*/
procedure logTable(
  logRec in out nocopy LogRecT
)
is

  pragma autonomous_transaction;

begin
  if logRec.date_ins is null then
    logRec.date_ins := sysdate;
  end if;
  insert into
    lg_log
  values
    logRec
  ;
  commit;
  --dbms_output.put_line(
  --  'logTable: log_id=' || logRec.log_id || ', text: ' || logRec.message_text
  --);
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '������ ��� ���������� ��������� � ������� ���� ('
      || 'log_id=' || logRec.log_id
      || ', context_level=' || logRec.context_level
      || ', context_type_id=' || logRec.context_type_id
      || ', context_value_id=' || logRec.context_value_id
      || ', open_context_log_id=' || logRec.open_context_log_id
      || ', open_context_flag=' || logRec.open_context_flag
      || ', context_type_level=' || logRec.context_type_level
      || ', module_id=' || logRec.module_id
      || ', parent_log_id=' || logRec.parent_log_id
      || ').'
    , true
  );
end logTable;

/* iproc: outputMessage
  ������� ���������.

  ���������:
  isDboutEnabled              - ������� ������ ����� dbms_output
  isTableEnabled              - ������� ������ � ������� ����
*/
procedure outputMessage(
  logRec in out nocopy LogRecT
  , isDboutEnabled boolean
  , isTableEnabled boolean
)
is
begin
  if isTableEnabled then
    logTable( logRec => logRec);
  end if;
  if isDboutEnabled then
    begin
      logDebugDbOut(
        rpad( logRec.level_code, 5) || ': ' || logRec.message_text
      );
    exception when others then
      logMessage(
        levelCode             => pkg_Logging.Error_LevelCode
        , messageText         =>
            '������ ������ ����� dbms_output:'
            || chr(10) || logger.getErrorStack()
            || chr(10) || '(���������� ���������:'
            || ' levelCode="' || logRec.level_code || '"'
            || ', messageText="' || logRec.message_text || '").'
        , loggerUid           => internalLoggerUid
        , disableDboutFlag    => 1
      );
    end;
  end if;
end outputMessage;

/* proc: logMessage
  �������� ���������.

  ���������:
  levelCode                   - ��� ������ ���������
  messageText                 - ����� ���������
  messageValue                - ������������� ��������, ��������� � ����������
                                (�� ��������� �����������)
  messageLabel                - ��������� ��������, ��������� � ����������
                                (�� ��������� �����������)
  contextTypeShortName        - ������� ������������ ����
                                ������������/������������ ��������� ����������
                                (�� ��������� �����������)
  contextValueId              - �������������, ��������� �
                                �����������/����������� ���������� ����������
                                (�� ��������� �����������)
  openContextFlag             - ���� �������� ��������� ����������
                                (1 �������� ���������, 0 �������� ���������,
                                -1 �������� � ����������� �������� ���������,
                                null �������� �� ��������)
                                (�� ��������� -1 ���� ������
                                contextTypeShortName, ����� null)
  contextTypeModuleId         - Id ������ � ModuleInfo, � �������� ���������
                                �����������/����������� �������� ����������
                                (�� ��������� Id ������, � �������� ���������
                                �����)
  loggerUid                   - ������������� ������
                                (�� ��������� �������� �����)
  disableDboutFlag            - ������ ������ ��������� ����� dbms_output
                                (� �.�. ����������� ��������� �� �������)
                                (1 ��, 0 ��� (�� ���������))


  ���������:
  - ������� ���������� �� ��������� ������� ��������� �� ������������ ��
    � ������� <lg_log>, � �� �������� �� ����� ����� dbms_output
*/
procedure logMessage(
  levelCode varchar2
  , messageText varchar2
  , messageValue integer := null
  , messageLabel varchar2 := null
  , contextTypeShortName varchar2 := null
  , contextValueId integer := null
  , openContextFlag integer := null
  , contextTypeModuleId integer := null
  , loggerUid varchar2 := null
  , disableDboutFlag integer := null
)
is

  -- Uid ������ ��� ������� ���������
  messageLoggerUid TLoggerUid;

  -- ������ ������ ����
  lgr LogRecT;

  -- ������� ��������� ���������
  isChangeContext boolean := false;

  -- �������� ����� ����� dbms_output
  isDboutEnabled boolean := false;

  -- �������� ����� � �������
  isTableEnabled boolean := false;

  -- ������� ������ ��������� (����� ��������)
  isOutput boolean := false;




  /*
    ��������� ���� ���������� ���������, ���������� false � ������ ������.
  */
  function fillNestedContextField
  return boolean
  is

    -- ���������� ����������
    isOk boolean := true;

    -- ��������� ������������� ����������� ���������� ��������� � ��� �� �����
    -- � ���������
    prevIds IdStrT;

    -- ��������� ������������� ����������� ���������� ��������� � ��� �� �����
    prevTypeIds IdStrT;



    /*
      ����� ���������� ��������� ���������� ��������� � ��� �� ����� �
      �����-���������.
    */
    procedure findOpenContext
    is

      i pls_integer;
      ids IdStrT;

    begin
      i := nestedCtxIdsCol.last();
      while i is not null loop
        ids := nestedCtxIdsCol( i);
        if openContextCol( ids).context_type_id = lgr.context_type_id then
          if prevTypeIds is null then
            prevTypeIds := ids;
          end if;
          if coalesce(
                openContextCol( ids).context_value_id = lgr.context_value_id
                , coalesce(
                    lgr.context_value_id
                    , openContextCol( ids).context_value_id
                  ) is null
              )
              then
            prevIds := ids;
            exit;
          end if;
        end if;
        i := nestedCtxIdsCol.prior( i);
      end loop;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , '������ ��� ������ ��������� ��������� ���� �� ����.'
        , true
      );
    end findOpenContext;



  -- fillNestedContextField
  begin
    findOpenContext();
    if lgr.open_context_flag in ( 1, -1) then
      lgr.context_level := nestedCtxIdsCol.count() + 1;
      lgr.context_type_level :=
        case when prevTypeIds is not null then
          openContextCol( prevTypeIds).context_type_level + 1
        else
          1
        end
      ;
    else
      if prevIds is not null then
        lgr.context_level       := openContextCol( prevIds).context_level;
        lgr.context_type_level  := openContextCol( prevIds).context_type_level;
        lgr.open_context_log_id := openContextCol( prevIds).log_id;
        lgr.open_context_log_time := openContextCol( prevIds).log_time;
      else
        isOk := false;
        logger.error(
          '����������� ��������������� �������� ��������� ��������,'
          || ' �������� ��������������� ('
          || ' contextTypeShortName="' || contextTypeShortName || '"'
          || ', contextValueId=' || contextValueId
          || ', context_type_id=' || lgr.context_type_id
          || case when messageLoggerUid != Root_LoggerUid then
              ', logger.moduleName="'
                || colLogger( messageLoggerUid).moduleName || '"'
              || ', logger.objectName="'
                || colLogger( messageLoggerUid).objectName || '"'
            end
          || case when length( messageText) > 500 then
              ', messageText(first 500 chars)="'
                || substr( messageText, 1, 500) || '"'
            else
              ', messageText="' || messageText || '"'
            end
          || ').'
        );
      end if;
    end if;
    return isOk;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , '������ ��� ���������� ����� ���������� ���������.'
      , true
    );
  end fillNestedContextField;



  /*
    ��������� ���� �������������� ���������, ���������� false � ������ ������.
  */
  function fillMappedContextField
  return boolean
  is

    -- ���������� ����������
    isOk boolean := true;

  begin
    if lgr.open_context_flag = 0 then
      if mappedCtxIdsCol.exists( lgr.context_type_id) then
        lgr.open_context_log_id :=
          openContextCol( mappedCtxIdsCol( lgr.context_type_id)).log_id
        ;
        lgr.open_context_log_time :=
          openContextCol( mappedCtxIdsCol( lgr.context_type_id)).log_time
        ;
      else
        isOk := false;
        logger.error(
          '����������� ��������������� �������� ��������� ��������,'
          || ' �������� ��������������� ('
          || ' contextTypeShortName="' || contextTypeShortName || '"'
          || ', context_type_id=' || lgr.context_type_id
          || case when messageLoggerUid != Root_LoggerUid then
              ', logger.moduleName="'
                || colLogger( messageLoggerUid).moduleName || '"'
              || ', logger.objectName="'
                || colLogger( messageLoggerUid).objectName || '"'
            end
          || case when length( messageText) > 500 then
              ', messageText(first 500 chars)="'
                || substr( messageText, 1, 500) || '"'
            else
              ', messageText="' || messageText || '"'
            end
          || ').'
        );
      end if;
    end if;
    return isOk;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , '������ ��� ���������� ����� �������������� ���������.'
      , true
    );
  end fillMappedContextField;



  /*
    ��������� ���� ��������� ����������.
  */
  procedure fillContextField
  is

    contextTypeModuleId integer := logMessage.contextTypeModuleId;

    -- ���� ���������� ���������
    nestedFlag lg_context_type.nested_flag%type;

    -- ������� ��������� ����������
    isOk boolean;

  -- fillContextField
  begin
    if openContextFlag not in ( -1, 0, 1) then
      raise_application_error(
        pkg_Error.IllegalArgument
        , '������������ �������� ����� �������� ��������� ('
          || ' openContextFlag=' || openContextFlag
          || ').'
      );
    end if;
    if contextTypeModuleId is null then
      contextTypeModuleId := getLoggerModuleId( loggerUid => messageLoggerUid);
    end if;
    getContextType(
      contextTypeId           => lgr.context_type_id
      , nestedFlag            => nestedFlag
      , moduleId              => contextTypeModuleId
      , contextTypeShortName  => contextTypeShortName
    );
    lgr.context_value_id := contextValueId;
    lgr.open_context_flag := coalesce( openContextFlag, -1);
    if nestedFlag = 1 then
      isOk := fillNestedContextField();
    else
      isOk := fillMappedContextField();
    end if;

    -- ������� ���� ��������� � ������ ������
    if not isOk then
      lgr.context_type_id := null;
      lgr.context_value_id := null;
      lgr.open_context_flag := null;
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , '������ ��� ���������� ����� ��������� ����������.'
      , true
    );
  end fillContextField;



  /*
    ������� ����� �� ���������� ������ �������� ���������.
  */
  procedure outputSkipOpenContext
  is

    -- �������� ������������� ������ ����� dbms_output
    isToDbout boolean;

    i IdStrT;

  begin
    i := hiddenContextList.first();
    while i is not null loop
      if openContextCol( i).context_level <= lgr.context_level
            -- ��� �������� ������� ������������� ����������� ���������
            -- ���������
            or lgr.context_type_level is not null
              and lgr.open_context_flag = 0
          then
        isToDbout := isDboutEnabled and not hiddenContextList( i);
        if isToDbout or isTableEnabled then
          -- ������������ ������ �� ������������ ������ ����� ���������
          -- ��������� ������� ������ � ������ ���������� ��� ������
          if isTableEnabled then
            hiddenContextList.delete( i);
          elsif isToDbout then
            hiddenContextList( i) := true;
          end if;
          outputMessage(
            logRec              => openContextCol( i)
            , isDboutEnabled    => isToDbout
            , isTableEnabled    => isTableEnabled
          );
        end if;
      end if;
      i := hiddenContextList.next( i);
    end loop;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , '������ ��� ������ ������� �������� ���������.'
      , true
    );
  end outputSkipOpenContext;



  /*
    ��������� �������������� �������� ���������.
  */
  procedure autoCloseContext
  is



    /*
      ��������� �������������� �������� ���������.
    */
    procedure processAutoClose(
      i varchar2
    )
    is

      -- ������� ������ � hiddenContextList
      isHidden boolean;

      -- �������� ������������� ������ � ��������������� ����������
      isToDbout boolean;
      isToTable boolean;

      acr LogRecT;

    begin
      isHidden := hiddenContextList.exists( i);
      isToDbout := isDboutEnabled and not (isHidden and hiddenContextList( i));
      isToTable := isTableEnabled and not isHidden;
      if isHidden then
        hiddenContextList.delete( i);
      end if;
      if isToDbout or isToTable then
        acr.context_level         := nestedCtxIdsCol.count();
        acr.context_type_id       := openContextCol( i).context_type_id;
        acr.context_value_id      := openContextCol( i).context_value_id;
        acr.open_context_log_id   := openContextCol( i).open_context_log_id;
        acr.open_context_log_time := openContextCol( i).open_context_log_time;
        acr.open_context_flag     := 0;
        acr.context_type_level    := openContextCol( i).context_type_level;
        acr.module_name           := openContextCol( i).module_name;
        acr.object_name           := openContextCol( i).object_name;
        acr.module_id             := openContextCol( i).module_id;
        fillCommonField(
          logRec              => acr
          , levelCode         => openContextCol( i).level_code
          , messageText       => '�������������� �������� ���������'
          , messageValue      => null
          , messageLabel      => null
          , loggerUid         => null
          , disableDboutFlag  => disableDboutFlag
        );
        if isToTable then
          prepareLogRow( acr);
        end if;
      end if;
      openContextCol.delete( i);
      if isToDbout or isToTable then
        outputMessage(
          logRec              => acr
          , isDboutEnabled    => isToDbout
          , isTableEnabled    => isToTable
        );
      end if;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , '������ ��� �������� ��������� ('
          || ' i="' || i || '"'
          || ').'
        , true
      );
    end processAutoClose;



  -- autoCloseContext
  begin
    if lgr.context_type_level is not null then
      for i in reverse
            lgr.context_level
              + case when lgr.open_context_flag = 0 then 1 else 0 end
            .. nestedCtxIdsCol.count()
          loop
        processAutoClose( nestedCtxIdsCol(i));
        nestedCtxIdsCol.trim( 1);
      end loop;
    else
      if lgr.open_context_flag in ( 1, -1)
            and mappedCtxIdsCol.exists( lgr.context_type_id)
          then
        processAutoClose( mappedCtxIdsCol( lgr.context_type_id));
        mappedCtxIdsCol.delete( lgr.context_type_id);
      end if;
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , '������ ��� ���������� ��������������� �������� ���������.'
      , true
    );
  end autoCloseContext;



  /*
    �������� ������� ��������.
  */
  procedure changeContext
  is

    -- ��������� ������������� �������� ���������
    ids IdStrT;

  begin
    ids := getIdStr( lgr.open_context_log_id);

    -- ����� �������� ��� �������� ��������� ������ ����
    if lgr.open_context_flag = 1 then
      openContextCol( ids) := lgr;
      if not ( isOutput and isTableEnabled) then
        hiddenContextList( ids) := isOutput and isDboutEnabled;
        --dbms_output.put_line( 'hiddenContextList: add: ' || ids);
      end if;
    end if;

    -- �������� ��� ���������� ���������
    if lgr.context_type_level is not null then
      if lgr.open_context_flag = 1 then
        nestedCtxIdsCol.extend( 1);
        nestedCtxIdsCol( lgr.context_level) := ids;
      else
        for i in reverse lgr.context_level .. nestedCtxIdsCol.count() loop
          if hiddenContextList.exists( nestedCtxIdsCol( i)) then
            hiddenContextList.delete( nestedCtxIdsCol( i));
          end if;
          openContextCol.delete( nestedCtxIdsCol( i));
          nestedCtxIdsCol.trim( 1);
        end loop;
      end if;
      if coalesce( nestedCtxIdsCol.count()
            != lgr.context_level + lgr.open_context_flag - 1, true)
          then
        raise_application_error(
          pkg_Error.ProcessError
          , '����� ��������� � nestedCtxIdsCol �� ������������� ������'
            || ' ����������� ��������� ('
            || ' nestedCtxIdsCol.count()=' || nestedCtxIdsCol.count()
            || ', lgr.context_level=' || lgr.context_level
            || ', lgr.open_context_flag=' || lgr.open_context_flag
            || ').'
        );
      end if;

    -- �������� ��� �������������� ���������
    else
      if lgr.open_context_flag = 1 then
        mappedCtxIdsCol( lgr.context_type_id) := ids;
      else
        if hiddenContextList.exists( ids) then
          hiddenContextList.delete( ids);
        end if;
        openContextCol.delete( ids);
        mappedCtxIdsCol.delete( lgr.context_type_id);
      end if;
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , '������ ��� ��������� �������� ���������.'
      , true
    );
  end changeContext;



  /*
    ���������� ������, ���� �������� ��������� ���� �������� ����� �����
    ��������� ����������.
  */
  function isOutputForAny(
    openContextIds varchar2
    , forDbout boolean
    , forTable boolean
  )
  return boolean
  is

    isDbout boolean;
    isTable boolean;

  begin
    isTable := not hiddenContextList.exists( openContextIds);
    isDbout :=
      -- ���� � �������� � ������, ��� � ����� dbms_output ����
      -- (�.�. ����� � ���� ������ ���������� ����������)
      isTable
      or not isTable
        and hiddenContextList( openContextIds)
    ;
    return
      forDbout and isDbout
      or forTable and isTable
    ;
  end isOutputForAny;



-- logMessage
begin
  --dbms_output.put_line( 'logMessage: text: '|| messageText);
  messageLoggerUid := coalesce( loggerUid, Root_LoggerUid);
  if contextTypeShortName is null
        and (
          contextValueId is not null
          or openContextFlag is not null
          or contextTypeModuleId is not null
        )
      then
    raise_application_error(
      pkg_Error.IllegalArgument
      , '�� ������ ��� ��������� ���������� (contextTypeShortName).'
    );
  end if;
  if contextTypeShortName is not null then
    fillContextField();
  end if;

  isChangeContext := lgr.open_context_flag is not null;
  if lgr.context_level is null then
    lgr.context_level := coalesce(
      nullif( nestedCtxIdsCol.count(), 0)
      , case when isChangeContext or mappedCtxIdsCol.count() > 0 then 0 end
    );
  end if;

  isDboutEnabled :=
    coalesce( disableDboutFlag, 0) != 1
    -- ���� ���� ������ ���� ������ ���� �� ������ � �������� ��
    and (
      forcedDestinationCode = pkg_Logging.DbmsOutput_DestinationCode
      or forcedDestinationCode is null and pkg_Common.isProduction() = 0
    )
  ;
  isTableEnabled :=
    -- ���� ������ ������� ���� �� ������
    nullif( forcedDestinationCode, pkg_Logging.Table_DestinationCode) is null
  ;
  isOutput :=
    ( isDboutEnabled or isTableEnabled)
      and isMessageEnabled( messageLoggerUid, levelCode)
    -- ���������� �� ������ ��������� ������� �������� ��������� ����
    -- ����� ���� �������� ��������
    or lgr.open_context_flag = 0
      and isOutputForAny(
        openContextIds  => getIdStr( lgr.open_context_log_id)
        , forDbout      => isDboutEnabled
        , forTable      => isTableEnabled
      )
  ;
  if isOutput then
    outputSkipOpenContext();
  end if;
  if isChangeContext then
    autoCloseContext();
  end if;

  -- ��������� ������� ������ � ������ �������� ��������� (�.�. ��� ����� ����
  -- �������� ����� � ����� ����������)
  if lgr.open_context_flag = 1 or isOutput then
    fillCommonField(
      logRec              => lgr
      , levelCode         => levelCode
      , messageText       => messageText
      , messageValue      => messageValue
      , messageLabel      => messageLabel
      , loggerUid         => messageLoggerUid
      , disableDboutFlag  => disableDboutFlag
    );
    if lgr.open_context_flag = 1 or isTableEnabled then
      prepareLogRow( lgr);
    end if;
  end if;
  if isOutput then
    outputMessage(
      logRec              => lgr
      , isDboutEnabled    => isDboutEnabled
      , isTableEnabled    => isTableEnabled
    );
  end if;

  if lgr.open_context_flag != -1 then
    changeContext();
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , '������ ��� ����������� ��������� ('
      || ' levelCode="' || levelCode || '"'
      || case when length( messageText) > 200 then
          ', messageText(first 200 chars)="'
            || substr( messageText, 1, 200) || '"'
        else
          ', messageText="' || messageText || '"'
        end
      || ', contextTypeShortName="' || contextTypeShortName || '"'
      || ', contextValueId=' || contextValueId
      || ', openContextFlag=' || openContextFlag
      || ', loggerUid="' || loggerUid || '"'
      || ').'
    , true
  );
end logMessage;



/* group: ���������� ������� ������ */

/* func: getOpenContextLogId
  ���������� Id ������ ���� �������� �������� (���������� ���������)
  ���������� ��������� (null ��� ���������� �������� ���������� ���������).
*/
function getOpenContextLogId
return integer
is

  i pls_integer;

begin
  i := nestedCtxIdsCol.last();
  return
    case when i is not null then
      openContextCol( nestedCtxIdsCol( i)).open_context_log_id
    end
  ;
end getOpenContextLogId;

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
  if logger is not null and logger.isTraceEnabled() then
    logger.trace(
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

/* func: mergeContextType
  ������� ��� ��������� ��� ���������.

  ���������:
  loggerUid                   - ������������� ������
  contextTypeShortName        - ������� ������������ ���� ���������
  contextTypeName             - ������������ ���� ���������
  nestedFlag                  - ���� ���������� ��������� (1 ��, 0 ���)
  contextTypeDescription      - �������� ���� ���������

  �������:
  - ���� �������� ��������� (0 ��� ���������, 1 ���� ��������� �������)
*/
function mergeContextType(
  loggerUid varchar2
  , contextTypeShortName varchar2
  , contextTypeName varchar2
  , nestedFlag integer
  , contextTypeDescription varchar2
)
return integer
is

  -- Id ������, � �������� ��������� ��� ���������
  moduleId integer;

  -- ���� �������� ���������
  isChanged integer := 0;

begin
  moduleId := getLoggerModuleId( loggerUid => loggerUid);
  merge into
    lg_context_type d
  using
    (
    select
      moduleId as module_id
      , contextTypeShortName as context_type_short_name
      , contextTypeName as context_type_name
      , nestedFlag as nested_flag
      , contextTypeDescription as context_type_description
      , 0 as deleted
    from
      dual
    minus
    select
      t.module_id
      , t.context_type_short_name
      , t.context_type_name
      , t.nested_flag
      , t.context_type_description
      , t.deleted
    from
      lg_context_type t
    ) s
  on (
    d.module_id = s.module_id
    and d.context_type_short_name = s.context_type_short_name
    )
  when not matched then
    insert
    (
      module_id
      , context_type_short_name
      , context_type_name
      , nested_flag
      , context_type_description
      , deleted
    )
    values
    (
      s.module_id
      , s.context_type_short_name
      , s.context_type_name
      , s.nested_flag
      , s.context_type_description
      , s.deleted
    )
  when matched then
    update set
      d.context_type_name           = s.context_type_name
      , d.nested_flag               = s.nested_flag
      , d.context_type_description  = s.context_type_description
      , d.deleted                   = s.deleted
  ;
  isChanged := sql%rowcount;
  return isChanged;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������� ��� ���������� ���� ��������� ('
        || ' loggerUid="' || loggerUid || '"'
        || ', contextTypeShortName="' || contextTypeShortName || '"'
        || ', nestedFlag=' || nestedFlag
        || case when moduleId is not null then
            ', moduleId=' || moduleId
          end
        || ').'
      )
    , true
  );
end mergeContextType;

/* proc: deleteContextType
  ������� ��� ���������.

  ���������:
  loggerUid                   - ������������� ������
  contextTypeShortName        - ������� ������������ ���� ���������

  ���������:
  - ��� ���������� ������������� � ���� ������ ��������� ���������, �����
    �������� ���� ����������� ��������;
*/
procedure deleteContextType(
  loggerUid varchar2
  , contextTypeShortName varchar2
)
is

  -- Id ������, � �������� ��������� ��� ���������
  moduleId integer;

  -- ���� �������������
  usedFlag integer;



  /*
    ��������� ������ �� ���� ���������.
  */
  procedure lockContextType
  is
  begin
    select
      (
      select
        count(*)
      from
        lg_log t
      where
        t.context_type_id = d.context_type_id
        and rownum <= 1
      )
    into usedFlag
    from
      lg_context_type d
    where
      d.module_id = moduleId
      and d.context_type_short_name = contextTypeShortName
      and d.deleted = 0
    for update of d.deleted nowait
    ;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��� ���������� ������.'
        )
      , true
    );
  end lockContextType;



-- deleteContextType
begin
  moduleId := getLoggerModuleId( loggerUid => loggerUid);
  lockContextType();
  if usedFlag = 0 then
    delete
      lg_context_type d
    where
      d.module_id = moduleId
      and d.context_type_short_name = contextTypeShortName
    ;
  else
    update
      lg_context_type d
    set
      d.deleted = 1
    where
      d.module_id = moduleId
      and d.context_type_short_name = contextTypeShortName
    ;
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������� ���� ��������� ('
        || ' loggerUid="' || loggerUid || '"'
        || ', contextTypeShortName="' || contextTypeShortName || '"'
        || case when moduleId is not null then
            ', moduleId=' || moduleId
          end
        || ').'
      )
    , true
  );
end deleteContextType;



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

  if logRec.date_ins is null then
    logRec.date_ins := sysdate;
  end if;

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
