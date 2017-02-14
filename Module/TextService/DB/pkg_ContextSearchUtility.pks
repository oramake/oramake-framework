create or replace package pkg_ContextSearchUtility is
/* package: pkg_ContextSearchUtility
  Пакет, содержащий утилиты по работе с контекстным поиском.

  SVN root: Oracle/Module/TextService
*/



/* group: Функции */

/* pfunc: normalizeSearchPhrase
  Нормализация строки контекстного поиска.

  Параметры:
  searchPhrase                - строка контекстного поиска

  Возврат:
  - нормализованная строка;

  Реализация:
  - если строка обрамлена в кавычки ( одинарные или двойные), то
    кавычки в начале и в конце удаляются и возвращается полученная строка
    как есть;
  - иначе все специальные символы ( все символы, кроме пробела, запятых, букв
    и цифр) заменяются на пробелы; несколько запятых подряд или несколько
    пробелов подряд заменяются на соответствующий один символ;

  Замечание:
  - автотест к функции реализован в скрипте
    <Test/normalize-search-phrase.sql>;

  ( <body::normalizeSearchPhrase>)
*/
function normalizeSearchPhrase(
  searchPhrase varchar2
)
return varchar2;

end pkg_ContextSearchUtility;
/
