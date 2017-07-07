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
  - иначе все специальные символы ( все символы, кроме пробела, запятых, букв
    и цифр) заменяются на пробелы; несколько запятых подряд или несколько
    пробелов подряд заменяются на соответствующий один символ; после удаляются
    пробелы и запятые в конце и в начале строки;

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
  if searchPhrase like '"%"' or searchPhrase like '''%''' then
    return substr( searchPhrase, 2, length( searchPhrase) - 2);
  else
    return
      rtrim(
      ltrim(
        regexp_replace(
        regexp_replace(
          -- Все символы кроме букв, цифр, запятых заменяем на пробелы
          regexp_replace( searchPhrase, '[^[:alnum:]^,^ ]', ' ')
          -- Из комбинации запятых и пробелов, содержащих хотя бы одну запятую
          -- оставляем только одну запятую
          , '([, ])+,([, ])*', ','
        )
          -- Повторяющиеся пробелы преобразуем в один
          , '([ ])+', ' '
        )
        , ', '
      )
        , ', '
      )
    ;
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка во время нормализации строки ('
      || ' searchPhrase="' || searchPhrase || '"'
      || ')'
      )
    , true
  );
end normalizeSearchPhrase;

end pkg_ContextSearchUtility;
/
