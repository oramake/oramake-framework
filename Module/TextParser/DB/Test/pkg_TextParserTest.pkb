create or replace package body pkg_TextParserTest is
/* package body: pkg_TextParserTest::body */



/* group: Переменные */

/* ivar: logger
  Логер пакета.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => pkg_TextParserBase.Module_Name
  , objectName  => 'pkg_TextParserTest'
);



/* group: Функции */

/* proc: testCsvIterator
  Тестирование разбора файла.

  Параметры:

*/
procedure testCsvIterator
is

  csvIterator tpr_csv_iterator_t;
  testOk boolean := true;

  /*
    Тест.
  */
  procedure csvTest(
    fileText clob
    , testName varchar2
    , value12 clob
    , value22 clob
    , noEnclosedCharFlag number := null
    , useGetClob boolean := false
  )
  is
    comparedValue clob;

    /*
      Получение строки.
    */
    function getString
    return varchar2
    is
    begin
      return
        case when
          useGetClob
        then
          substr(csvIterator.getClob(2), 1, 32767)
        else
          csvIterator.getString(2)
        end
      ;
    end getString;

  begin
    pkg_TestUtility.beginTest(testName);
    csvIterator := tpr_csv_iterator_t(
      fileText
      , noEnclosedCharFlag => noEnclosedCharFlag
    );
    logger.trace(
      'csvIterator.getDataLength=' || to_char( csvIterator.getDataLength())
    );
    if not csvIterator.next() then
      pkg_TestUtility.failTest( 'next returned false: 1');
    end if;
    testOk := true;
    begin
      for i in 1..2 loop
        comparedValue :=
          case when
            i = 1
          then
            value12
          else
            value22
          end
        ;
        if i = 1 then
          testOk := testOk
            and
            pkg_TestUtility.compareChar(
              failMessageText => '1'
              , actualString => csvIterator.getString(1)
              , expectedString => '1'
            );
        end if;
        testOk := testOk
          and pkg_TestUtility.compareChar(
            failMessageText => '2'
            , actualString => substr(getString(), 1, 30000)
            , expectedString => substr(comparedValue, 1, 30000)
          );
        testOk := testOk
          and (
            not useGetClob
            or
            pkg_TestUtility.compareChar(
              failMessageText => '2'
              , actualString => substr(csvIterator.getClob(2), 30001, 30000)
              , expectedString => substr(comparedValue, 30001, 30000)
            )
          )
        ;
        if i = 1 then
          if not csvIterator.next() then
            pkg_TestUtility.failTest( 'next returned false: 2');
          end if;
        end if;
      end loop;
    exception when others then
      pkg_TestUtility.failTest(
        'exception: "' || pkg_Logging.getErrorStack() || '"'
       );
    end;
    pkg_TestUtility.endTest();
  end csvTest;

  /*
    Тестирование разбора и количества записей.
  */
  procedure testRecordCount(
    testName varchar2
    , fileText clob
    , fieldSeparator varchar2
    , recordCount integer
  )
  is
  begin
    pkg_TestUtility.beginTest( testName);
    csvIterator := tpr_csv_iterator_t(
      textData => fileText
      , headerRecordNumber => 1
      , fieldSeparator => fieldSeparator
    );
    while ( csvIterator.next()) loop
      logger.trace(
        '#' || csvIterator.getRecordNumber()
        || '|' || csvIterator.getString( 'last_name')
        || '|' || csvIterator.getString( 'first_name')
        || '|' || csvIterator.getString( 'middle_name')
        || '|' || to_char(
            csvIterator.getDate( 'birth_date', 'dd.mm.yyyy')
            , 'dd.mm.yyyy hh24:mi:ss'
          )
        || '|' || csvIterator.getString( 'work_place')
        || '|' || csvIterator.getNumber( 'amount', ',')
      );
    end loop;
    if not pkg_TestUtility.compareChar(
      failMessageText   => 'processed_count'
      , actualString    => to_char( csvIterator.getProcessedCount())
      , expectedString  => recordCount
    )
    then
      return;
      end if;
    pkg_TestUtility.endTest();
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка тестирования разбора количества записей '
        )
      , true
    );
  end testRecordCount;

  /*
    Тест получения значения поля, указанного в виде процентов ( числа с
    добавленым после него символом "%", возможно с дополнительными пробелами).
  */
  procedure getPercentTest(
    fileText clob
    , decimalCharacter varchar2 := null
  )
  is
  begin
    pkg_TestUtility.beginTest( 'get percent');
    csvIterator := tpr_csv_iterator_t(
      textData => fileText
      , headerRecordNumber => 1
    );
    while ( csvIterator.next()) loop
      logger.trace(
        '#' || csvIterator.getRecordNumber()
        || '|' || csvIterator.getString( 'field_name')
        || '|' ||
          csvIterator.getNumber(
            'field_value'
            , decimalCharacter => decimalCharacter
          )
        || '|' ||
          csvIterator.getNumber(
            'percent_value'
            , decimalCharacter => decimalCharacter
            , isTrimPercent    => 1
          )
      );
    end loop;
    pkg_TestUtility.endTest();
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка тестирования получения значения поля, указанного в процентах.'
        )
      , true
    );
  end getPercentTest;

-- testCsvIterator
begin
  csvTest(
'1;2
3;4'
    , 'elementary test'
    , '2'
    , '4'
  );
  csvTest(
'1;
3;4'
    , '";" in the end of a line'
    , ''
    , '4'
  );
  csvTest(
'1;2
3;'
    , '";" in the end of the file'
    , '2'
    , ''
  );
  csvTest(
'1;"2"3
3;'
    , 'no enclosed char'
    , '"2"3'
    , ''
    , noEnclosedCharFlag => 1
  );
  testRecordCount(
    'separator=";"'
, 'last_name;first_name;middle_name;birth_date;amount;work_place
Иванов;Иван;Иванович;01.05.1970;100,35;"ООО ""Проба"""
Петров;Владимир;;30.04.1981;0;"ООО ""Мир,труд;май"""
Сидоров;;;;;
;;;;500;
;;;01.01.1990;;
'
    , ';'
    , 5
  );
  testRecordCount(
    'separator=<Tab>'
    ,
'last_name	first_name	middle_name	birth_date	amount	work_place
Алексеев	Иван	Иванович	01.05.1970	100,35	"ООО ""Проба"""
Петров	Владимир		30.04.1981	0	"ООО ""Мир,труд;май"""
Сидоров					' || '
				500	' || '
			01.01.1990		' || '
'
    , chr(9)
    , 5
  );
  getPercentTest(
'field_name;field_value;percent_value
Доход;1900000.8;15%
Налоги;900000;35.5 %
Прибыль;100 000;5
'
    , decimalCharacter => '.'
  );
  csvTest(
'1;2
3;' || lpad('0', 30000, '0') || lpad('1', 30000, '1')
    , 'long lines'
    , '2'
    , lpad('0', 30000, '0') || lpad('1', 30000, '1')
    , useGetClob => true
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка тестирования разбора файла'
      )
    , true
  );
end testCsvIterator;

end pkg_TextParserTest;
/
