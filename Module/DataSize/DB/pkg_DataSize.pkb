create or replace package body pkg_DataSize is
/* package body: pkg_DataSize::body */

/* ivar: logger
  ������������ ������ � ������ Logging
*/
  logger lg_logger_t := lg_logger_t.GetLogger(
    moduleName => Module_Name
    , objectName => 'pkg_DataSize'
  );



/* group: ������� */

/* func: GetNextHeaderId
  ��������� ���������� id ���������
  (<body::GetNextHeaderId>)
*/
function GetNextHeaderId
return integer
is

                                       -- ��������� ����������
  tmpHeaderId integer;
begin
  select
    dsz_header_seq.nextVal
  into
    tmpHeaderId
  from
    dual;
  return tmpHeaderId;
end GetNextHeaderId;

/* func: GetNextSegmentId
  ��������� ���������� id ��� <dsz_segment>
  (<body::GetNextSegmentId>)
*/
function GetNextSegmentId
return integer
is
                                       -- ��������� ����������
  tmpSegmentId integer;
begin
  select
    dsz_segment_seq.nextVal
  into
    tmpSegmentId
  from
    dual;
  return tmpSegmentId;
end GetNextSegmentId;

/* proc: SaveDataSize
  ���������� �������� ��������� dba_segment
  � ������� <dsz_header>, <dsz_segment>.
*/
procedure SaveDataSize
is
                                       -- Id ���������

  headerId integer;

  procedure CreateHeader
  is
  -- �������� ��������
  -- � ������ id � ���������� headerId
  begin
    insert into dsz_header(
      header_id
    )
    values(
      pkg_DataSize.getNextHeaderId()
    )
    returning
      header_id
    into
      headerId;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack( '������ �������� ���������' )
      , true
    );
  end CreateHeader;

  procedure SaveDbaSegments
  is
  -- ������� � dsz_segment
  begin
    insert into dsz_segment(
      header_id
      , owner
      , segment_name
      , partition_name
      , segment_type
      , tablespace_name
      , header_file
      , header_block
      , bytes
      , blocks
      , extents
      , initial_extent
      , next_extent
      , min_extents
      , max_extents
      , pct_increase
      , freelists
      , freelist_groups
      , relative_fno
      , buffer_pool
    )
    select
      headerId as header_id
      , owner as owner
      , segment_name as segment_name
      , partition_name as partition_name
      , segment_type as segment_type
      , tablespace_name as tablespace_name
      , header_file as header_file
      , header_block as header_block
      , bytes as bytes
      , blocks as blocks
      , extents as extents
      , initial_extent as initial_extent
      , next_extent as next_extent
      , min_extents as min_extents
      , max_extents as max_extents
      , pct_increase as pct_increase
      , freelists as freelists
      , freelist_groups as freelist_groups
      , relative_fno as relative_fno
      , buffer_pool as buffer_pool
    from
      dba_segments;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack( '������ ������ dsz_segment' )
      , true
    );
  end SaveDbaSegments;

begin
  pkg_TaskHandler.InitTask(
    moduleName => Module_Name
    , processName => 'SaveDataSize'
  );
  lock table dsz_header in exclusive mode;
  CreateHeader;
  logger.Info('������ ��������� ( header_id='
    || to_char( headerId ) || ')'
  );
  SaveDbaSegments;
  pkg_TaskHandler.CleanTask;
exception when others then
  pkg_TaskHandler.CleanTask;
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( '������ ���������� dba_segments' )
    , true
  );
end SaveDataSize;

/* func: GetMaxHeaderDate
  ���������� ���� ���������� ������������
  ���������

  �������:
    - ���� ���������� ������������
  ���������
*/
function GetMaxHeaderDate
return date
is
  maxDateIns date;
begin
  select
    max( date_ins )
  into
    maxDateIns
  from
    dsz_header;
  return maxDateIns;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( '������ ��������� ������������ ����' )
    , true
  );
end GetMaxHeaderDate;

/* func: GetHeaderDate
  ���������� ���� ���������

  ���������:
    headerId - id ���������

  �������:
    - ���� ���������
*/
function GetHeaderDate( headerId integer )
return date
is
  dateIns date;
begin
  select
    date_ins
  into
    dateIns
  from
    dsz_header
  where
    header_Id = headerId;
  return dateIns;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack( '������ ��������� ���� ���������' )
    , true
  );
end GetHeaderDate;

