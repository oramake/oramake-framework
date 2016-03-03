create or replace package body pkg_TextUtility is
/* package body: pkg_TextUtility::body */

/* ivar: lg_logger_t
  Интерфейсный объект для модуля Logging
*/
  logger lg_logger_t := lg_logger_t.getLogger(
    moduleName => pkg_TextUtility.Module_Name
    , objectName => 'pkg_TextUtility'
  );



/* group: Функции */


/* group: Сравнение строк */

/* func: levenshteinDistance
  Вычисление Расстояния Редактирования (Дистанции Левенштейна).

  Параметры:
    source                            - Исходная строка
    target                            - Строка, которую необходимо получить

  Возвращаемое функцией значение:
    - Расстояние Редактирования (Дистанция Левенштейна)

*/
function levenshteinDistance(
  source varchar2
  , target varchar2
)
return integer
is
  -- Длинна исходной строки.
  n integer;
  -- Длинна целевой строки.
  m integer;
  -- Переменные для использования в циклах.
  i integer;
  j integer;
  -- Рабочая матрица.
  type D1_array_integer_t is table of integer;
  type D2_array_integer_t is table of D1_array_integer_t;
  matrix D2_array_integer_t := null;
  -- Символ исходной строки.
  s varchar2(1);
  -- Символ целевой строки.
  t varchar2(1);
  -- Стоимость необходимой замены символов.
  cost integer;

  -- Minimum из трех параметров.
  function minimum(
    a integer
    , b integer
    , c integer
  )
  return integer
  is
    -- Minimum.
    m integer := null;
  begin
    m := a;

    if b < m then
      m := b;
    end if;

    if c < m then
      m := c;
    end if;

    return m;
  end minimum;

begin
  -- Вычислим длины исходной и целевой строк.
  n := length(source);
  m := length(target);

  -- Вернем null если исходная и целевая строки пустые.
  if n is null and m is null then
    return null;
  -- Вернем m если исходная строка пустая.
  elsif n = 0 or n is null then
    return m;
  -- Вернем n если целевая строка пустая.
  elsif m = 0 or m is null then
    return n;
  end if;

  -- Сформируем рабочую матрицу.
  matrix := D2_array_integer_t();
  for j in 1..(m + 1) loop
    matrix.extend;
    matrix(j) := D1_array_integer_t();
    for i in 1..(n + 1) loop
      matrix(j).extend;
    end loop;
  end loop;

  -- Заполним первую строку.
  for i in 1..(n + 1) loop
    matrix(1)(i) := i - 1;
  end loop;

  -- Заполним первую колонку.
  for j in 2..(m + 1) loop
    matrix(j)(1) := j - 1;
  end loop;

  -- Пробежимся по исходной строке.
  for i in 2..(n + 1) loop
    s := substr(source, i - 1, 1);

    -- Пробежимся по целевой строке.
    for j in 2..(m + 1) loop
      t := substr(target, j - 1, 1);

      cost := case
        when t = s then 0
        else 1
      end;

      matrix(j)(i) := minimum(
        matrix(j)(i - 1) + 1,
        matrix(j - 1)(i) + 1,
        matrix(j - 1)(i - 1) + cost
      );
    end loop;
  end loop;

  return matrix(m + 1)(n + 1);

exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.ErrorStack(
        'Ошибка вычисления Расстояния Редактирования (Дистанции Левенштейна) ('
        || 'source = "' || source || '"'
        || ', target = "' || target || '"'
        || ')'
      )
    , true
  );
end levenshteinDistance;

/* proc: normalizeWordList
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
*/
function normalizeWordList(
  sourceString varchar2
  , addonDelimiterList varchar2 := null
)
return varchar2
is

  -- Строковый тип максимальной длины
  subtype MaxVarchar2 is varchar2(32767);
  -- Двумерный массив слов
  type WordListT is table of MaxVarchar2;
  wordList WordListT := WordListT();

  -- Результирущая строка
  resultString MaxVarchar2 := '';

  /*
    Быстрая сортировка Хоара.
  */
  procedure quickSort(
    low integer
    , high integer
  )
  is
    i integer;
    j integer;
    wsp MaxVarchar2;
    m MaxVarchar2;
  begin
    i := low;
    j := high;
    m := wordList( trunc( ( i + j) / 2));
    for safeCycle in 1..10000 loop
      while ( wordList( i) < m) loop
        i := i + 1;
      end loop;
      while ( wordList( j) > m) loop
        j := j - 1;
      end loop;
      if ( i <= j) then
        wsp := wordList( i);
        wordList( i) := wordList( j);
        wordList( j) := wsp;
        i := i + 1;
        j := j - 1;
      end if;
      if ( i > j) then
        exit;
      end if;
      if safeCycle >= 10000 then
        raise_application_error(
          pkg_Error.IllegalArgument
          , 'Произошло зацикливание в функции quickSort'
        );
      end if;
    end loop;
    if ( low < j) then
      quickSort( low, j);
    end if;
    if ( i < high) then
      quickSort( i, high);
    end if;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка сортировки ('
          || ' low=' || to_char( low)
          || ', high=' || to_char( high)
          || ').'
        )
      , true
    );
  end quickSort;

  /*
    Разбор исходной строки на слова.
  */
  procedure parseSourceString
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
      wordList.extend( 1);
      wordList( wordList.count) := newWord;
      logger.trace( 'addWord: "' || newWord || '"');
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
          'Ошибка разбора исходной строки'
        )
      , true
    );
  end parseSourceString;

  /*
    Формирование итогового слова.
  */
  procedure createResultString
  is
    -- Индекс текущего слова
    currentWordIndex integer;
    -- Новое ли слово
    isNewWord boolean;
  begin
    for i in 1 .. wordList.count loop
      if ( wordList( i) is null ) then
        raise_application_error(
          pkg_Error.IllegalArgument
          , 'Найдено пустое слово'
        );
      end if;
      if ( currentWordIndex is null ) then
        isNewWord := true;
      else
        isNewWord := ( wordList( currentWordIndex) <> wordList( i));
      end if;
      if isNewWord then
        resultString := ltrim( resultString || ' ' || wordList( i));
        currentWordIndex := i;
      end if;
    end loop;
    logger.trace( 'resultString: "' || resultString || '"');
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка формирования результирующей строки'
        )
      , true
    );
  end createResultString;

-- normalizeWordList
begin
  parseSourceString();
  if ( wordList.count > 0) then
    quickSort( 1, wordList.count);
    createResultString();
  end if;
  return
    resultString
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка нормализации списка слов'
      )
    , true
  );
end normalizeWordList;

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

-- wordListCloseness
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

end pkg_TextUtility;
/
