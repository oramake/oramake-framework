create or replace package body pkg_TextUtilityTest is
/* package body: pkg_TextUtilityTest::body */

/* group: Переменные */

/* ivar: logger
   Объект для логгирования.
*/
logger lg_logger_t := lg_logger_t.getLogger(
    moduleName  => pkg_TextUtility.Module_Name
  , packageName => 'pkg_TextUtilityTest'
  );



/* group: Функции */



/* group: Unit-тесты методов */

/* proc: testLevenshteinDistance
   Выполняет проверку вычисления Расстояния Редактирования (Дистанции Левенштейна).

*/
procedure testLevenshteinDistance
is

  /*
    Тестирование расстояния.
  */
  procedure checkDistance(
    target varchar2
    , expectedDistance integer
  )
  is
  begin
    pkg_TestUtility.compareChar(
      actualString =>
         pkg_TextUtility.levenshteinDistance(
           source => 'Бухгалтерия, аудит, финансы / Бухгалтерский учет'
           , target => target
         )
      , expectedString => to_char( expectedDistance)
      , failMessageText => 'неверное расстояние'
    );
  end checkDistance;

begin
  pkg_TestUtility.beginTest( 'Проверка вычисления Расстояния Редактирования' );
  checkDistance( 'Бухгалтерия / Банки / Финансы / Инвестиции / Аудит / Бухгалтерия / Финансы', 40);
  checkDistance( 'Бухгалтерия / Банки / Финансы / Инвестиции / Банк / Финансовая компания/ Фондовый рынок', 57);
  checkDistance( 'Бухгалтер', 39);
  checkDistance( 'Бухгалтер 1С', 38);
  checkDistance( 'Бухгалтер на участок', 31);
  checkDistance( 'другие специальности', 39);
  pkg_TestUtility.endTest();
end testLevenshteinDistance;

/* proc: testNormalizeWordList
  Проверка работы функции нормализации списка строк.

  Параметры:
  sourceString                - исходная строка
  expectedString              - ожидаемая строка
  addonDelimiterList         - список разделителей ( по-умолчанию только пробел)
*/
procedure testNormalizeWordList(
  sourceString varchar2
  , expectedString varchar2
  , addonDelimiterList varchar2 := null
)
is
-- testNormalizeWordList
begin
  pkg_TestUtility.beginTest(
    'testNormalizeWordList ( "' || substr( sourceString, 1, 10) || '...")'
  );
  pkg_TestUtility.compareChar(
    expectedString => expectedString
    , actualString => pkg_TextUtility.normalizeWordList(
        sourceString => sourceString
        , addonDelimiterList => addonDelimiterList
      )
    , failMessageText => 'strings do not match'
  );
  pkg_TestUtility.endTest();
end testNormalizeWordList;

/* func: normalizeAndLevenstein
  Вычисление функции Левенштейна над нормализованными списками слов.

  Параметры:
  source                      - исходная строка
  target                      - строка, которую необходимо получить

  Замечание:
  - используются дополительные разделители "/-,";
*/
function normalizeAndLevenstein(
  source varchar2
  , target varchar2
)
return integer
is
  addonDelimiterList varchar2(10) := '/-,';
-- normalizeAndLevenstein
begin
  return
    pkg_TextUtility.levenshteinDistance(
      source =>
        pkg_TextUtility.normalizeWordList(
          sourceString => source
          , addonDelimiterList => addonDelimiterList
        )
      , target =>
        pkg_TextUtility.normalizeWordList(
          sourceString => target
          , addonDelimiterList => addonDelimiterList
        )
    );
end normalizeAndLevenstein;