/* func: CreateReport(header)
  �������� ������ �� ���������
  ��������������� ������������ ��
  dba_segments.

  ���������:
    fromHeaderId - id ���������� ��������� ��� ���������
    toHeaderId - id ��������� ��������� ��� ���������

  �������:
    - ����� ������
*/
function CreateReport(
  fromHeaderId integer
  , toHeaderId integer
)
return clob
is
                                       -- ����� ������
  messageText clob;
                                       -- ������ ��� ��������� ������
  cursor curReport is
select
  t.owner as owner
  , t.segment_name as segment_name
  , t.partition_name as partition_name
  , t.tablespace_name as tablespace_name
  , t.segment_type as segment_type
  , t.delta as delta
  , t.old_bytes as old_bytes
  , t.new_bytes as new_bytes
  , sum( delta ) over() as total_delta
  , sum( old_bytes ) over() as total_old_bytes
  , sum( new_bytes ) over() as total_new_bytes
from
  (
  select
    t.*
  from
    (
    select
      owner
      , case when
          segment_name = '_SYS'
        then
          '<����� "_SYS%">'
        else
          segment_name
        end as segment_name
      , segment_type
      , partition_name
      , tablespace_name
      , sum( delta ) as delta
      , sum( old_bytes ) as old_bytes
      , sum( new_bytes ) as new_bytes
    from
      dsz_segment_group_tmp
    group by
      owner
      , segment_name
      , segment_type
      , partition_name
      , tablespace_name
    ) t
  ) t
