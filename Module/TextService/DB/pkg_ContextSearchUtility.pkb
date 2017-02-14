create or replace package body pkg_ContextSearchUtility is
/* package body: pkg_ContextSearchUtility::body */



/* group: Переменные */

/* ivar: logger
  Логер пакета.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => 'TextService'
  , objectName  => 'pkg_ContextSearchUtility'
);



/* group: Функции */

/* func: normalizeSearchPhrase
  Нормализация строки контекстного поиска.

  Параметры:
  searchPhrase                - строка контекстного поиска

  Возврат:
  - нормализованная строка;

  Реализация:
  - если строка обрамлена в кавычки ( одинарные или двойные), то
    кавычки в начале и в конце удаляются и возвращается полученная строка
    как есть;
  - иначе все специальные символы ( все символы, кроме пробела, букв и цифр)
    заменяются на пробелы;

  Замечание:
  - автотест к функции реализован в скрипте
    <Test/normalize-search-phrase.sql>;
*/
function normalizeSearchPhrase(
  searchPhrase varchar2
)
return varchar2
is
-- normalizeSearchPhrase
begin
  return null;
end normalizeSearchPhrase;

end pkg_ContextSearchUtility;
/
