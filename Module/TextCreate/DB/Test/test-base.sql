-- script: Test/test-base.sql
-- Базовый тест добавления в clob
--
-- Добавляет строки с помощью:
--           - <pkg_TextCreate.newText>
--           - <pkg_TextCreate.append( str )>
--           - <pkg_TextCreate.getClob>
--
-- Замеряет производительность
declare

   str varchar2( 32767) :=  '!' || lpad( '!', 32766, '*');
   strCount integer := 100; -- trunc(1024*1024/32767);

   resSize integer;
   checkSize number := 0;
   startTime number;
   endTime number;
begin
  lg_logger_t.GetRootLogger().SetLevel( pkg_Logging.Trace_LevelCode);
                                       -- Замеряем время
  startTime := dbms_utility.get_time;
                                       -- Инициализируем текст
  pkg_TextCreate.NewText;
                                       -- Добавляем различного вида строки
  for i in 1..strCount loop
     pkg_TextCreate.Append( str);
     checkSize := checkSize + length( str);
  end loop;
  str := '!' || lpad( '!', 1000-1, '*');
  for i in 1..strCount loop
     pkg_TextCreate.Append( str);
     checkSize := checkSize + length( str);
  end loop;
  str := lpad( 'Hello, clob''s world!', 50);
  pkg_TextCreate.Append( str);
  checkSize := checkSize + 50;
                                       -- Обновляем постоянный clob
  update
    t
  set
    a = pkg_TextCreate.GetClob;
  commit;
                                       -- Проверяем результат
  endTime := dbms_utility.get_time;
  select
    dbms_lob.substr( a, 100, dbms_lob.getlength( a) + 1 - 100)
    , dbms_lob.getlength( a)
  into
    str
    , resSize
  from
    t;
  pkg_Common.OutputMessage( 'str=' || str);
  pkg_Common.OutputMessage( 'resSize=' || to_char( resSize));
  pkg_Common.OutputMessage( 'checkSize=' || to_char( checkSize));
  pkg_Common.OutputMessage( 'speed=' || to_char(
    checkSize * 100 / (endTime-startTime)
    , 'FM999G999G999G999G999G999D00'
    , 'NLS_NUMERIC_CHARACTERS=''. ''') || ' b/s'
  );
end;
/