order by
  delta desc;
                                       -- ������ ������ ������
  recReport curReport%rowtype;

  procedure FillSegmentGroup
  is
  -- ���������� ��������� ������� �������� ������
  begin
    delete dsz_segment_group_tmp;
    insert into dsz_segment_group_tmp(
      segment_id
      , owner
      , segment_name
      , tablespace_name
      , partition_name
      , segment_type
      , old_bytes
      , new_bytes
      , delta
    )
    select
      coalesce( e2.segment_id, e1.segment_id ) as segment_id
      , coalesce( e2.owner, e1.owner ) as owner
      -- ��� ��������� �������� ������������ � ������
      ,
      case when
        coalesce(e2.segment_name, e1.segment_name) like '_SYS%'
      then
        '_SYS'
      else
        coalesce(e2.segment_name, e1.segment_name)
      end as segment_name
      , coalesce( e2.tablespace_name, e2.tablespace_name ) as tablespace_name
      , coalesce( e2.partition_name, e1.partition_name ) as partition_name
      , coalesce(e2.segment_type, e1.segment_type)
        ||
        case when l.table_name is not null then
          ',' || l.owner || '.' || l.table_name || '.' || l.column_name
        end
        as segment_type
      , e1.bytes as old_bytes
      , e2.bytes as new_bytes
      , coalesce( e2.bytes, 0 )  - coalesce( e1.bytes, 0 ) as delta
    from
      (
      select
        *
      from
        dsz_segment e1
      where
        e1.header_id = fromHeaderId
      )  e1
    full outer join
      (
      select
        *
      from
        dsz_segment e2
      where
        e2.header_id = toHeaderId
      ) e2
    on
      e2.owner = e1.owner
      and e2.segment_name = e1.segment_name
      and e2.segment_type = e1.segment_type
      and e2.tablespace_name = e1.tablespace_name
      and
      ( e2.partition_name = e1.partition_name
        or coalesce(  e2.partition_name, e1.partition_name ) is null
      )
    left join
      dba_lobs l
    on
      l.segment_name = coalesce(e2.segment_name, e1.segment_name)
    ;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack( '������ ��������� ������������� ������' )
      , true
    );
  end FillSegmentGroup;

  procedure FillMessageText
  is
  -- ��������� ����� ��������� ��� ������
                                       -- �������� �� ���������
                                       -- ������
    reportHeaderAdded boolean := false;

    procedure AddLine(
      lineText varchar2
    )
    is
    -- ��������� ������ � ���������
    begin
      messageText := messageText || lineText
        || chr(10 );
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.ErrorStack( '������ ���������� ������ ( lineText = "'
            || lineText || '")'
         )
        , true
      );
    end AddLine;

    function FormatField(
      fieldValue varchar2
      , symbolCount integer
    )
    return varchar2
    -- ����������� ����� �������� ����
    is
    begin
      return
        replace(
          rpad(
            substr( coalesce( fieldValue, ' ' )
                    , 1
                    , symbolCount
            )
            , symbolCount
          )
          , ' '
          , ' '
        );
    end FormatField;

    procedure AddReportHeader
    is
    -- ��������� ��������� ������
    begin
      AddLine( rpad( '��������� �����: ', 50 )
        || '{' || to_char( GetHeaderDate( fromHeaderId )
                           , 'dd.mm.yyyy hh24:mi:ss' ) || '}'
      );
      AddLine( rpad( '�������� �����: ', 50 )
        || '{' || to_char( GetHeaderDate( toHeaderId )
                           , 'dd.mm.yyyy hh24:mi:ss' ) || '}'
      );
      AddLine( FormatField( '��������� ��������� �������� bytes: ', 50 )
        || to_char(
             recReport.total_old_bytes
             , 'FM999G999G999G999G999'
             , 'NLS_NUMERIC_CHARACTERS=''. '''
           )
      );
      AddLine( FormatField( '�������� ��������� �������� bytes: ', 50 )
        || to_char(
             recReport.total_new_bytes
             , 'FM999G999G999G999G999'
             , 'NLS_NUMERIC_CHARACTERS=''. '''
           )
      );
      AddLine( FormatField( '���������: ', 50 )
        || to_char(
             recReport.total_delta
             , 'FM999G999G999G999'
             , 'NLS_NUMERIC_CHARACTERS=''. '''
           )
      );
      AddLine( '' );
      AddLine(
        FormatField( 'N', 4 )
        || FormatField( 'OWNER', 20 )
        || FormatField( 'SEGMENT_NAME', 30 )
        || FormatField( 'DELTA ( NEW_VALUE )', 30 )
      );
      AddLine(
        FormatField( '', 4 )
        || FormatField( '', 20 )
        || FormatField( '(TYPE,PARTITION)', 30 )
      );
      AddLine( rpad( '-', 4 + 20 + 30 + 30, '-' ) );
      reportHeaderAdded := true;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.ErrorStack( '������ ���������� ������' )
        , true
      );
    end AddReportHeader;

    procedure AddReportRecord
    is
    -- ��������� ������ � �����
    begin
      AddLine(
        FormatField( to_char( curReport%rowcount ), 4 )
        || FormatField( recReport.owner, 20 )
        || FormatField( recReport.segment_name,  30 )
        || FormatField(
             to_char(
               recReport.delta
               , 'FM999G999G999G999'
               , 'NLS_NUMERIC_CHARACTERS=''. '''
             )
             || ' ( '
             ||
             to_char(
               recReport.new_bytes
               , 'FM999999999999'
               , 'NLS_NUMERIC_CHARACTERS=''. '''
             )
             || ' )'
             , 30
           )
      );
      AddLine(
        FormatField( '', 4 )
        || FormatField( '', 20 )
        || FormatField( '(' || recReport.segment_type
             ||
             case when
               recReport.partition_name is not null
             then
               ',' || recReport.partition_name
             end
             || ')'
             ,  50

           )
      );
      AddLine( '' );
      reportHeaderAdded := true;
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.ErrorStack( '������ ���������� ������' )
        , true
      );
    end AddReportRecord;

  begin
    open curReport;
    fetch curReport into recReport;
    while curReport%found loop
      if not reportHeaderAdded then
        AddReportHeader;
      end if;
      if recReport.delta <> 0 then
        AddReportRecord;
      end if;
      fetch curReport into recReport;
    end loop;
    close curReport;
  exception when others then
    if curReport%ISOPEN then
      close curReport;
    end if;
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack( '������ ����������� ������ ���������' )
      , true
    );
  end FillMessageText;

begin
  pkg_TaskHandler.SetAction( 'CreateReport' );
  if fromHeaderId = toHeaderId then
    raise_application_error(
      pkg_error.ProcessError
      , '��������� ��� ��������� ���������: ( fromHeaderId ='
          || to_char( fromHeaderId ) || ')'
    );
  end if;
  FillSegmentGroup;
  FillMessageText;
  pkg_TaskHandler.SetAction( '' );
  return messageText;
exception when others then
  pkg_TaskHandler.SetAction( '' );
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack(
        '������ �������� ������ ��������� dba_segments'
     )
    , true
  );
end CreateReport;

