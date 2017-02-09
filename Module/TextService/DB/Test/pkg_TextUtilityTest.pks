create or replace package pkg_TextUtilityTest is
/* package: pkg_TextUtilityTest
  Пакет автоматизированного тестирования пакета pkg_TextUtility модуля TextService.

  SVN root: Oracle/Module/TextService
*/



/* group: Функции */



/* group: Unit-тесты методов */

/* pproc: testLevenshteinDistance
   Выполняет проверку вычисления Расстояния Редактирования (Дистанции Левенштейна).


  ( <body::testLevenshteinDistance>)
*/
procedure testLevenshteinDistance;

/* pproc: testNormalizeWordList
  Проверка работы функции нормализации списка строк.

  Параметры:
  sourceString                - исходная строка
  expectedString              - ожидаемая строка
  addonDelimiterList         - список разделителей ( по-умолчанию только пробел)

  ( <body::testNormalizeWordList>)
*/
procedure testNormalizeWordList(
  sourceString varchar2
  , expectedString varchar2
  , addonDelimiterList varchar2 := null
);

/* pfunc: normalizeAndLevenstein
  Вычисление функции Левенштейна над нормализованными списками слов.

  Параметры:
  source                      - исходная строка
  target                      - строка, которую необходимо получить

  Замечание:
  - используются дополительные разделители "/-,";

  ( <body::normalizeAndLevenstein>)
*/
function normalizeAndLevenstein(
  source varchar2
  , target varchar2
)
return integer;

/* pfunc: wordListCloseness
  Вычисление близости между наборами слов ( чем больше значение функции,
  тем больше близость - значение от 0 до 1).

  Параметры:
  wordList1                   - набор слов 1
  wordList2                   - набор слов 2
  addonDelimiterList          - список дополнительных разделителей (
                                по-умолчанию только пробел)

  ( <body::wordListCloseness>)
*/
function wordListCloseness(
  wordList1 varchar2
  , wordList2 varchar2
  , addonDelimiterList varchar2 := null
)
return number;

/* pproc: testWordListCloseness
  Тестирование функции близости двух наборов слов.

  Параметры:
  wordList1                   - набор слов 1
  wordList2                   - набор слов 2
  expectedCloseness           - ожидаемое значение близости

  ( <body::testWordListCloseness>)
*/
procedure testWordListCloseness(
  wordList1 varchar2
  , wordList2 varchar2
  , expectedCloseness number
);

end pkg_TextUtilityTest;
/
