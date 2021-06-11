declare


  logger lg_logger_t := lg_logger_t.GetLogger(
    moduleName => 'Test'
    , objectName => 'compare-forming-clob-performance'
  );
  docId integer;
  unloadDataLob clob;
  
  String_Size constant integer := 32700;
  String_Count constant integer := 100;
  levelCode constant varchar2( 100 ) := pkg_Logging.Debug_LevelCode;
  testCounter integer := 2;


  procedure ShowMemoryUsage
  is
    cursor curMemory is 
select
  sst.pga_memory
  , sst.pga_memory_max
  , sst.uga_memory
  , sst.uga_memory_max
from
  (
  select
    sst.sid as sst_sid
    , max( case when sn.name = 'session pga memory' then sst.value end)
      as pga_memory
    , max( case when sn.name = 'session pga memory max' then sst.value end)
      as pga_memory_max
    , max( case when sn.name = 'session uga memory' then sst.value end)
      as uga_memory
    , max( case when sn.name = 'session uga memory max' then sst.value end)
      as uga_memory_max
  from
    v$sesstat sst
    inner join v$statname sn
      on sn.statistic# = sst.statistic#
  where
    sn.name like  '%ga %'
  group by
    sst.sid
  ) sst
  inner join v$session ss
    on ss.sid = sst.sst_sid
where
   sst_sid = pkg_Common.GetSessionSid;
   recMemory curMemory%rowtype;
  begin
    open curMemory;
    fetch curMemory into recMemory;
    logger.Debug(
      'Memory usage: pga_memory=' || to_char( recMemory.pga_memory)
      || ', pga_memory_max=' || to_char( recMemory.pga_memory_max)
      || ', uga_memory=' || to_char( recMemory.uga_memory)
      || ', uga_memory_max=' || to_char( recMemory.uga_memory_max)
    );   
    close curMemory;
  exception when others then
    if curMemory%isopen then
      close curMemory;
    end if;
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.ErrorStack(
          'Ошибка ShowUserMemory'
        )
      , true
    );     
  end ShowMemoryUsage;
 
  procedure TestAppend
  is
  begin
    logger.Info( 'Start append');
    dbms_lob.open( unloadDataLob, dbms_lob.lob_readwrite);
    for i in 1..String_Count loop
      dbms_lob.writeappend( 
        unloadDataLob
        , String_Size
        , rpad( '!', String_Size-1, '*') || '!'
      );  
    end loop;
    dbms_lob.close( unloadDataLob);
    logger.Debug( 'End append: size=' || dbms_lob.getlength( unloadDataLob));
  end TestAppend;
  
  procedure UpdateTable
  is
  begin
    logger.Debug( 'start update t');
    update
      t 
    set 
      a = unloadDataLob;    
    logger.Debug( 'end update t');
  end UpdateTable;  
  
begin
  logger.SetLevel( levelCode );
  loop
    ShowMemoryUsage;
    logger.Info( 'insert into doc_output_document');
    commit;
    insert into doc_output_document      --Создаем новый документ
    (
      output_document
    )
    values
    (
      empty_clob()
    )
    returning 
      output_document_id 
      , output_document
    into 
      docId
      , unloadDataLob;
    logger.Info( 'insert into doc_output_document: end');
    TestAppend;  
    UpdateTable;
    ShowMemoryUsage;
    logger.Info( 'create temporary');
    commit;
    dbms_lob.createtemporary( unloadDataLob, true);
    TestAppend;
    UpdateTable;
    ShowMemoryUsage;
    logger.Info( 'set a = empty_clob()');
    commit;
    update
      t
    set 
      a = empty_clob();
    select
      a
    into
      unloadDataLob  
    from
      t;  
    TestAppend;
    ShowMemoryUsage;
    logger.Info( 'end test');
    testCounter := testCounter - 1;
    exit when testCounter <= 0;
  end loop;  
end;
/  