/* func: getReport
  �������� ������ �� ��������� ��������������� ������������ �� dba_segments.

  ���������:
    dateFrom                   - ���� ������ ��� ������. ���� �� ������,
  ������������ ��������� ��������� ���������.
    recipient                  - ���������� ( ������ ) ������ � �������
  ��-��������� ������������ pkg_Common.GetMailAddressDestination
    dataTo                     - ���� ��������� ��� ������. ��-���������
  ������ ������� ����.
    saveDataSize               - ��������� �� ������� ��������. ��-���������
  ���������

  ����������:
    - � �������� ���������� ��� ��������� ������� ���������
  � ������������ ����� �� ��������. ��������, � �������� �������
  ��������� ������ ��������� � ������������ ����� �� dateFrom.

  �������:
  - ����� � ���� clob;
*/
function getReport(
  dateFrom date := null
  , recipient varchar2 := null
  , dateTo date := null
  , toSaveDataSize boolean := null
)
return clob
is
                                       -- ������������ ���� ��� ������
  usedDateTo date;
  usedDateFrom date;
                                       -- ��������� ��� ���������
  fromHeaderId integer;
  toHeaderId integer;

  function GetHeaderId( forDate date )
  return integer
  -- ��������� ��������� �� ����
  is
                                       -- ��������� ������
    headerId integer;
  begin
    select
      header_id
    into
      headerId
    from
      dsz_header
    where
      date_ins =
      (
      select
        max( date_ins )
      from
        dsz_header
      where
        date_ins <= forDate
      );
    return headerId;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack( '������ ��������� ��������� �� ����: '
          || '{' || to_char( forDate, 'dd.mm.yyyy hh24:mi:ss' ) || '}' )
      , true
    );
  end GetHeaderId;

begin
                                       -- ��������� ���������
  usedDateFrom := coalesce(dateFrom, GetMaxHeaderDate );
  if coalesce(getReport.toSaveDataSize, true ) then
    SaveDataSize;
  end if;
                                       -- ������������� ����
                                       -- ����� ������
  usedDateTo := coalesce( dateTo, sysdate );
                                       -- ��������� ����
  if coalesce( usedDateFrom, usedDateTo )
     >= coalesce( usedDateTo, usedDateFrom )
  then
    raise_application_error(
      pkg_error.IllegalArgument
      , '������������ �������� ��� ��� ������'
    );
  end if;
  logger.Debug( 'usedDateFrom = {'
    || to_char( usedDateFrom, 'dd.mm.yyyy hh24:mi:ss' ) || '}'
  );
  logger.Debug( 'usedDateTo = {'
    || to_char( usedDateTo, 'dd.mm.yyyy hh24:mi:ss' ) || '}'
  );
  fromHeaderId := GetHeaderId ( forDate => usedDateFrom );
  toHeaderId := GetHeaderId ( forDate => usedDateTo );
  return
    createReport(
      fromHeaderId => fromHeaderId
      , toheaderId => toHeaderId
    );
  pkg_TaskHandler.SetAction( '' );
exception when others then
  pkg_TaskHandler.SetAction( '' );
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack(
        '������ �������� ������ ��������� dba_segments'
     )
    , true
  );
end getReport;

/* proc: CreateReport
  �������� ������ �� ��������� ��������������� ������������ �� dba_segments.

  ���������:
    dateFrom                   - ���� ������ ��� ������. ���� �� ������,
  ������������ ��������� ��������� ���������.
    recipient                  - ���������� ( ������ ) ������ � �������
  ��-��������� ������������ pkg_Common.GetMailAddressDestination
    dataTo                     - ���� ��������� ��� ������. ��-���������
  ������ ������� ����.
    saveDataSize               - ��������� �� ������� ��������. ��-���������
  ���������

  ����������:
    - � �������� ���������� ��� ��������� ������� ���������
  � ������������ ����� �� ��������. ��������, � �������� �������
  ��������� ������ ��������� � ������������ ����� �� dateFrom.
*/
procedure CreateReport(
  dateFrom date := null
  , recipient varchar2 := null
  , dateTo date := null
  , toSaveDataSize boolean := null
)
is
  -- ���������� ������
  usedRecipient varchar2( 100 ) :=
    coalesce(
      recipient
      , pkg_Common.GetMailAddressDestination
    );

  -- ����� ������
  reportText clob;

begin
  reportText := getReport(
    dateFrom => dateFrom
  , dateTo => dateTo
  , toSaveDataSize => toSaveDataSize
  );
  -- ���������� ������
  logger.Debug(
    'message_id = '
    || to_char(
  pkg_Mail.SendMessage(
    sender => pkg_Common.GetMailAddressSource
    , recipient => usedRecipient
    , subject => '����� �� ��������������� ������������ �� �����'
    , messageText => reportText
  )
       )
  );
  pkg_TaskHandler.SetAction( '' );
exception when others then
  pkg_TaskHandler.SetAction( '' );
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack(
        '������ �������� ������ ��������� dba_segments'
     )
    , true
  );
end CreateReport;

end pkg_DataSize;
/
