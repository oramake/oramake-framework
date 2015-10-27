create or replace package body pkg_ProcessMonitor is

/* package body: pkg_ProcessMonitor::body */



/* group: ���������� */

/* ivar: logger
  ������������ ������ � ������ Logging
*/
  logger lg_logger_t := lg_logger_t.getLogger(
    moduleName => pkg_ProcessMonitorBase.Module_Name
    , objectName => 'pkg_ProcessMonitor'
  );



/* group: ��������� */

/* iconst: TkProf_Parameters
  ��������� ��������� ������ ��� tkprof
*/
TkProf_Parameters constant varchar2(1000) := 'print=100 sort=exeela aggregate=YES SYS=YES';

/* iconst: Trace_File_Mask
  ����� ����� ����� �����������
*/
Trace_File_Mask  constant varchar2(1000) := '$(sysdate)_$(baseFileName).txt';

/* iconst: Tkprof_File_Mask
  ����� ����� ����� ������ tkprof
*/
Tkprof_File_Mask constant varchar2(1000) := '$(sysdate)_$(baseFileName)_tkprof.txt';

/* iconst: Oracle_OsProcessName
  ��� �������� Oracle ������������ �������.
*/
Oracle_OsProcessName constant varchar2(100) := 'ORACLE.EXE';



/* group: ���� */

/* itype: TfileName
  ��� ��� ����� �����
*/
  subtype TfileName is varchar2(1000);

/* itype: TfileName
  ��� ��� ���� � �����
*/
  subtype TFilePath is varchar2(1000);



/* group: ������� */



/* group: ����������� */

/* proc: hoursToString
  ������� �������� ������� � ����� � ������.

  �������:
  - ������ � ���� "? ����� ?? �����"
*/
function hoursToString( hour number)
return varchar2
is
begin
  return
    trunc( hour) || ' �����(a) '
    || trunc( ( hour - trunc( hour)) * 60 )
    || ' �����';
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        ''
      )
    , true
  );
end hoursToString;

