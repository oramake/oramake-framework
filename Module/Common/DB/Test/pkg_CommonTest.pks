create or replace package pkg_CommonTest is
/* package: pkg_CommonTest
  Добавлен пакет для тестирования модуля.

  SVN root: Oracle/Module/Common
*/



/* group: Функции */

/* pproc: testNumberToWord
  Тестирование функции <pkg_Common::numberToWord>;

  Параметры:
  sourceNumber                - исходное число
  expectedString              - ожидаемая строка

  ( <body::testNumberToWord>)
*/
procedure testNumberToWord(
  sourceNumber number
  , expectedString varchar2
);

end pkg_CommonTest;
/
