create or replace package body pkg_CommonTest is
/* package body: pkg_CommonTest::body */



/* group: Переменные */

/* ivar: logger
  Логер пакета.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => pkg_Common.Module_Name
  , objectName  => 'pkg_CommonTest'
);



/* group: Функции */

/* proc: testNumberToWord
  Тестирование функции <pkg_Common::numberToWord>;

  Параметры:
  sourceNumber                - исходное число
  expectedString              - ожидаемая строка
*/
procedure testNumberToWord(
  sourceNumber number
  , expectedString varchar2
)
is
-- testNumberToWord
begin
  pkg_TestUtility.beginTest( 'testNumberToWord');
  pkg_TestUtility.compareChar(
    actualString => pkg_Common.numberToWord( sourceNumber)
    , expectedString => expectedString
    , failMessageText => 'testNumberToWord'
  );
  pkg_TestUtility.endTest();
end testNumberToWord;

end pkg_CommonTest;
/