/* proc: sqlTraceOn(registeredSessionId)
   ��������� ����������� ��� ����������������� ������.

   ���������:
   registeredSessionId        - id ������������������ ������ ( ������ ��
                                <prm_registered_session>)
   isFinalTraceSending        - ����� �� ���������� ������
                                � ����������� �� ���������� ������
                                ��-��������� �� ����������.
   recipient                  - ����������(�) ���������
                                ��� �������� ����� � �����������.
                                ��-��������� ����������� ���� ��� ��
                                (  ������� pkg_Common.getMailAddressSource()).
   subject                    - ���� ������ ��� �������� �����.
                                ��-��������� - ���.
   sqlTraceLevel              -  ������� �����������. �� ��������� - 12
                                (��. �������� ������� ����������� � <sqlTraceOn>)
*/
procedure sqlTraceOn(
  registeredSessionId integer
  , isFinalTraceSending integer := null
  , recipient varchar2 := null
  , subject varchar2 := null
  , sqlTraceLevel integer := null
)
is
  -- �������������� ������� �����������
  usedSqlTraceLevel integer := coalesce( sqlTraceLevel, 12);
  -- ��������� ������
  sid integer;
  serial# integer;
  -- ������������� ��������
  spid number(10);
  -- ������������� ������� �����������
  sqlTraceLevelSet integer;
  -- ��������� �� �������� �������� ����������� �� ���������� �����
  isFinalTraceSendingSet integer;

  procedure getRegisteredParameter
  is
  -- ��������� ���������� ������������������ ������
  begin
    select
      (
      select
        count(1)
      from
        prm_session_action a
      where
        a.registered_session_id = registeredSessionId
        and a.session_action_code =
          pkg_ProcessMonitorBase.SendTrace_SessionActionCode
        -- �������� �� ����������
        and a.planned_time is null
      ) as is_final_trace_sending_set
      , r.sql_trace_level_set
      , r.sid
      , r.serial#
    into
      isFinalTraceSendingSet
      , sqlTraceLevelSet
      , sid
      , serial#
    from
      v_prm_registered_session r
    where
      r.registered_session_id = registeredSessionId
    ;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��������� ���������� ������������������ ������'
        )
      , true
    );
  end getRegisteredParameter;

  /* setSqlTrace
    ��������� ����������� ��� Oracle-������
  */
  procedure setSqlTrace
  is
    -- ��������� ������� ������
    currentSid integer;
    currentSerial# integer;
  begin
    currentSid := pkg_Common.getSessionSid();
    currentSerial# := pkg_Common.getSessionSerial();
    select
      p.spid as spid
    into
      spid
    from
      v$session vs
    inner join
      v$process p
    on
      p.addr=vs.paddr
    where
      vs.sid = SqlTraceOn.sid
    ;
    logger.debug( 'setSqlTrace: sid=' || to_char( sid));
    if sid = currentSid and serial# = currentSerial# then
      logger.debug( 'alter session clause');
      execute immediate 'alter session set'
        || ' events ''10046 trace name context forever, level '
        || to_char( usedSqlTraceLevel) || '''';
    else
      sys.dbms_system.set_ev(
        sid
        , serial#
        , 10046
        , usedSqlTraceLevel
        , ''
      );
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��������� Oracle-�����������'
        )
      , true
    );
  end setSqlTrace;

begin
  getRegisteredParameter;
  -- ���� ��������� ���������� �����������
  if sqlTraceLevelSet is null
    or usedSqlTraceLevel <> sqlTraceLevelSet
  then
    setSqlTrace;
    update
      v_prm_registered_session
    set
      sql_trace_level_set = sqlTraceLevel
      , spid = sqlTraceOn.spid
      , sql_trace_date = coalesce( sql_trace_date, sysdate)
    where
      registered_session_id = registeredSessionId;
  end if;
  -- ��������� ��� �������� ��������
  if isFinalTraceSending = 1 and isFinalTraceSendingSet = 0 then
    -- �������� �� ���������� c�����
    pkg_ProcessMonitorUtility.addAction(
      registeredSessionId => registeredSessionId
      , dateTime => null
      , actionCode => pkg_ProcessMonitorBase.SendTrace_SessionActionCode
      , emailRecipient => recipient
      , emailSubject => subject
    );
  -- ���� ����� ������� ��������
  elsif isFinalTraceSending = 0 and isFinalTraceSendingSet = 1 then
    pkg_ProcessMonitorUtility.deleteAction(
      registeredSessionId => registeredSessionId
      , dateTime => null
      , actionCode => pkg_ProcessMonitorBase.SendTrace_SessionActionCode
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��������� ����������� ( '
        || 'registeredSessionId=' || to_char( registeredSessionId)
        || ')'
      )
    , true
  );
end sqlTraceOn;

/* proc: sqlTraceOn
   ��������� �����������

   ���������:
   sid                        - sid ������ ( ��-��������� ������ ������� ������)
   serial#                    - serial# ������ ( ��-��������� ������ ������� ������)
   isFinalTraceSending        - ����� �� ���������� ������ � ����������� ��
                                ���������� ������. �� ���������-���.
   recipient                  - ����������(�) ��������� ��� �������� ����� �
                                �����������. �� ���������-����������� ���� ��� ��
                                ( ������ Common).
   subject                    - ���� ������ ��� �������� �����. �� ���������-���.
   sqlTraceLevel              - ������� �����������. ��-��������� 12.

   sqlTraceLevel ����� ��������� ��������� ��������:

   sqlTraceLevel=1            - �������� ����������� �������� SQL_TRACE.
                                ��������� �� ���������� �� ���������
                                SQL_TRACE=true.
   sqlTraceLevel=4            - �������� ����������� �������� SQL_TRACE �
                                ��������� � �������������� ���� ��������
                                ����������� ����������.
   sqlTraceLevel=8            - �������� ����������� �������� SQL_TRACE �
                                ��������� � �������������� ���� ���������� �
                                �������� �������� �� ������ ��������.
   sqlTraceLevel=12           - �������� ����������� �������� SQL_TRACE �
                                ��������� ��� �������� ����������� ����������,
                                ��� � ���������� �� �������� �������.
*/
procedure sqlTraceOn(
  sid integer := null
  , serial# integer := null
  , isFinalTraceSending integer := null
  , recipient varchar2 := null
  , subject varchar2 := null
  , sqlTraceLevel integer := null
)
is
  pragma autonomous_transaction;
  -- id ������������������ ������
  registeredSessionId integer;
begin
  registeredSessionId := pkg_ProcessMonitorUtility.getRegisteredSession(
    sid => coalesce( sid, pkg_Common.getSessionSid)
    , serial# => coalesce( serial#, pkg_Common.getSessionSerial)
  );
  logger.debug( 'registeredSessionId=' || to_char( registeredSessionId));
  sqlTraceOn(
    registeredSessionId => registeredSessionId
    , isFinalTraceSending => isFinalTraceSending
    , recipient => recipient
    , subject => subject
    , sqlTraceLevel => sqlTraceLevel
  );
  commit;
exception when others then
  rollback;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��������� ����������� ('
        || 'sid=' || to_char( sid)
        || ', serial#=' || to_char( serial#)
        || ', isFinalTraceSending=' || to_char(isFinalTraceSending)
        || ', recipient="' || recipient || '"'
        || ', sqlTraceLevel=' || to_char( sqlTraceLevel)
        || ')'
      )
    , true
  );
end sqlTraceOn;

/* func: copyTrace(registeredSessionId)
  ����������� ������ �����������

  ���������:
  registeredSessionId         - id ������������������ ������ ( ������ ��
                                <prm_registered_session>)
  traceCopyPath               - ���������� ��� ����������� ������ �����������
                                ( ��-��������� ������ ���������
                                  <pkg_ProcessMonitorUtility.getDefaultTraceCopyPath>)
  isSourceDeleted             - ������� �� �������� ���� ����������� (
                                ��-��������� �� �������).

  �������:
  - ���������� � ����������� � ���� ������;
*/
function copyTrace(
  registeredSessionId integer
  , traceCopyPath varchar2
  , isSourceDeleted integer := null
)
return varchar2
is
  -- ��� ����� �����������
  fileName TFileName;
  -- ����� ��� ������ �������������� ������
  traceFileMask TFileName;
  -- ���������� � trace-�������
  traceDirectory TFilePath;
  -- ��� ����� ����� �����������
  outputFileName TFileName;
  -- ��� ������ ����� �����������
  tkprofFileName TFileName;
  -- ���� ��� ����������� ������ �����������
  usedTraceCopyPath TFilePath :=
    coalesce( traceCopyPath, pkg_ProcessMonitorUtility.getDefaultTraceCopyPath);
  -- ��������� ������
  usedSid number;
  usedSpid number;
  usedSerial# number;
  -- �������������� ���������
  resultMessage varchar2( 32767);

  procedure getFilePath
  is
  -- ����������� ����� � ���� ����� �����������
    -- �������������� ��������� get_parameter_value
    l_type number;
    l_intval number;
    -- ���� ��������� �����������
    sqlTraceDate date;
    -- ��� ����
    dbName varchar2(100);
    -- ����� ��� ��������� ����� �����
    cursor curFile( sqlTraceDate date) is
      select
        file_name
      from
        tmp_file_name t
      where
        -- ����� ���� ������
        t.last_modification >= sqlTraceDate-1/24/60;
    -- ������ ��� ��������� ���������� ������
    cursor curProcess is
select
  sid
  , serial#
  , spid
  , sql_trace_date
into
  usedSid
  , usedSerial#
  , usedSpid
  , sqlTraceDate
from
  v_prm_registered_session r
where
  r.registered_session_id = registeredSessionId;

  begin
    -- �������� ��� ����������
    l_type := dbms_utility.get_parameter_value(
      'user_dump_dest'
      , l_intval
      , traceDirectory
    );
    logger.debug('l_type=' || to_char( l_type));
    logger.debug('l_intval=' || to_char( l_intval));
    -- �������� ��������� ������
    open curProcess;
    loop
      fetch
        curProcess
      into
        usedSid
        , usedSerial#
        , usedSpid
        , sqlTraceDate;
      exit when curProcess%notfound;
    end loop;
    if curProcess%rowcount > 1 then
      raise_application_error(
        pkg_Error.ProcessError
        , logger.errorStack(
            '���������� ��������� ��������� ������ 1'
          )
      );
    end if;
    close curProcess;
    logger.debug('usedSid=' || to_char( usedSid));
    logger.debug('usedSerial#=' || to_char( usedSerial#));
    logger.debug('usedSpid=' || to_char( usedSpid));
    logger.debug('sqlTraceDate='
      || '{' || to_char( sqlTraceDate, 'yyyy.mm.dd hh24:mi:ss') || '}'
    );

    if usedSid is not null then
      -- �������� ��� ����
      select
        value
      into
        dbName
      from
        v$parameter
      where
        name = 'instance_name'
      ;
      -- �������� ��� �����
      delete tmp_file_name;
      traceFileMask := dbName || '\_%\_' || to_char(usedSpid) || '.trc';
      pkg_File.fileList(
        fromPath => traceDirectory
        , fileMask => traceFileMask
      );
      open curFile( sqlTraceDate => sqlTraceDate);
      loop
        fetch
          curFile
        into
          fileName;
        exit when curFile%notfound;
      end loop;
      if curFile%rowcount > 1 then
        raise_application_error(
          pkg_Error.ProcessError
          , logger.errorStack(
              '�������� ���������� ��������� ������('
              || 'count=' || to_char( curFile%rowcount)
              || ', traceFileMask="' || traceFileMask || '"'
              || ', traceDirectory="' || traceDirectory || '"'
              || ')'
            )
        );
      end if;
      close curFile;
    end if;
    logger.debug( 'fileName="' || fileName || '"');
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��������� ����� ����� �����������'
        )
      , true
    );
  end getFilePath;

  procedure createFile
  is
  -- �������� tkprof-������ � �����������
  -- ����� �����������

    -- ��� ����� ��� ����������
    baseFileName varchar2(1000) :=
      case when
        instr( fileName, '.') > 0
      then
        substr( fileName, 1, instr(fileName, '.', -1, 1)-1 )
      else
        fileName
      end;

    function getFileByMask(
      mask varchar2
    )
    return varchar2
    is
    -- ��������� ����� ����� �� �����,
    -- � ������� ����� ����������� �������
    --   - $(baseFileName)
    --   - $(sysdate)
    begin
      return
        replace(
        replace(
          mask
          , '$(baseFileName)'
          , baseFileName
        )
          , '$(sysdate)'
          , to_char( sysdate, 'YYYYMMDD_HH24MISS')
        );
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            '������ ���������� ����� ����� �� �����('
            || 'mask="' || mask || '"'
            || ')'
          )
        , true
      );
    end getFileByMask;

  begin
    outputFileName := getFileByMask( Trace_File_Mask);
    tkprofFileName := getFileByMask( Tkprof_File_Mask);
    logger.debug( 'outputFileName="' || outputFileName || '"');
    logger.debug( 'tkprofFileName="' || tkprofFileName || '"');
    pkg_File.fileCopy(
      fromPath => pkg_File.getFilePath(
        traceDirectory
        , fileName
      )
      , toPath => pkg_File.getFilePath(
        usedTraceCopyPath
        , outputFileName
      )
      , overwrite => 1
    );
    pkg_File.execCommand(
      'tkprof.exe '
      || pkg_File.getFilePath( traceDirectory, fileName)
      || ' ' || pkg_File.getFilePath( usedTraceCopyPath, tkprofFileName)
      || ' ' || Tkprof_Parameters
    );
    if isSourceDeleted = 1 then
      pkg_File.fileDelete(
        fromPath => pkg_File.getFilePath(
          traceDirectory
          , fileName
        )
      );
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ �������� ������'
        )
      , true
    );
  end createFile;

begin
  getFilePath;
  -- ���� ���� ����������� ������
  if fileName is null then
    resultMessage := '���� ����������� �� ������ ( '
      || 'sid=' || to_char( usedSid)
      || ', serial#=' || to_char( usedSerial#)
      || ', traceFileMask="' || traceFileMask || '"'
      || ', traceDirectory="' || traceDirectory || '"'
      || ')'
    ;
  else
    createFile;
    resultMessage :=
      '���� ����������� '
      || '( sid=' || to_char( usedSid)
      || ', serial#='|| to_char( usedSerial#) || ')'
      || ' ���������� � ' || chr(10) || chr(10)
      || pkg_File.getFilePath( usedTraceCopyPath, outputFileName) || chr(10)||chr(10)
      || '���� tkprof ������ � ' || chr(10) || chr(10)
      || pkg_File.getFilePath( usedTraceCopyPath, tkprofFileName)
      || case when isSourceDeleted = 1 then
          chr(10) || chr(10)
          || '�������� ���� ����������� "' || fileName || '" �����'
         end
    ;
  end if;
  commit;
  return resultMessage;
exception when others then
  rollback;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ����������� ������ ����������� ( '
        || 'registeredSessionId=' || to_char( registeredSessionId)
        || ', traceCopyPath="'|| traceCopyPath || '"'
        || ', isSourceDeleted=' || to_char( isSourceDeleted)
        || ')'
      )
    , true
  );
end copyTrace;

/* func: copyTrace
  ����������� ������ �����������

  ���������:
  traceCopyPath               - ���������� ��� ����������� ������ �����������
                                ( ��-��������� ������ ���������
                                  <pkg_ProcessMonitorUtility.getDefaultTraceCopyPath>)
  isSourceDeleted             - ������� �� �������� ���� ����������� (
                                ��-��������� �� �������).
  sid                         - sid ������ ( ��-��������� ������ ������� ������)
  serial#                     - serial# ������ ( ��-��������� ������ ������� ������)

  �������:
    - ���������� � ����������� � ���� ������
*/
function copyTrace(
  traceCopyPath varchar2
  , isSourceDeleted integer := null
  , sid integer := null
  , serial# integer := null
)
return varchar2
is
  pragma autonomous_transaction;
  -- id ������������������ ������
  registeredSessionId integer;
begin
  registeredSessionId := pkg_ProcessMonitorUtility.getRegisteredSession(
    sid => coalesce( sid, pkg_Common.getSessionSid)
    , serial# => coalesce( serial#, pkg_Common.getSessionSerial)
  );
  logger.debug( 'registeredSessionId=' || to_char( registeredSessionId));
  return
    copyTrace(
      registeredSessionId => registeredSessionId
      , traceCopyPath => traceCopyPath
      , isSourceDeleted => isSourceDeleted
    );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ����������� ������ �����������( '
        || 'traceCopyPath="'|| traceCopyPath || '"'
        || ', isSourceDeleted=' || to_char( isSourceDeleted)
        || ', sid=' || to_char( sid)
        || ', serial#=' || to_char( serial#)
        || ')'
      )
    , true
  );
end copyTrace;

/* proc: sendTrace
  �������� ������ �� ����� ������ �����������

  ���������:
  sid                         - sid ������ ( ��-��������� ������ �������
                                ������)
  serial#                     - serial# ������ ( ��-��������� ������ �������
                                ������)
  recipient                   - ����������(�) ��������� ��� �������� ����� �
                                �����������.  ��-��������� ����������� ����
                                ��� �� ( �������
                                pkg_Common.getMailAddressSource()).
  subject                     - ���� ������ ��� �������� �����.  ��-���������
                                ����������� ��������� ������.
  isSourceDeleted             - ������� �� �������� ���� ����������� (
                                ��-��������� �� �������).
  traceCopyPath               - ���������� ��� ����������� ������ �����������
                                ( ��-��������� ������ ���������
                                  <pkg_ProcessMonitorUtility.getDefaultTraceCopyPath>)
  sqlTraceOff                 - ��������� �� ����������� ����� ���������
                                ������ (1-��).  ��-��������� �� ���������.
*/
procedure sendTrace(
  sid integer := null
  , serial# integer := null
  , recipient varchar2 := null
  , subject varchar2 := null
  , isSourceDeleted integer := null
  , traceCopyPath varchar2 := null
  , sqlTraceOff integer := null
)
is
  pragma autonomous_transaction;
  -- ����� ��������� � �����������
  messageText varchar2( 32767);
  -- ��������� ������
  vSid integer := coalesce( sid, pkg_Common.getSessionSid);
  vSerial# integer := coalesce( serial#, pkg_Common.getSessionSerial);
begin
  if sendTrace.sqlTraceOff = 1 then
    pkg_ProcessMonitor.sqlTraceOff(
      sid => sid
      , serial# => serial#
    );
  end if;
  messageText :=
    copyTrace(
      traceCopyPath => traceCopyPath
      , isSourceDeleted => isSourceDeleted
      , sid => vSid
      , serial# => vSerial#
    );
  pkg_Common.sendMail(
    mailSender => pkg_Common.getMailAddressSource(
      pkg_ProcessMonitorBase.Module_Name
    )
    , mailRecipient =>
      coalesce(
        recipient
        , pkg_Common.getMailAddressDestination
      )
    , subject =>
        coalesce(
          subject
          , '����������� '
             || '(' || to_char( vSid) || ', ' || to_char( vSerial#) || ')'
         )
    , message => messageText
  );
  commit;
exception when others then
  rollback;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ �������� ��������� � ����������� ( '
        || 'sid=' || to_char( sid)
        || ', serial#=' || to_char( serial#)
        || ', recipient="'|| recipient || '"'
        || ', subject="'|| recipient || '"'
        || ', traceCopyPath="'|| traceCopyPath || '"'
        || ', isSourceDeleted=' || to_char( isSourceDeleted)
        || ')'
      )
    , true
  );
end sendTrace;

/* proc: sqlTraceOff
  ���������� �����������

  ���������:
  sid                         - sid ������ ( ��-��������� ������� �������)
  serial#                     - serial# ������ ( ��-��������� ������� �������)
*/
procedure sqlTraceOff(
  sid integer := null
  , serial# integer := null
)
is
  -- �������������� ��������� ������
  usedSid integer;
  usedSerial# integer;
begin
  if sid is null then
    usedSid := pkg_Common.getSessionSid;
    usedSerial# := pkg_Common.getSessionSerial;
  else
    usedSid := sid;
    usedSerial# := serial#;
  end if;
  update
    v_prm_registered_session
  set
    sql_trace_level_set = null
  where
    sid = usedSid
    and serial# = usedSerial#
  ;
  sys.dbms_system.set_ev( sid, serial#, 10046, 0, '');
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ���������� ����������� ( '
        || 'sid=' || to_char( sid)
        || ', serial#=' || to_char( serial#)
        || ')'
      )
    , true
  );
end sqlTraceOff;

/* proc: batchTraceOn
  ��������� ����������� ��� ������ �����

  ���������:
  sid                         - sid ������ ( ��-��������� ������ ������� ������)
  serial#                     - serial# ������ ( ��-��������� ������ ������� ������)
  isFinalTraceSending         - ����� �� ���������� ������ � ����������� ��
                                ���������� ������
  sqlTraceLevel               - ������� ����������� (��. �������� �������
                                ����������� � <sqlTraceOn>)
  batchShortName              - ������������ �����
*/
procedure batchTraceOn(
  sid integer
  , serial# integer
  , isFinalTraceSending integer
  , sqlTraceLevel integer
  , batchShortName varchar2
)
is
begin
  sqlTraceOn(
    sid => sid
    , serial# => serial#
    , sqlTraceLevel => sqlTraceLevel
    , isFinalTraceSending => isFinalTraceSending
    , subject => batchShortName || ': �����������'
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��������� ����������� ��� ������ �����'
      )
    , true
  );
end batchTraceOn;



/* group: �������� �� ���������� */

/* proc: batchBegin
  ���������, ���������� � ������ ������ �����.

  ���������:
  sqlTraceLevel               - ������� ����������� (��. �������� �������
                                ����������� � <sqlTraceOn>)
*/
procedure batchBegin(
  sqlTraceLevel integer := null
)
is
  -- �������� ������������ �����
  batchShortName v_sch_batch.batch_short_name%type;
  -- ��������� ������
  sid integer :=  pkg_Common.getSessionSid;
  serial# integer :=  pkg_Common.getSessionSerial;
  -- ��������� ��������� �����
  isFinalTraceSending integer;
  traceTimeHour integer;
  usedSqlTraceLevel integer;
begin
  -- ��������� ��������� ��������
  select
    max( is_final_trace_sending)
    , max( trace_time_hour)
    , coalesce(
        sqlTraceLevel
        , max( sql_trace_level)
      )
    , max( batch_short_name)
  into
    isFinalTraceSending
    , traceTimeHour
    , usedSqlTraceLevel
    , batchShortName
  from
    prm_batch_config c
  where
    batch_short_name =
    (
    select
      batch_short_name
    from
      v_sch_batch
    where
      sid = batchBegin.sid
      and serial# = batchBegin.serial#
    );
  if traceTimeHour <= 0 or sqlTraceLevel is not null then
    batchTraceOn(
      sid => sid
      , serial# => serial#
      , sqlTraceLevel => sqlTraceLevel
      , isFinalTraceSending => isFinalTraceSending
      , batchShortName => batchShortName
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��������� ������ ������ �����'
      )
    , true
  );
end batchBegin;

/* proc: batchEnd
  ���������, ���������� � ����� ������ �����.
*/
procedure batchEnd
is
begin
  checkSendTrace(
    isBatchEnd => 1
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��������� ��������� ������ �����'
      )
    , true
  );
end batchEnd;

/* proc: checkTrace
  ��������� ����������� ��� ������������������ ������.
*/
procedure checkTrace
is
  pragma autonomous_transaction;
begin
  pkg_TaskHandler.initTask(
    moduleName =>  pkg_ProcessMonitorBase.Module_Name
    , processName => 'checkTrace'
  );
  for recAction in
  (
  select
    sid
    , serial#
    , v.registered_session_id
    , v.session_action_code
    , v.planned_time
  from
    v_prm_execution_action v
  where
    session_action_code =
      pkg_ProcessMonitorBase.Trace_SessionActionCode
  order by
    planned_time
  nulls last
  )
  loop
    sqlTraceOn(
      registeredSessionId => recAction.registered_session_id
    );
    pkg_ProcessMonitorUtility.completeAction(
      registeredSessionId => recAction.registered_session_id
      , dateTime => recAction.planned_time
      , actionCode => recAction.session_action_code
    );
    logger.info(
      '�������� ����������� ��� ������ ('
       || 'sid='|| to_char( recAction.sid)
       || ', serial#=' || to_char( recAction.serial#)
       || ')'
    );
  end loop;
  pkg_ProcessMonitorUtility.clearRegisteredSession;
  pkg_TaskHandler.cleanTask;
  commit;
exception when others then
  pkg_TaskHandler.cleanTask;
  rollback;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��������� ����������� ������������������ ������'
      )
    , true
  );
end checkTrace;

/* proc: checkOraKill
  ���������� oraKill ��� ������������������ ������.
*/
procedure checkOraKill
is
  pragma autonomous_transaction;
  -- ����� ���������
  messageText varchar2( 32767);
begin
  pkg_TaskHandler.InitTask(
    moduleName =>  pkg_ProcessMonitorBase.Module_Name
    , processName => 'checkOraKill'
  );
  for recAction in
  (
  select
    v.registered_session_id
    , v.planned_time
    , sid
    , serial#
    , email_recipient
    , email_subject
  from
    v_prm_execution_action v
  where
    session_action_code =
      pkg_ProcessMonitorBase.OraKill_SessionActionCode
  order by
    planned_time
  nulls last
  )
  loop
    pkg_ProcessMonitorUtility.oraKill(
      sid => recAction.sid
      , serial# => recAction.serial#
    );
    messageText :=
      '�������� orakill ��� ������ ( '
       || 'sid='|| to_char( recAction.sid)
       || ', serial#=' || to_char( recAction.serial#)
       || ')';
    pkg_Common.sendMail(
      mailSender => pkg_Common.getMailAddressSource(
        pkg_ProcessMonitorBase.Module_Name
      )
      , mailRecipient =>
          coalesce(
            recAction.email_recipient
            , pkg_Common.getMailAddressDestination
          )
      , subject =>
          coalesce( recAction.email_subject, 'orakill('
             || to_char(recAction.sid) || ',' || to_char( recAction.serial#)
             || ')'
          )
      , message => messageText
    );
    logger.info( messageText);
    pkg_ProcessMonitorUtility.completeAction(
      registeredSessionId => recAction.registered_session_id
      , dateTime => recAction.planned_time
      , actionCode => pkg_ProcessMonitorBase.OraKill_SessionActionCode
    );
  end loop;
  pkg_ProcessMonitorUtility.clearRegisteredSession;
  pkg_TaskHandler.cleanTask;
  commit;
exception when others then
  pkg_TaskHandler.cleanTask;
  rollback;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ���������� oraKill ������������������ ������'
      )
    , true
  );
end checkOraKill;

/* proc: checkSendTrace
  �������� ������ �� ����� ������ ����������� ��� ������������������ ������.

  ���������:
  isBatchEnd                  - ����� �� ��������� �������� ��� ����� �������
                                ������ (1-��) ��-��������� ���.
*/
procedure checkSendTrace(
  isBatchEnd integer := null
)
is
  pragma autonomous_transaction;
  -- �������� ������
  currentSid integer := pkg_Common.getSessionSid;
  currentSerial# integer := pkg_Common.getSessionSerial;
  -- Id ������������������ ������ ��� �������
  registeredSessionId integer :=
    case when
      isBatchEnd = 1
    then
      pkg_ProcessMonitorUtility.getRegisteredSession(
        sid => currentSid
        , serial# => currentSerial#
      )
    end;
begin
  pkg_TaskHandler.InitTask(
    moduleName =>  pkg_ProcessMonitorBase.Module_Name
    , processName => 'checkSendTrace'
  );
  for recAction in
  (
  select
    sid as sid
    , serial# as serial#
    , v.registered_session_id as registered_session_id
    , v.session_action_code as session_action_code
    , v.email_recipient as email_recipient
    , v.email_subject as email_subject
    , v.planned_time as planned_time
  from
    v_prm_execution_action v
  where
    session_action_code =
      pkg_ProcessMonitorBase.SendTrace_SessionActionCode
    and coalesce( isBatchEnd, 0) = 0
  union all
  select
    currentSid as id
    , currentSerial# as serial#
    , registeredSessionId as registered_session_id
    , a.session_action_code as session_action_code
    , a.email_recipient as email_recipient
    , a.email_subject as email_subject
    , a.planned_time as planned_time
  from

    prm_session_action a
  where
    session_action_code =
      pkg_ProcessMonitorBase.SendTrace_SessionActionCode
    and coalesce( isBatchEnd, 0) = 1
    and a.registered_session_id = registeredSessionId
  order by
    planned_time
  nulls last
  )
  loop
    sendTrace(
      sid => recAction.sid
      , serial# => recAction.serial#
      , recipient => recAction.email_recipient
      , subject => recAction.email_subject
      , isSourceDeleted =>
          case when recAction.planned_time is null then 1 end
    );
    pkg_ProcessMonitorUtility.completeAction(
      registeredSessionId => recAction.registered_session_id
      , dateTime => recAction.planned_time
      , actionCode => recAction.session_action_code
    );
    logger.info(
      '���������� ���������� � ����������� ��� ������ ('
       || 'sid='|| to_char( recAction.sid)
       || ', serial#=' || to_char( recAction.serial#)
       || ')'
    );
  end loop;
  pkg_ProcessMonitorUtility.clearRegisteredSession;
  pkg_TaskHandler.cleanTask;
  commit;
exception when others then
  pkg_TaskHandler.cleanTask;
  rollback;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ �������� ����� �� �������������� ������'
      )
    , true
  );
end checkSendTrace;

/* proc: checkBatchExecution
  ������������ ������ ������

  ���������:
  warningTimePercent          - ����� �������������� ( � ���������)
  warningTimeHour             - ����� �������������� ( � �����)
  minWarningTimeHour          - ����������� ����� �������������� ( � �����)
  abortTimeHour               - ����� ���������� ( � �����)
  orakillWaitTimeHour         - ����� ���������� ����� orakill ( � �����).
                                ����� ������� ������������� � ������
                                ���������� ������.
*/
procedure checkBatchExecution(
  warningTimePercent integer
  , warningTimeHour integer
  , minWarningTimeHour integer
  , abortTimeHour integer
  , orakillWaitTimeHour integer
  , traceCopyPath varchar2 := null
)
is
  pragma autonomous_transaction;
  -- ��������� ���������
  messageText varchar2( 32767);
  -- ��������� �� ����������� �������
  isLong boolean;
  -- �������� �� ���������� �������
  isAborted boolean;
  -- ��������� �� �����������
  isTrace boolean;

  cursor curLongBatch is
select
  l.*
from
  (
  select
    d.*
      -- ���� ������ ��������� ��� ��������� ������� �� ��������
    , greatest(
        -- ����������� �� ������������ ���������� ��� ��������������
        least(
          coalesce(
            max_execution_hour *
              case when c.batch_short_name is not null then
                c.warning_time_percent
              else
                warningTimePercent
              end
            / 100
            , execution_hour + 1
          )
          ,
          coalesce(
            case when c.batch_short_name is not null then
              c.warning_time_hour
            else
              warningTimeHour
            end
            , execution_hour + 1
          )
        )
          -- �� ������ ���� ������ minWarningTimeHour, ���� ��� �������� �����
        , coalesce(
            case when c.batch_short_name is null then
              minWarningTimeHour
            end
            , 0
          )
      ) as warning_time_hour
    , case when c.batch_short_name is not null then
        c.abort_time_hour
      else
        abortTimeHour
      end as abort_time_hour
    , case when c.batch_short_name is not null then
        c.orakill_wait_hour
      else
        orakillWaitTimeHour
      end as orakill_wait_time_hour
    , c.trace_time_hour as trace_time_hour
    , c.sql_trace_level as sql_trace_level
    , c.is_final_trace_sending as is_final_trace_sending
  from
    (
    select
      b.batch_id
      , b.batch_short_name
      , b.batch_name_rus
      , b.sid
      , b.serial#
      , ( b.duration_second / 3600) as execution_hour
      , (
        select
          max(
          (
          select
            lg.date_ins
          from
            sch_log lg
          where
            lg.parent_log_id = rl.log_id
            and lg.message_type_code = 'BFINISH'
          )
          - rl.date_ins
          ) * 24
        from
          v_sch_batch_root_log rl
        where
          rl.batch_id = b.batch_id
        )
        as max_execution_hour
      , (
        select
          count(1)
        from
          sch_schedule sd
        where
          sd.batch_id = b.batch_id
          and not exists
            (
            select
              null
            from
              sch_interval iv
            where
              iv.schedule_id = sd.schedule_id
            )
        ) as is_real_time
    from
      v_sch_batch b
    where
      b.sid is not null
      -- �� ������� ������
      and not (
        b.sid = ( select pkg_Common.getSessionSid from dual)
        and b.serial# = ( select pkg_Common.getSessionSerial from dual)
      )
    ) d
  left join
    prm_batch_config c
  on
    c.batch_short_name = d.batch_short_name
  ) l
where
  is_real_time = 0
  and
  (
    -- l.warning_time_hour ��������� warning_time_percent
    l.execution_hour > l.warning_time_hour
    or l.execution_hour > l.abort_time_hour
  )
  or l.execution_hour > l.trace_time_hour
  ;

  procedure addMessage(
    addedMessage varchar2
  )
  is
  -- ���������� ������ � ���������
  --
  -- ���������:
  --   addedMessage          - ����������� �����
  begin
    if messageText is not null then
      messageText := messageText || chr(10);
    end if;
    messageText := messageText || addedMessage;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ���������� ���������'
        )
      , true
    );
  end addMessage;

  procedure abortBatch(
    rec curLongBatch%rowtype
  )
  is
  -- ���������� ������
  begin
    pkg_ProcessMonitorUtility.abortBatch(
      batchID => rec.batch_id
      , sid => rec.sid
      , serial# => rec.serial#
    );
    addMessage(
      '�������� ���������� ������ "'
      || rec.batch_name_rus || '" [' || rec.batch_short_name || ']'
      || ' ( sid=' || rec.sid || ', serial#=' || rec.serial# || ').'
    );
  exception when others then
    addMessage(
      '������ ��� ���������� ��������� �������������� ������ ('
      || ' batch_id=' || rec.batch_id || ').'
      || chr(10) || logger.getErrorStack
    );
  end abortBatch;

  procedure checkExecution(
    rec curLongBatch%rowtype
  )
  is
  begin
    if rec.execution_hour > rec.abort_time_hour then
      isAborted := true;
      abortBatch( rec => rec);
      if rec.orakill_wait_time_hour is not null then
        pkg_ProcessMonitorUtility.addAction(
          registeredSessionId =>
            pkg_ProcessMonitorUtility.getRegisteredSession(
              sid => rec.sid
              , serial# => rec.serial#
            )
          , dateTime => sysdate + rec.orakill_wait_time_hour / 24
          , actionCode => pkg_ProcessMonitorBase.OraKill_SessionActionCode
          , emailRecipient => pkg_Common.getMailAddressDestination
          , emailSubject => rec.batch_short_name || ': Orakill'
        );
        addMessage(
          '� ������ ������������� ������ ����� '
          ||  '{' || to_char(
                       sysdate + rec.orakill_wait_time_hour / 24
                       , 'dd.mm.yyyy hh24:mi:ss'
                     ) || '} '
          || '����� �������� orakill'
        );
      end if;
    elsif rec.execution_hour > rec.warning_time_hour then
      isLong := true;
      addMessage(
        '����� "'
        || rec.batch_name_rus || '" [' || rec.batch_short_name || ']'
        || ' ����������� ���������� �����'
        || ' ( ' || hoursToString( rec.execution_hour) || ')'
      );
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ �������� ������ ����� ( '
          || ' rec.batch_short_name="' || rec.batch_short_name || '"'
          || ')'
        )
      , true
    );
  end checkExecution;

  procedure trace(
    rec curLongBatch%rowtype
  )
  is
  -- ��������� ����������� ��� �����
  -- � ���������� ��������� � ����� ������ �����������
  begin
    batchTraceOn(
      sid => rec.sid
      , serial# => rec.serial#
      , isFinalTraceSending => rec.is_final_trace_sending
      , sqlTraceLevel => rec.sql_trace_level
      , batchShortName => rec.batch_short_name
    );
    addMessage(
      chr(10) ||
      copyTrace(
        traceCopyPath =>
          coalesce(
            traceCopyPath
            , pkg_ProcessMonitorUtility.getDefaultTraceCopyPath
          )
        , sid => rec.sid
        , serial# => rec.serial#
      )
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��������� ���������� ����������� ����� ('
          || 'batch_short_name="' || rec.batch_short_name || '"'
          || ')'
        )
      , true
    );
  end trace;

  procedure sendMessage(
    rec curLongBatch%rowtype
  )
  is
  -- �������� email-���������

    -- ���� ������
    subject varchar2( 400);
  begin
    subject :=
      rec.batch_short_name ||
        case when
          isAborted
        then
          ': ����������'
        when
          isLong
        then
          ': ��������������'
        when
          isTrace
        then
          ': �����������'
        end;
    pkg_Common.sendMail(
      mailSender => pkg_Common.getMailAddressSource(
        pkg_ProcessMonitorBase.Module_Name
      )
      , mailRecipient => pkg_Common.getMailAddressDestination
      , subject => subject
      , message => messageText
    );
    logger.debug( '������ ���������� ( '
      || 'subject="' || subject || '"'
      || ', message="' || messageText || '"'
      || ')'
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ �������� email ('
          || 'batch_short_name="' || rec.batch_short_name || '"'
          || ')'
        )
      , true
    );
  end sendMessage;

begin
  pkg_TaskHandler.InitTask(
    moduleName =>  pkg_ProcessMonitorBase.Module_Name
    , processName => 'checkBatchExecution'
  );
  logger.debug( 'minWarningTimeHour=' || to_char( minWarningTimeHour));
  for rec in curLongBatch loop
    logger.debug(
      '�������� ����� ( '
      || ' batch_short_name="' || rec.batch_short_name || '"'
      || ' , sid=' || to_char( rec.sid)
      || ' , serial#=' || to_char( rec.serial#)
      || ' , execution_hour=' || to_char( rec.execution_hour)
      || ' , warning_time_hour=' || to_char( rec.warning_time_hour)
      || ' , abort_time_hour=' || to_char( rec.abort_time_hour)
      || ' , trace_time_hour=' || to_char( rec.trace_time_hour)
      || ')'
    );
    messageText := '';
    isLong := false;
    isAborted := false;
    checkExecution( rec => rec);
    isTrace := false;
    if rec.execution_hour >= rec.trace_time_hour then
      trace( rec => rec);
      isTrace := true;
    end if;
    sendMessage( rec => rec);
  end loop;
  pkg_TaskHandler.cleanTask;
  commit;
exception when others then
  pkg_TaskHandler.cleanTask;
  rollback;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ������������ ������ ������ ( '
        || 'warningTimePercent=' || to_char( warningTimePercent)
        || ', warningTimeHour=' || to_char( warningTimeHour)
        || ', abortTimeHour=' || to_char( abortTimeHour)
        || ', orakillWaitTimeHour=' || to_char( orakillWaitTimeHour)
        || ', traceCopyPath=' || to_char( traceCopyPath)
        || ')'
      )
    , true
  );
end checkBatchExecution;

/* func: getOsMemory
  ��������� ������ ������ ( � ������) �������������� ��������� Oracle.

  ���������:
  - ��������������, ��� ��� �������, ���������������� �������� �������� � ����
    ��� oracle instance;
*/
function getOsMemory
return number
is

  -- PID �������� Oracle
  oracleOsPid integer;

  /*
    ��������� ���������� ������ ������ �� ������ ���� "18�012 K".
  */
  function getMemorySize( sizeString varchar2)
  return number
  is
  begin
    return
      to_number(
        regexp_replace(
          replace(
            sizeString
            -- ����������� �������� ( ����������� ������)
            , chr(160)
            , ''
          )
          , '[,| |K]', ''
        )
      ) * 1024
    ;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��������� ������ ������ �� ������ "' || sizeString || '"'
        )
      , true
    );
  end getMemorySize;

  /*
    �������� PID �������� Oracle, ���������������� ��.
  */
  function getServicePid
  return integer
  is
    commandOutput clob;
    -- �������� ��� �������� CSV
    csvIterator tpr_csv_iterator_t;
    -- PID �������� Oracle
    oracleOsPid integer;
  -- getServicePid
  begin
    dbms_lob.createTemporary( commandOutput, true);
    -- ������� PID ������� �����c�
    pkg_File.execCommand(
      command => 'tasklist /FI "imagename eq ' || Oracle_OsProcessName || '" /FO csv /svc'
      , output => commandOutput
    );
    logger.trace( 'commandOutput="' || commandOutput);
    if commandOutput is not null then
      csvIterator := tpr_csv_iterator_t(
        textData => commandOutput
        , headerRecordNumber => 1
        , fieldSeparator => ','
      );
      while csvIterator.next() loop
        if upper( csvIterator.getString(3))
          like '%' || upper( pkg_Common.getInstanceName()) || '%'
        then
          oracleOsPid := csvIterator.getNumber(2);
          exit;
        end if;
      end loop;
      if oracleOsPid is null then
        raise_application_error(
          pkg_Error.IllegalArgument
          , '�� ������� ������ ���������� �� �������'
        );
      end if;
    else
      raise_application_error(
        pkg_Error.IllegalArgument
        , '������� �� ������� ���������'
      );
    end if;
    return
      oracleOsPid;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ '
        )
      , true
    );
  end getServicePid;

  /*
    �������� �������� ������ ������ ��������.
  */
  function getProcessMemory(
    oracleOsPid integer
  )
  return number
  is
    -- ����� ������� ��
    commandOutput clob;
    -- �������� ��� �������� CSV
    csvIterator tpr_csv_iterator_t;
    -- ����� ������ ��������
    processMemory number;

  -- getProcessMemory
  begin
    dbms_lob.createTemporary( commandOutput, true);
    pkg_File.execCommand(
      command => 'tasklist /FI "imagename eq ' || Oracle_OsProcessName || '" /FO csv'
      , output => commandOutput
    );
    logger.trace( 'commandOutput="' || commandOutput);
    -- ������� ����� ������ �� PID
    if commandOutput is not null then
      csvIterator := tpr_csv_iterator_t(
        textData => commandOutput
        , headerRecordNumber => 1
        , fieldSeparator => ','
      );
      while csvIterator.next() loop
        if csvIterator.getNumber(2) = oracleOsPid then
          logger.debug( 'process found: memory');
          processMemory := getMemorySize( csvIterator.getString(5));
          exit;
        end if;
      end loop;
      if processMemory is null then
        raise_application_error(
          pkg_Error.IllegalArgument
          , '�� ������� ������ ���������� �� PID'
        );
      end if;
    else
      raise_application_error(
        pkg_Error.IllegalArgument
        , '������� �� ������� ���������'
      );
    end if;
    return
      processMemory;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ ��������� ������ ������ �� PID �������� �� ('
          || ' oracleOsPid=' || to_char( oracleOsPid)
          || ')'
        )
      , true
    );
  end getProcessMemory;

-- getOracleOsProcessMemory
begin
  oracleOsPid := getServicePid();
  return
    getProcessMemory( oracleOsPid => oracleOsPid)
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��������� ���������� ������ �������� ������������ �������'
      )
    , true
  );
end getOsMemory;

/* proc: checkMemory
  �������� ���������� �������� ������� ���������������� ����������� ������.

  ���������:
  osMemoryThreshold           - ����� ������ �������� ������������ ������� �
                                ������, ��� ������� ������� ��������������
  pgaMemoryThreshold          - ����� ������ PGA ��������� Oracle, ��� �������
                                ������� ��������������
  emailRecipient              - ����������(�) ��������������

  ����������:
  - ������ ���� ����� ���� �� ���� ����� ( osMemoryThreshold ���
    pgaMemoryThreshold);
*/
procedure checkMemory(
  osMemoryThreshold number := null
  , pgaMemoryThreshold number := null
  , emailRecipient varchar2 := null
)
is

  -- ��������� ��� ��������������
  messageText clob := null;

  -- ���������� ��������������
  usedEmailRecipient varchar2(1000) :=
    coalesce( emailRecipient, pkg_Common.getMailAddressDestination);

  /*
    ��������� ����������������� ������ ������� ������ � ������.
  */
  function formatMemorySize(
    memorySize number
  )
  return varchar2
  is
  begin
    return
      to_char(
        memorySize
        , 'FM999G999G999G999G999'
        , 'NLS_NUMERIC_CHARACTERS=''. '''
      );
  end formatMemorySize;

  /*
    �������� ����������.
  */
  procedure checkParameter
  is
  begin
    if osMemoryThreshold is null and pgaMemoryThreshold is null then
      raise_application_error(
        pkg_Error.IllegalArgument
        , '������ ���� ����� ���� �� ���� ��������: osMemoryThreshold ���'
          || ' pgaMemoryThreshold'
      );
    end if;
  end checkParameter;

  /*
    �������� ������, ������������� ������������ ��������.
  */
  procedure checkOsMemory
  is
    -- ������, ������������ ��������� ������������ ������� ( Oracle.exe)
    currentOsMemory number;
  begin
    currentOsMemory := getOsMemory();
    if currentOsMemory > osMemoryThreshold then
      messageText := messageText ||
