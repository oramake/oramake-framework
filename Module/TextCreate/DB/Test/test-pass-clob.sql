declare


  logger lg_logger_t := lg_logger_t.GetLogger(
    moduleName => 'Test'
    , objectName => 'test-pass-clob'
  );
  
  s clob;
  s2 clob;
  txtObj txc_text_t;
   str varchar2( 32767) :=  '!' || lpad( '!', 1000, '*');  
   strCount integer := 10; -- trunc(1024*1024/32767);

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
begin
     update
       t
     set
       a = empty_clob();
     select
       a
     into
       s
     from
       t;  
     txtObj := txc_text_t( s);
     txtObj.Append( '1222');
/*     for i in 1..strCount loop
       txtObj.Append( str);
     end loop;*/
     s := txtObj.GetClob;
     update
       t
     set
       a = s;
     commit;
     TestSize;
     
end;     


