/* script: Test/compare-method-performance.sql
  —равнение производительности методов 
  формировани€ clob в посто€нной таблице
  
  —равниваютс€ методы:
    - добавление через pkg_File, update по doc_output_document ( avgOld)
    - добавление с использованием объектного типа <txc_text_t> ( avgObject)
    - формирование с использованием пакета <pkg_TextCreate> ( avgPackage)
    - формирование clob сразу в посто€нной таблице с использованием 
      объектного типа <txc_text_t> ( avgInto) 
      
  ѕеременные дл€ редактировани€ в скрипте:
    testCount                - количество повторений тестов     
    pauseBetweenTest         - пауза между повторени€ми
    strLength                - длина добавл€емой строки
    strCount                 - количество добавлений
    
  «амечание:
    - дл€ выполнени€ скрипта нужно выполнить установку тестовых объектов
      ( test-table.sql, Test-Object-Type/txc_text_t.*)   
*/
declare
   testCount integer := 10;
   pauseBetweenTest integer := 1;
   strLength integer := 1000;
   strCount integer := 100; -- trunc(1024*1024/32767);


   str varchar2( 32767) :=  '!' || lpad( '!', strLength-1, '*');  
   testCounter integer := testCount;
  logger lg_logger_t := lg_logger_t.GetLogger(
    moduleName => 'Test'
    , objectName => 'compare-method-performance'
  );
  
  avgOld number := 0;
  avgObject number := 0;
  avgPackage number := 0;
  avgInto number := 0;
  
  startTime integer;
  
   procedure TestOld 
   is
   begin
     logger.Info( 'TestOld: end');
     startTime := dbms_utility.get_time;    
     pkg_File.DeleteUnloadData;
     for i in 1..strCount loop
       pkg_File.AppendUnloadData( str);
     end loop;
     pkg_File.AppendUnloadData( '');
     logger.Info( 'update t');
     update
       t
     set
       a = 
       (
       select
         output_document
       from
         doc_output_document
       );    
     commit;
     avgOld:= avgOld + ( dbms_utility.get_time - startTime);
     logger.Info( 'TestOld: end');
   end TestOld;

  procedure TestPackage 
   is
     s clob;
   begin
     logger.Info( 'TextPackage: start');
     startTime := dbms_utility.get_time;    
     pkg_TextCreate.NewText;
     for i in 1..strCount loop
       pkg_TextCreate.Append( str);
     end loop;
     logger.Info( 'TextPackage: getClob: is_open');
     update
       t
     set
       a = pkg_TextCreate.GetClob;
     commit;
     avgPackage:= avgPackage + ( dbms_utility.get_time - startTime);
     logger.Info( 'TextPackage: end');
   end TestPackage;
   
   procedure TestObject
   is
     txtObj txc_text_t; 
     s clob;
   begin
     logger.Info( 'TextObject: start');
     startTime := dbms_utility.get_time;    
     txtObj := txc_text_t();
     txtObj.clear;
     for i in 1..strCount loop
       txtObj.Append( str);
     end loop;
     s := txtObj.GetClob;
     logger.Info( 'update t');
     update
       t
     set
       a = s;
     avgObject:= avgObject + ( dbms_utility.get_time - startTime);
     logger.Info( 'TextObject: end');
     commit;
   end TestObject;   
   
   procedure TestSize 
   is
     tsize integer;
   begin
     select
       dbms_lob.getlength( a)
     into  
       tsize  
     from
       t;
     logger.Info( 'size=' || to_char( tsize));  
   end TestSize; 
   
   procedure TestInto
   is
     txtObj txc_text_t; 
     s clob;
   begin
     logger.Info( 'TestInto: start');
     delete from t;
     commit;  
     startTime := dbms_utility.get_time;    
     insert into t( a)
     values( empty_clob())
     returning a into s;
     dbms_lob.open( s, dbms_lob.lob_readwrite);  
     txtObj := txc_text_t( s);
     for i in 1..strCount loop
       txtObj.Append( str, s);
     end loop;
     txtObj.Finalize( s);
     commit;
     logger.Info( 'TestInto: end');
     avgInto:= avgInto + ( dbms_utility.get_time - startTime);
   end TestInto;  
      
begin
  delete from t;
  insert into t( a) values (null);
  commit;
  lg_logger_t.GetRootLogger().SetLevel( pkg_Logging.Info_LevelCode);
  loop
    update t set a = null;
    commit;
    TestPackage;
    TestSize;
    update t set a = null;
    commit;
    TestOld;
    TestSize;
    update t set a = null;
    commit;
    TestObject;
    TestSize;
    update t set a = null;
    commit;
    TestInto;
    TestSize;
    testCounter := testCounter -1;
    exit when testCounter <= 0;
    dbms_lock.sleep(pauseBetweenTest);
  end loop;  
  avgObject := avgObject / testCount;
  avgOld := avgOld / testCount;
  avgPackage := avgPackage / testCount;
  avgInto := avgInto / testCount;
  logger.Info( 'avgObject=' || to_char( avgObject));
  logger.Info( 'avgOld=' || to_char( avgOld));
  logger.Info( 'avgPackage=' || to_char( avgPackage));
  logger.Info( 'avgInto=' || to_char( avgInto));
end;
/