'���������� ������ ������ �������� ������������ �������.
����� ������ ' || Oracle_OsProcessName || ': ' || formatMemorySize( currentOsMemory) || ' ����
�����: ' || formatMemorySize( osMemoryThreshold) || ' ����'
      ;
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ �������� ������, ������������� ������������ ��������'
        )
      , true
    );
  end checkOsMemory;

  /*
    �������� ������ PGA ��������� Oracle.
  */
  procedure checkPga
  is
    headerFlag boolean := false;
  begin
    logger.debug( 'checkPga');
    for sessionMemory in (
      select
        *
      from
        v_prm_session_memory
      where
        pga_memory > pgaMemoryThreshold
      order by
        pga_memory desc
    )
    loop
      if not headerFlag then
        messageText := messageText || chr(13) || chr(10) || '
���������� ������ ������ ( PGA) ����������� ���������� Oracle: '
|| formatMemorySize( pgaMemoryThreshold) || ' ����'
        ;
        headerFlag := true;
      end if;
      messageText := messageText || chr(13) || chr(10) || '
Sid: ' || to_char( sessionMemory.sid) || '
Serial#: ' || to_char( sessionMemory.serial#) || '
����� PGA: ' || formatMemorySize( sessionMemory.pga_memory) || ' ����'
        ||
        case when
         sessionMemory.batch_short_name is not null then