/* func: wordListCloseness
  Вычисление близости между наборами слов ( чем больше значение функции,
  тем больше близость - значение от 0 до 1).

  Параметры:
  wordList1                   - набор слов 1
  wordList2                   - набор слов 2
  addonDelimiterList          - список дополнительных разделителей (
                                по-умолчанию только пробел)

  Реализация:
  - функция нормализует исходные строки и разбирает их на слова, после этого
    сравнивает каждую пару слов функцией Левенштейна с учётом количества букв
    в словах и с учётом нахождения слова в строке ( более близкие к концу
    слова имеют больший вес);
*/
function wordListCloseness(
  wordList1 varchar2
  , wordList2 varchar2
  , addonDelimiterList varchar2 := null
)
return number
is

  -- Строковый тип максимальной длины
  subtype MaxVarchar2 is varchar2(32767);

  -- Двумерный массив слов
  type WordColT is table of MaxVarchar2;
  wordCol1 WordColT := WordColT();
  wordCol2 WordColT := WordColT();

  -- Расстояние между словами
  wordDistance number;
  -- Близость между наборами
  closeness number := 0;

  -- Параметры последовательностей весов
  sequenceSum1 number;
  sequenceSum2 number;
  sequenceStep1 number;
  sequenceStep2 number;

  /*
    Разбор исходной строки на слова.
  */
  procedure splitWordList(
    wordCol in out nocopy WordColT
    , sourceString varchar2
  )
  is
    normalizedString MaxVarchar2;
    -- Позиция следующего разделителя
    nextDelimiterPos integer;
    -- Позиция предыдущего разделителя
    lastDelimiterPos integer := 0;

    /*
      Добавление слова.
    */
    procedure addWord
    is
      newWord MaxVarchar2 :=
        substr( normalizedString, lastDelimiterPos + 1, nextDelimiterPos - lastDelimiterPos - 1)
      ;
    begin
      wordCol.extend( 1);
      wordCol( wordCol.count) := newWord;
      logger.trace( 'addWord: "' || newWord || '"');
    exception when others then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , logger.errorStack(
            'Ошибка добавления слова в коллекцию'
          )
        , true
      );
    end addWord;

  begin
    -- Заменяем все разделители на пробелы
    normalizedString := translate(
      sourceString
      , ' ' || addonDelimiterList
      , ' ' || lpad( ' ', length( addonDelimiterList))
    );
    -- Удаляем повторяющиеся пробелы
    normalizedString := trim( lower(
        regexp_replace( normalizedString, ' +', ' ')
      ));
    logger.trace( 'normalizedString: "'  || normalizedString || '"');
    if normalizedString is not null then
      for safeCycle in 1 .. length( normalizedString) loop
        nextDelimiterPos := instr( normalizedString, ' ', lastDelimiterPos + 1);
        if nextDelimiterPos = 0 then
          nextDelimiterPos := length( normalizedString) + 1;
          addWord();
          exit;
        else
          addWord();
          lastDelimiterPos := nextDelimiterPos;
        end if;
      end loop;
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка разбора исходной строки ('
          || ' sourceString="' || sourceString || '"'
          || ').'
        )
      , true
    );
  end splitWordList;

-- wordListDistance
begin
  splitWordList( wordCol1, wordList1);
  splitWordList( wordCol2, wordList2);

  if ( wordCol1.count > 0 and wordCol2.count > 0) then
    sequenceSum1 := wordCol1.count * ( wordCol1.count + 1) / 2;
    sequenceSum2 := wordCol2.count * ( wordCol2.count + 1) / 2;
    for i in wordCol1.first .. wordCol1.last loop
      for j in wordCol2.first .. wordCol2.last loop
        wordDistance := pkg_TextUtility.levenshteinDistance(
          wordCol1( i)
          , wordCol2( j)
        ) / ( length( wordCol1(i)) + length( wordCol2(j)));
        logger.trace(
          'Distance between "' || wordCol1( i) || '" and "' || wordCol2( j) || '" = ' || to_char( wordDistance)
        );
        if wordDistance <= 0.1 then
          closeness :=
            -- Чем дальше от конца, тем больше вес
            closeness
            +
            (
              i / sequenceSum1
              + j / sequenceSum2
            ) / 2
          ;
          logger.trace( 'closeness=' || to_char( closeness, 'FM999999.0000'));
        end if;
      end loop;
    end loop;
    return
      closeness
    ;
  else
    return null;
  end if;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка вычисления расстояния между наборами слов ('
        || ' wordList1="' || wordList1 || '"'
        || ', wordList2="' || wordList2 || '"'
        || ', addonDelimiterList="' || addonDelimiterList || '"'
        || ').'
      )
    , true
  );
end wordListCloseness;

/* proc: testWordListCloseness
  Тестирование функции близости двух наборов слов.

  Параметры:
  wordList1                   - набор слов 1
  wordList2                   - набор слов 2
  expectedCloseness           - ожидаемое значение близости
*/
procedure testWordListCloseness(
  wordList1 varchar2
  , wordList2 varchar2
  , expectedCloseness number
)
is
-- testWordListCloseness
begin
  pkg_TestUtility.beginTest( 'testWordListCloseness ( '
    || substr( wordList1, 1, 3) || '... - ' || substr( wordList2, 1, 3) || '...)'
  );
  pkg_TestUtility.compareChar(
    actualString => to_char(
      wordListCloseness(
        wordList1 => wordList1
        , wordList2 => wordList2
        , addonDelimiterList => '_-,.:;/\'
      )
    )
    , expectedString => to_char( expectedCloseness)
    , failMessageText => 'closeness'
  );
  pkg_TestUtility.endTest();
end testWordListCloseness;



/* group: Утилиты для работы с конектсным поиском */

/* proc: testNormalizeSearchPhrase
  Тестирование нормализации функции контекстного поиска.

  Параметры:
  searchPhrase                - исходная строка
  expectedPhrase              - ожидаемая строка
*/
procedure testNormalizeSearchPhrase(
  searchPhrase varchar2
, expectedPhrase varchar2
)
is
-- testNormalizeSearchPhrase
begin
  pkg_TestUtility.beginTest( 'normalizeSearchPhrase ("' || searchPhrase || '")');
  pkg_TestUtility.compareChar(
    actualString     => pkg_ContextSearchUtility.normalizeSearchPhrase( searchPhrase)
  , expectedString   => expectedPhrase
  , failMessageText  => 'function result'
  );
  pkg_TestUtility.endTest();
end testNormalizeSearchPhrase;

end pkg_TextUtilityTest;
/
