create or replace package pkg_TextUtility is
/* package: pkg_TextUtility
  Интерфейсный пакет функционала TextUtility.

  SVN root: Oracle/Module/TextService
*/



/* group: Константы */

/* const: Module_Name
  Название модуля, к которому относится пакет.
*/
Module_Name constant varchar2(30) := 'TextService';



/* group: Функции */



/* group: Сравнение строк */

/* pfunc: levenshteinDistance
  Вычисление Расстояния Редактирования (Дистанции Левенштейна).

  Параметры:
    source                            - Исходная строка
    target                            - Строка, которую необходимо получить

  Возвращаемое функцией значение:
    - Расстояние Редактирования (Дистанция Левенштейна)


  ( <body::levenshteinDistance>)
*/
function levenshteinDistance(
  source varchar2
  , target varchar2
)
return integer;

/* pproc: normalizeWordList
  Нормализация текста как списка слов.

  Параметры:
  sourceString                - исходная строка
  addonDelimiterList          - список дополнительных разделителей (
                                по-умолчанию только пробел)

  Операции над исходной строкой:
  - замена указанных символов разделителей на пробелы;
  - приведение к нижнему регистру;
  - замена повторяющихся пробелов на один пробел;
  - лексикографиеская сортировка слов;
  - удаление дублирующихся слов;

  ( <body::normalizeWordList>)
*/
function normalizeWordList(
  sourceString varchar2
  , addonDelimiterList varchar2 := null
)
return varchar2;

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

end pkg_TextUtility;
/