'
����: "' || sessionMemory.batch_short_name || '"'
        else
'
username: ' || sessionMemory.username || '
osuser: ' || sessionMemory.osuser || '
terminal: ' || sessionMemory.terminal || '
program: ' || sessionMemory.program
        end
        || '
logon_time: ' || to_char( sessionMemory.logon_time, 'dd.mm.yyyy hh24:mi:ss')
      ;
    end loop;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          '������ �������� ������ PGA ��������� Oracle'
        )
      , true
    );
  end checkPga;

-- checkMemory
begin
  checkParameter();
  if osMemoryThreshold is not null then
    checkOsMemory();
  end if;
  if pgaMemoryThreshold is not null then
    checkPga();
  end if;
  if messageText is not null then
    pkg_Common.sendMail(
      mailSender => pkg_Common.getMailAddressSource(
        pkg_ProcessMonitorBase.Module_Name
      )
      , mailRecipient => usedEmailRecipient
      , subject => '���������� ������ ������'
      , message => messageText
    );
    logger.info(
      '���������� �������������� �� ������(��): "' || usedEmailRecipient || '"'
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ �������� ���������� ������������� ���������� ��������� ������'
        || '����������� ������'
      )
    , true
  );
end checkMemory;



/* group: ��������� ����� */

/* proc: setBatchConfig
  ��������� �������� ��� �����

  ���������:
  batchShortName              - �������� ������������ �����
  warningTimePercent          - ����� �������������� � ���������� ����������
                                ( � ���������)
  warningTimeHour             - ����� �������������� � ���������� ����������
                                ( � �����)
  abortTimeHour               - ����� ���������� ( � �����)
  orakillWaitTimeHour         - ����� �������� ��� ���������� oraKill ��� ������
                                � ��������� KILLED
  traceTimeHour               - ����� ��������� � �������� ����� �����������
  isFinalTraceSending         - �������� ������ �� ���� ����������� ��� ����������
                                ��������� �������
  sqlTraceLevel               - ������� �����������
                                (��. �������� ������� ����������� � <sqlTraceOn>)
*/
procedure setBatchConfig(
  batchShortName varchar2
  , warningTimePercent integer
  , warningTimeHour integer
  , abortTimeHour integer
  , orakillWaitTimeHour integer
  , traceTimeHour integer
  , sqlTraceLevel integer
  , isFinalTraceSending integer
)
is
begin
  update
    prm_batch_config
  set
    warning_time_percent = warningTimePercent
    , warning_time_hour = warningTimeHour
    , abort_time_hour = abortTimeHour
    , orakill_wait_hour = orakillWaitTimeHour
    , trace_time_hour = traceTimeHour
    , sql_trace_level = sqlTraceLevel
    , is_final_trace_sending = isFinalTraceSending
  where
    batch_short_name = batchShortName;
  if sql%rowcount = 0 then
    insert into prm_batch_config(
      batch_short_name
      , warning_time_percent
      , warning_time_hour
      , abort_time_hour
      , orakill_wait_hour
      , trace_time_hour
      , sql_trace_level
      , is_final_trace_sending
      , operator_id
    )
    values(
      batchShortName
      , warningTimePercent
      , warningTimeHour
      , abortTimeHour
      , orakillWaitTimeHour
      , traceTimeHour
      , sqlTraceLevel
      , isFinalTraceSending
      , pkg_Operator.getCurrentUserId
    );
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��������� �������� ����� ( '
        || 'batchShortName="' || batchShortName || '"'
        || ')'
      )
    , true
  );
end setBatchConfig;

/* proc: deleteBatchConfig
  �������� �������� ��� �����

  ���������:
  batchShortName              - �������� ������������ �����
*/
procedure deleteBatchConfig(
  batchShortName varchar2
)
is
begin
  delete from
    prm_batch_config
  where
    batch_short_name = batchShortName
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ �������� �������� ����� ( '
        || 'batchShortName="' || batchShortName || '"'
        || ')'
      )
    , true
  );
end deleteBatchConfig;

end pkg_ProcessMonitor;
/
