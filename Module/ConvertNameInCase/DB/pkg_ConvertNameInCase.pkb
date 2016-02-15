create or replace package body pkg_ConvertNameInCase is
/* package body: pkg_ConvertNameInCase::body */



/* group: Функции */

/* ifunc: getExceptionCase
  Функция поиска записи в справочнике исключений.

  Входные параметры:
    stringNativeCase            - Строка исключения в именительном падеже
    sexCode                     - Пол (M - мужской, W - женский)
    typeExceptionCode           - Тип исключения

  Возврат:
    запись со всеми полями представления <v_ccs_case_exception>.
*/
function getExceptionCase(
  stringNativeCase varchar2
  , sexCode varchar2
  , typeExceptionCode varchar2
)
return v_ccs_case_exception%rowtype
is
  -- Запись с исключением
  exceptionRec v_ccs_case_exception%rowtype;

-- getExceptionCase
begin
  select
    *
  into
    exceptionRec
  from
    v_ccs_case_exception ce
  where
    upper( trim( ce.native_case_name ) ) = upper( trim( stringNativeCase ) )
    and ce.sex_code = sexCode
    and ce.type_exception_code = typeExceptionCode
  ;

  return exceptionRec;

exception
  when no_data_found then
    return null;
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Во время поиска записи в справочнике исключений'
        || ' произошла ошибка ('
        || sqlerrm
        || ').'
      , true
    );
end getExceptionCase;

/* iproc: mergeExceptionCase
  Процедура добавления/обновления записи в справочнике исключений.
  Работает в автономной транзации для уменьшения количества блокировок
  таблицы исключений.

  Входные параметры:
    stringException             - Строка исключения
    stringNativeCase            - Строка исключения в именительном падеже
    sexCode                     - Пол (M - мужской, W - женский)
    typeExceptionCode           - Тип исключения
    caseCode                    - код падежа,
                                  (NAT - именительный, GEN -  родительный
                                  , DAT-дательный, ACC - винительный
                                  , ABL- творительный, PREP- предложный)
    operatorId                  - ИД оператора

  Выходные параметры отсутствуют.
*/
procedure mergeExceptionCase(
  stringException varchar2
  , stringNativeCase varchar2
  , sexCode varchar2 default Women_SexCode
  , typeExceptionCode varchar2
  , caseCode varchar2
  , operatorId integer
)
is
  pragma autonomous_transaction;

-- mergeExceptionCase
begin
  -- Добавляем/обновляем данные в таблице исключений
  merge into
    ccs_case_exception dst
  using
    (
    select
      stringNativeCase as native_case_name
      , upper( trim( sexCode ) ) as sex_code
      , upper( trim( typeExceptionCode ) ) as type_exception_code
      , decode(
          upper( trim( caseCode ) )
          , pkg_ConvertNameInCase.Genetive_CaseCode
          , initcap( stringException )
          , null
        ) as genetive_case_name
      , decode(
          upper( trim( caseCode ) )
          , pkg_ConvertNameInCase.Dative_CaseCode
          , initcap( stringException )
          , null
        ) as dative_case_name
      , decode(
          upper( trim( caseCode ) )
          , pkg_ConvertNameInCase.Accusative_CaseCode
          , initcap( stringException )
          , null
        ) as accusative_case_name
      , decode(
          upper( trim( caseCode ) )
          , pkg_ConvertNameInCase.Ablative_CaseCode
          , initcap( stringException )
          , null
        ) as ablative_case_name
      , decode(
          upper( trim( caseCode ) )
          , pkg_ConvertNameInCase.Preposition_CaseCode
          , initcap( stringException )
          , null
        ) as preposition_case_name
      , operatorId as operator_id
    from
      dual
    ) src
  on
    (
    upper( trim( dst.native_case_name ) ) = upper( trim( src.native_case_name ) )
    and dst.sex_code = src.sex_code
    and dst.type_exception_code = src.type_exception_code
    )
  when matched then
    update set
      dst.genetive_case_name =
        coalesce( src.genetive_case_name, dst.genetive_case_name )
      , dst.dative_case_name =
          coalesce( src.dative_case_name, dst.dative_case_name )
      , dst.accusative_case_name =
          coalesce( src.accusative_case_name, dst.accusative_case_name )
      , dst.ablative_case_name =
          coalesce( src.ablative_case_name, dst.ablative_case_name )
      , dst.preposition_case_name =
          coalesce( src.preposition_case_name, dst.preposition_case_name )
      , dst.deleted = 0
  when not matched then
    insert(
      dst.native_case_name
      , dst.genetive_case_name
      , dst.dative_case_name
      , dst.accusative_case_name
      , dst.ablative_case_name
      , dst.preposition_case_name
      , dst.sex_code
      , dst.type_exception_code
      , dst.operator_id
    )
    values(
      src.native_case_name
      , src.genetive_case_name
      , src.dative_case_name
      , src.accusative_case_name
      , src.ablative_case_name
      , src.preposition_case_name
      , src.sex_code
      , src.type_exception_code
      , src.operator_id
    )
  ;

  commit;

exception
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Во время добавления/обновления записи в справочнике исключений'
        || ' произошла ошибка ('
        || sqlerrm
        || ').'
      , true
    );
end mergeExceptionCase;

/* ifunc: getNormalizedString
  Функция нормализации строки - удаления всех пробелов до и
  после символа "-" и символов "(", ")" и текста внутри скобок.

  Входные параметры
    inputString                 - Исходная строка

  Возврат:
    outputStr                   - Нормализованная строка
*/
function getNormalizedString(
  inputString varchar2
)
return varchar2
is
-- getNormalizedString
begin
  -- Удаляем все пробелы до и после символа "-"
  return regexp_replace(
    -- Удаляем символы "(", ")" и текст внутри скобок
    regexp_replace(
      inputString
      , '\(([^()]*)\)'
    )
    , '\s*[-–—]\s*'
    , '-'
  );
end getNormalizedString;

/* ifunc: getSexCode
  Функция определения пола, если он не задан явно.

  Входные параметры:
    stringNativeCase               - Строка в именительном падеже
    formatString                   - Формат преобразования
*/
function getSexCode(
  stringNativeCase varchar2
  , formatString varchar2
)
return varchar2
is
  sexCode varchar2(1);

-- getSexCode
begin
  sexCode :=
    -- Ищем позицию отчества в исходной строке и выделяем его
    -- окончание
    case when
      -- Чтобы не было ошибки в случае, когда в строке нет отчетства
      instr( formatString, pkg_ConvertNameInCase.MiddleName_TypeExceptionCode, 1 ) > 0
      and (
        upper(
          substr(
            regexp_substr(
              stringNativeCase
              , '[^ ]+'
              , 1
              , instr( formatString, pkg_ConvertNameInCase.MiddleName_TypeExceptionCode, 1 )
            )
            , -1
          )
        ) = 'Ч'
        or upper( stringNativeCase ) like '%ОГЛЫ%'
      )
    then
      Men_SexCode
    else
      Women_SexCode
    end
  ;

  return coalesce( sexCode, Women_SexCode );

end getSexCode;

/* proc: updateExceptionCase
  Процедура добавления/обновления записи в справочнике исключений.

  Входные параметры:
    exceptionCaseId             - ИД записи исключения
    stringException             - Строка исключения
    stringNativeCase            - Строка исключения в именительном падеже
    stringConvertInCase         - Строка, полученная склонением функцией
                                  convertNameInCase
    formatString                - формат строки для преобразования (
                                  "L"- строка содержит фамилию
                                  , "F"- строка содержит имя
                                  , "M" - строка содержит отчество)
                                  , если параметр null, то считаем,
                                  что формат строки "LFM"
    sexCode                     - Пол (M - мужской, W - женский)
    caseCode                    - код падежа (NAT - именительный
                                  , GEN - родительный
                                  , DAT - дательный, ACC - винительный
                                  , ABL - творительный, PREP - предложный)
    operatorId                  - ИД оператора

  Выходные параметры отсутствуют.
*/
procedure updateExceptionCase(
  exceptionCaseId integer default null
  , stringException varchar2
  , stringNativeCase varchar2
  , stringConvertInCase varchar2
  , formatString varchar2
  , sexCode varchar2 default null
  , caseCode varchar2
  , operatorId integer
)
is
  -- Код типа исключения
  typeExceptionCode ccs_case_exception.type_exception_code%type;
  -- Пол
  sexCodeNormalized ccs_case_exception.sex_code%type;
  -- Запись исключения
  caseExceptionRec ccs_case_exception%rowtype;
  -- Нормализованный формат строки
  normalizedFormatStr varchar2(20) := upper( trim( formatString ) );
  -- Тип падежа
  normalizedCaseCode varchar2(20) := upper( trim( caseCode ) );

  -- Нормализованные значения строк ФИО
  -- Строка с исключением
  normalizedstringException varchar2(150);
  -- Строка в именительном падеже
  normalizedstringNativeCase varchar2(150);
  -- Строка результат преобразования функции
  normalizedStrConvertInCase varchar2(150);

  -- Разбиваем строки по частям в соответствии с форматом
  -- Строка исключение
  stringExceptionPart varchar2(50);
  -- Строка в именительном падеже
  stringNativeCasePart varchar2(50);
  -- Строка результат работы функции преобразования
  strConvertInCasePart varchar2(50);

-- updateExceptionCase
begin
  -- Получаем нормализованные строки
  normalizedstringException := getNormalizedString( stringException );
  normalizedstringNativeCase := getNormalizedString( stringNativeCase );
  normalizedStrConvertInCase := getNormalizedString( stringConvertInCase );

  -- Пол
  sexCodeNormalized := coalesce(
    sexCode
    , getSexCode(
        stringNativeCase => normalizedStringNativeCase
        , formatString => normalizedFormatStr
      )
  );

  -- Если указан ИД записи - редактируем ее
  if exceptionCaseId is not null then
    -- Считываем параметры записи
    select
      *
    into
      caseExceptionRec
    from
      ccs_case_exception ce
    where
      ce.exception_case_id = exceptionCaseId
    ;

    if caseExceptionRec.Deleted = 1 then
      raise_application_error(
        pkg_Error.ErrorStackInfo
        , 'Невозможно редактировать удаленную запись.'
        , true
      );
    end if;

    -- Выделяем исключение из строки
    -- Тип исключения берем из записи по ид-ку и определяем
    -- какую часть исходной строки с исключением необходимо сохранить
    stringExceptionPart := regexp_substr(
      normalizedstringException
      , '[^ ]+'
      , 1
      , instr( normalizedFormatStr, caseExceptionRec.Type_Exception_Code, 1 )
    );
    -- Выделяем именительный падеж исключения
    stringNativeCasePart := regexp_substr(
      normalizedStringNativeCase
      , '[^ ]+'
      , 1
      , instr( normalizedFormatStr, caseExceptionRec.Type_Exception_Code, 1 )
    );
    -- Обновляем запись в таблице исключений
    update
      ccs_case_exception ce
    set
      ce.genetive_case_name =
        case when
          normalizedCaseCode = pkg_ConvertNameInCase.Genetive_CaseCode
        then
          stringExceptionPart
        else
          ce.genetive_case_name
        end
      , ce.dative_case_name =
          case when
            normalizedCaseCode = pkg_ConvertNameInCase.Dative_CaseCode
          then
            stringExceptionPart
          else
            ce.dative_case_name
          end
      , ce.accusative_case_name =
          case when
            normalizedCaseCode = pkg_ConvertNameInCase.Accusative_CaseCode
          then
            stringExceptionPart
          else
            ce.accusative_case_name
          end
      , ce.ablative_case_name =
          case when
            normalizedCaseCode = pkg_ConvertNameInCase.Ablative_CaseCode
          then
            stringExceptionPart
          else
            ce.ablative_case_name
          end
      , ce.preposition_case_name =
          case when
            normalizedCaseCode = pkg_ConvertNameInCase.Preposition_CaseCode
          then
            stringExceptionPart
          else
            ce.preposition_case_name
          end
      , ce.sex_code = sexCodeNormalized
    where
      ce.exception_case_id = exceptionCaseId
    ;

  -- Если задан именительный падеж - добавляем/обновляем исключение
  elsif stringNativeCase is not null then
    for i in 1..length( normalizedFormatStr ) loop
      -- Определяем код типа исключения
      typeExceptionCode := substr( normalizedFormatStr, i, 1 );

      -- Выделяем часть из строки с именительным падежом по
      -- позиции, соответствующей коду исключения
      stringNativeCasePart := regexp_substr(
        normalizedStringNativeCase
        , '[^ ]+'
        , 1
        , i
      );
      -- Выделяем часть из строки с исключением по
      -- позиции, соответствующей коду исключения
      stringExceptionPart := regexp_substr(
        normalizedstringException
        , '[^ ]+'
        , 1
        , i
      );
      -- Выделяем часть из строки с результатом функции преобразования по
      -- позиции, соответствующей коду исключения
      strConvertInCasePart := regexp_substr(
        normalizedStrConvertInCase
        , '[^ ]+'
        , 1
        , i
      );

      -- Если исключение не совпадает с
      -- результатом функции преобразования - сохраняем его в таблице
      if stringExceptionPart != strConvertInCasePart then
        mergeExceptionCase(
          stringException => stringExceptionPart
          , stringNativeCase => stringNativeCasePart
          , sexCode => sexCodeNormalized
          , typeExceptionCode => typeExceptionCode
          , caseCode => caseCode
          , operatorId => operatorId
        );
      end if;

    end loop;
  -- Если не задан ни 1 параметр - генерируем ошибку
  else
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Невозможно добавить запись в таблицу исключений.'
      , true
    );
  end if;

exception
  when no_data_found then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Указан ИД несуществующей записи ('
        || 'exceptionCaseId="' || to_char( exceptionCaseId ) || '"'
        || ').'
      , true
    );
  when dup_val_on_index then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Запись с такими параметрами уже существует в справочнике'
        || ' исключений ('
        || 'exceptionCaseId="' || to_char( exceptionCaseId ) || '"'
        || ', sexCode="' || sexCode || '"'
        || ').'
      , true
    );
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Во время добавления/обновления записи в справочнике исключений '
        || ' произошла ошибка ('
        || 'exceptionCaseId="' || to_char( exceptionCaseId ) || '"'
        || ', stringException="' || stringException || '"'
        || ', stringNativeCase="' || stringNativeCase || '"'
        || ', stringConvertInCase="' || stringConvertInCase || '"'
        || ', formatString="' || formatString || '"'
        || ', sexCode="' || sexCode || '"'
        || ', caseCode="' || caseCode || '"'
        || ', operatorId="' || to_char( operatorId ) || '"'
        || ').'
      , true
    );
end updateExceptionCase;

/* ifunc: convertInCase
  Функция преобразования ФИО к указанному падежу.

  Входные параметры:
    nameText                    - Строка для преобразования
    typeExceptionCode           - Формат строки для преобразования
    caseCode                    - Код падежа преобразования (
                                  NAT - именительный, GEN -  родительный
                                  , DAT-дательный, ACC - винительный
                                  , ABL- творительный, PREP- предложный)
    sexCode                     - Пол W-women (женский), M-men (мужской)

  Возврат:
    строка в указанном падеже.
*/

function convertInCase(
  nameText varchar2
  , typeExceptionCode varchar2
  , caseCode varchar2
  , sexCode varchar2 default Women_SexCode
)
return varchar2
is
  tailChr varchar2(1);
  nameInCase varchar2(50) := nameText;

  --
  function termCompare(
    nameText varchar2
    , tail varchar2
  )
  return boolean
  is
  -- termCompare
  begin
    if nvl( length( nameText ) , 0 ) < nvl( length( tail ), 0 ) then
      return false;
    end if;

    if lower( substr( nameText, -length( tail ) ) ) = lower( tail ) then
      return true;
    else
      return false;
    end if;

  end termCompare;

  /*
    Процедура дополнения необходимым окончанием в зависимости от падежа.
  */
  procedure makeName(
    nameText in out varchar2
    , posNumber number
    , genTail varchar2
    , datTail varchar2
    , accTail varchar2
    , ablTail varchar2
    , preTail varchar2
  )
  is
  begin
    select
      substr( nameText, 1, length( nameText ) - posNumber )
      || decode(
        caseCode
        , pkg_ConvertNameInCase.Genetive_CaseCode
        , genTail
        , pkg_ConvertNameInCase.Dative_CaseCode
        , datTail
        , pkg_ConvertNameInCase.Ablative_CaseCode
        , ablTail
        , pkg_ConvertNameInCase.Accusative_CaseCode
        , accTail
        , pkg_ConvertNameInCase.Preposition_CaseCode
        , preTail
      )
    into
      nameText
    from
      dual
    ;
  end makeName;

-- convertInCase
begin
  -- Фамилия
  if typeExceptionCode = pkg_ConvertNameInCase.LastName_TypeExceptionCode then
    -- Предусмотрим обработку сдвоенной фамилии:
    if instr( nameText, '-' ) > 0 then
      nameInCase :=
        -- Для фамилий, содержащих приставки -сюрюн, -сал,
        -- -оол, -оглы, -кызы, -кыс, -заде
        -- первую часть фамилии не склоняем
        case when
          upper(
            substr( nameText, instr( nameText, '-' ) + 1 )
          ) not in (
            'СЮРЮН'
            , 'САЛ'
            , 'ООЛ'
            , 'ОГЛЫ'
            , 'КЫЗЫ'
            , 'КЫС'
            , 'ЗАДЕ'
          )
        then
          convertNameInCase(
            nameText => substr( nameText, 1, instr( nameText, '-' ) - 1 )
            , formatString => pkg_ConvertNameInCase.LastName_TypeExceptionCode
            , caseCode => caseCode
            , sexCode => sexCode
          )
        else
          substr( nameText, 1, instr( nameText, '-' ) - 1 )
        end
        || '-'
        || convertNameInCase(
             nameText => substr( nameText, instr( nameText, '-' ) + 1 )
             , formatString => pkg_ConvertNameInCase.LastName_TypeExceptionCode
             , caseCode => caseCode
             , sexCode => sexCode
           )
      ;
    else

      tailChr := lower( substr( nameText, -1 ) );
      -- Мужчины
      if sexCode = Men_SexCode then
        if tailChr not in ( 'о', 'е', 'у', 'ю', 'и', 'э', 'ы' ) then
          if tailChr = 'в' then
            makeName( nameInCase, 0, 'а', 'у', 'а', 'ым', 'е' );
          elsif tailChr = 'н'
            and termCompare( nameInCase, 'ин' )
          then
            makeName( nameInCase, 0, 'а', 'у', 'а', 'ым', 'е' );
          elsif tailChr = 'ц'
            and termCompare( nameText, 'ец' )
          then
            if length( nameText ) > 3
              and lower( substr( nameText, -3 ) ) in (
                'аец', 'еец', 'иец', 'оец', 'уец'
              )
            then
              makeName( nameInCase, 2, 'йца', 'йцу', 'йца', 'йцем', 'йце' );
            elsif length( nameText ) > 3
              and lower( substr( nameText, -3 ) ) in (
                'тец', 'бец', 'вец', 'мец', 'нец', 'рец', 'сец'
              )
              and lower( substr( nameText, -4, 1 ) ) in (
                'а', 'е', 'и', 'о', 'у', 'ы', 'э', 'ю', 'я', 'ё'
              )
            then
              makeName( nameInCase, 2, 'ца', 'цу', 'ца', 'цом', 'це' );
            elsif length( nameText ) > 3
              and lower( substr( nameText, -3 ) ) = 'лец'
            then
              makeName( nameInCase, 2, 'ьца', 'ьцу', 'ьца', 'ьцом', 'ьце' );
            else
              makeName( nameInCase, 0, 'а', 'у', 'а', 'ом', 'е' );
            end if;
          elsif tailChr = 'х'
            and (
              termCompare( nameText, 'их' )
              or termCompare( nameText, 'ых' )
            )
          then
            makeName( nameInCase, 0, null, null, null, null, null );
          elsif tailChr in (
            'б', 'г', 'д', 'ж', 'з', 'л', 'м', 'н', 'п', 'р', 'с'
            , 'т', 'ф', 'х', 'ц', 'ч', 'ш', 'щ'
          )
          then
            makeName( nameInCase, 0, 'а', 'у', 'а', 'ом', 'е' );
          elsif tailChr = 'я'
            and not(
              termCompare( nameText, 'ия' )
              or termCompare( nameText, 'ая' )
            )
          then
            makeName( nameInCase, 1, 'и', 'е', 'ю', 'ей', 'е' );
          elsif tailChr = 'а'
            and not(
              termCompare( nameText, 'иа' )
              or termCompare( nameText, 'уа' )
            )
          then
            makeName( nameInCase, 1, 'и', 'е', 'у', 'ой', 'е' );
          elsif tailChr = 'ь' then
            makeName( nameInCase, 1, 'я', 'ю', 'я', 'ем', 'е' );
          elsif tailChr = 'к' then
            if length( nameText ) > 4
              and termCompare( nameText, 'ок' )
            then
              makeName( nameInCase, 2, 'ка', 'ку', 'ка', 'ком', 'ке' );
            elsif length( nameText ) > 4
              and (
                termCompare( nameText, 'лек' )
                or termCompare( nameText, 'рек' )
              )
            then
              makeName( nameInCase, 2, 'ька', 'ьку', 'ька', 'ьком', 'ьке' );
            else
              makeName( nameInCase, 0, 'а', 'у', 'а', 'ом', 'е' );
            end if;
          elsif tailChr = 'й' then
            if length( nameText ) > 4 then
              if termCompare( nameText, 'ский' )
                or termCompare( nameText, 'цкий' )
              then
                makeName( nameInCase, 2, 'ого', 'ому', 'ого', 'им', 'ом' );
              elsif termCompare( nameText, 'ой' ) then
                makeName( nameInCase, 2, 'ого', 'ому', 'ого', 'им', 'ом' );
              elsif termCompare( nameText, 'ый' ) then
                makeName( nameInCase, 2, 'ого', 'ому', 'ого', 'ым', 'ом' );
              elsif lower( substr( nameText, -3 ) ) in (
                'рий', 'жий', 'лий', 'вий', 'дий'
                , 'бий', 'гий', 'зий', 'мий', 'ний', 'пий', 'сий', 'фий', 'хий'
              )
              then
                makeName( nameInCase, 1, 'я', 'ю', 'я', 'ем', 'и' );
              elsif termCompare( nameText, 'ий' ) then
                makeName( nameInCase, 2, 'его', 'ему', 'его', 'им', 'им' );
              else
                makeName( nameInCase, 1, 'я', 'ю', 'я', 'ем', 'е' );
              end if;
            else
              makeName( nameInCase, 1, 'я', 'ю', 'я', 'ем', 'е' );
            end if;
          end if;
        end if;
      -- Женщины
      elsif sexCode = Women_SexCode then
        if lower( substr( nameText, -3 ) ) in (
          'ова', 'ева', 'ына', 'ина', 'ена'
        )
        then
          makeName( nameInCase, 1, 'ой', 'ой', 'у', 'ой', 'ой' );
        elsif termCompare( nameText, 'ая' )
          and lower( substr( nameText, -3, 1 ) ) = 'ц'
        then
          makeName( nameInCase, 2, 'ей', 'ей', 'ую', 'ей', 'ей' );
        elsif termCompare( nameText, 'ая' ) then
          makeName( nameInCase, 2, 'ой', 'ой', 'ую', 'ой', 'ой' );
        elsif termCompare( nameText, 'ля' )
          or termCompare( nameText, 'ня' )
        then
          makeName( nameInCase, 1, 'и', 'е', 'ю', 'ей', 'е' );
        elsif termCompare( nameText, 'а' )
          and lower( substr( nameText, -2, 1 ) ) = 'д'
        then
          makeName( nameInCase, 1, 'ы', 'е', 'у', 'ой', 'е' );
        end if;
      end if;
    end if;

  -- Имя
  elsif typeExceptionCode = pkg_ConvertNameInCase.FirstName_TypeExceptionCode then
    tailChr := lower( substr( nameText, -1 ) );
    -- Мужчины
    if sexCode = Men_SexCode then
      if tailChr not in ( 'е', 'и', 'у' ) then
        if upper( nameText ) = 'ЛЕВ' then
          makeName( nameInCase, 2, 'ьва', 'ьву', 'ьва', 'ьвом', 'ьве' );
        elsif tailChr in (
          'б', 'в', 'г', 'д', 'з', 'ж', 'к', 'м', 'н', 'п', 'р'
          , 'с', 'т', 'ф', 'х', 'ц', 'ч', 'ш', 'щ'
        )
        then
          makeName( nameInCase, 0, 'а', 'у', 'а', 'ом', 'е' );
        elsif tailChr = 'а' then
          makeName( nameInCase, 1, 'ы', 'е', 'у', 'ой', 'е' );
        elsif tailChr = 'о' then
          makeName( nameInCase, 1, 'а', 'у', 'а', 'ом', 'е' );
        elsif tailChr = 'я' then
          if termCompare( nameText, 'ья' ) then
            makeName( nameInCase, 1, 'и', 'е', 'ю', 'ей', 'е' );
          elsif termCompare( nameText, 'ия' ) then
            makeName( nameInCase, 1, 'и', 'е', 'ю', 'ей', 'е' );
          else
            makeName( nameInCase, 1, 'и', 'е', 'ю', 'ей', 'е' );
          end if;
        elsif tailChr = 'й' then
          if termCompare( nameText, 'ай' ) then
            makeName( nameInCase, 1, 'я', 'ю', 'я', 'ем', 'е' );
          else
            if termCompare( nameText, 'ей' ) then
              makeName( nameInCase, 1, 'я', 'ю', 'я', 'ем', 'е' );
            else
              makeName( nameInCase, 1, 'я', 'ю', 'я', 'ем', 'и' );
            end if;
          end if;
        elsif tailChr = 'ь' then
          makeName( nameInCase, 1, 'я', 'ю', 'я', 'ем', 'е' );
        elsif tailChr = 'л' then
          if termCompare( nameText, 'авел' ) then
            makeName( nameInCase, 2, 'ла', 'лу', 'ла', 'лом', 'ле' );
          else
            makeName( nameInCase, 0, 'а', 'у', 'а', 'ом', 'е' );
          end if;
        end if;
      end if;
    -- женщины
    elsif sexCode = Women_SexCode then
      if tailChr = 'а'
        and length( nameText ) > 1
      then
        if lower( substr( nameText, -2 ) ) in (
          'га', 'ха', 'ка', 'ша', 'ча', 'ща', 'жа'
        )
        then
          makeName( nameInCase, 1, 'и', 'е', 'у', 'ой', 'е' );
        else
          makeName( nameInCase, 1, 'ы', 'е', 'у', 'ой', 'е' );
        end if;
      elsif tailChr = 'я'
        and length( nameText ) > 1
      then
        if termCompare( nameText, 'ия' )
          and lower( substr( nameText, -4 ) ) = 'ьфия'
        then
          makeName( nameInCase, 1, 'и', 'е', 'ю', 'ей', 'е' );
        elsif termCompare( nameText, 'ия' ) then
          makeName( nameInCase, 1, 'и', 'и', 'ю', 'ей', 'и' );
        else
          makeName( nameInCase, 1, 'и', 'е', 'ю', 'ей', 'е' );
        end if;
      elsif tailChr = 'ь' then
        if termCompare( nameText, 'вь' ) then
          makeName( nameInCase, 1, 'и', 'и', 'ь', 'ью', 'и' );
        else
          makeName( nameInCase, 1, 'и', 'и', 'ь', 'ью', 'ье' );
        end if;
      end if;
    end if;

  -- Отчество
  elsif typeExceptionCode = pkg_ConvertNameInCase.MiddleName_TypeExceptionCode then
    tailChr := lower( substr( nameText, -1 ) );
    -- Мужчины
    if sexCode = Men_SexCode then
      if tailChr = 'ч' then
        makeName( nameInCase, 0, 'а', 'у', 'а', 'ем', 'е' );
      end if;
    -- Женщины
    elsif sexCode = Women_SexCode then
      if tailChr = 'а'
        and length( nameText ) != 1
      then
        makeName( nameInCase, 1, 'ы', 'е', 'у', 'ой', 'е' );
      end if;
    end if;
  end if;

  return nameInCase;

end convertInCase;

/* func: convertNameInCase
  Функция преобразования ФИО к указанному падежу. Порядок слов
  в формате и в переданной строке должен совпадать. Двойные фамилии
  должны отделяться друг от друга знаком "-", при этом количество пробелов до
  и после знака не важно.

  Входные параметры:
    nameText                    - Строка для преобразования
    formatString                - Формат строки для преобразования
    caseCode                    - Код падежа преобразования
    sexCode                     - Пол

  Возврат:
    строка в указанном падеже.
*/
function convertNameInCase(
  nameText varchar2
  , formatString varchar2
  , caseCode varchar2
  , sexCode varchar2 default null
)
return varchar2
is
  -- Результат преобразования
  strConvertInCase varchar2(150);
  -- Код типа исключения
  typeExceptionCode ccs_case_exception.type_exception_code%type;
  -- Пол
  normalizedsexCode ccs_case_exception.sex_code%type;
  -- Нормализованный формат строки
  normalizedFormatStr varchar2(20) := upper( trim( formatString ) );
  -- Тип падежа
  normalizedCaseCode varchar2(20) := upper( trim( caseCode ) );

  -- Нормализованная строка в именительном падеже
  normalizedStringNativeCase varchar2(150);

  -- Строка результат работы функции преобразования
  strConvertInCasePart varchar2(50);

  -- Запись с исключением
  exceptionRec v_ccs_case_exception%rowtype;

  -- Строка в именительном падеже
  stringNativeCasePart varchar2(50);

  -- Исключение при некорректном формате
  UncorrectFormat exception;
  -- Флаг наличия кода типа исключения в справочнике
  isExceptionTypeCodeExists integer;

  -- Оглы, Кызы
  isOglyExists integer;
  isKyzyExists integer;

-- convertNameInCase
begin
  -- Получаем нормализованные строки
  normalizedStringNativeCase := getNormalizedString( nameText );

  select
    count(*)
  into
    isExceptionTypeCodeExists
  from
    ccs_type_exception te
  where
    instr( normalizedFormatStr, te.type_exception_code, 1 ) > 0
  ;

  if normalizedStringNativeCase is null
    or isExceptionTypeCodeExists = 0
    or normalizedCaseCode not in (
      pkg_ConvertNameInCase.Genetive_CaseCode
      , pkg_ConvertNameInCase.Dative_CaseCode
      , pkg_ConvertNameInCase.Accusative_CaseCode
      , pkg_ConvertNameInCase.Ablative_CaseCode
      , pkg_ConvertNameInCase.Preposition_CaseCode
    )
  then
    raise UncorrectFormat;
  end if;

  -- Пол
  normalizedSexCode := coalesce(
    sexCode
    , getSexCode(
        stringNativeCase => normalizedStringNativeCase
        , formatString => normalizedFormatStr
      )
  );

  -- Проверяем наличие "оглы" и "кызы"
  -- оглы
  select
    count(*)
  into
    isOglyExists
  from
    (
    select
      regexp_substr(
        normalizedStringNativeCase
        , '[^ ]+'
        , 1
        , level
      ) as name
    from
      dual
    connect by
      level <= length( normalizedStringNativeCase ) -
        length( replace( normalizedStringNativeCase, ' ' ) ) + 1
    ) t
  where
    upper( t.name ) = upper( 'оглы' )
    -- Учитываем только приставку, если это само
    -- отчество - в конце не добавляем "оглы"
    and length( t.name ) > 4
  ;
  -- кызы
  select
    count(*)
  into
    isKyzyExists
  from
    (
    select
      regexp_substr(
        normalizedStringNativeCase
        , '[^ ]+'
        , 1
        , level
      ) as name
    from
      dual
    connect by
      level <= length( normalizedStringNativeCase ) -
        length( replace( normalizedStringNativeCase, ' ' ) ) + 1
    ) t
  where
    upper( t.name ) = upper( 'кызы' )
    -- Учитываем только приставку, если это само
    -- отчество - в конце не добавляем "кызы"
    and length( t.name ) > 4
  ;

  -- В цикле по формату преобразования
  for i in 1..length( normalizedFormatStr ) loop
    -- Определяем код типа исключения
    typeExceptionCode := substr( normalizedFormatStr, i, 1 );
    -- Выделяем именительный падеж из строки
    stringNativeCasePart := regexp_substr(
      normalizedStringNativeCase
      , '[^ ]+'
      , 1
      , i
    );

    -- Ищем в справочнике исключений
    exceptionRec := getExceptionCase(
      stringNativeCase => stringNativeCasePart
      , sexCode => normalizedSexCode
      , typeExceptionCode => typeExceptionCode
    );


    strConvertInCase := ltrim(
      strConvertInCase
      || ' '
      || coalesce(
           case
             normalizedCaseCode
           when
             Pkg_ConvertNameInCase.Genetive_CaseCode
           then
             exceptionRec.genetive_case_name
           when
             Pkg_ConvertNameInCase.Dative_CaseCode
           then
             exceptionRec.dative_case_name
           when
             Pkg_ConvertNameInCase.Accusative_CaseCode
           then
             exceptionRec.accusative_case_name
           when
             Pkg_ConvertNameInCase.Ablative_CaseCode
           then
             exceptionRec.ablative_case_name
           when
             Pkg_ConvertNameInCase.Preposition_CaseCode
           then
             exceptionRec.preposition_case_name
           end
           , convertInCase(
               nameText => stringNativeCasePart
               , typeExceptionCode => typeExceptionCode
               , caseCode => normalizedCaseCode
               , sexCode => normalizedsexCode
             )
         )
      -- Оглы, Кызы
      || case when
           typeExceptionCode = pkg_ConvertNameInCase.MiddleName_TypeExceptionCode
           and isOglyExists = 1
         then
           ' Оглы'
         when
           typeExceptionCode = pkg_ConvertNameInCase.MiddleName_TypeExceptionCode
           and isKyzyExists = 1
         then
           ' Кызы'
         end
    );

  end loop;

  return initCap( trim( strConvertInCase ) );

exception
  when UncorrectFormat then
    return normalizedStringNativeCase;
  when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , 'Во время преобразования ФИО к указанному падежу произошла ошибка ('
        || 'nameText="' || nameText || '"'
        || ', formatString="' || formatString || '"'
        || ', caseCode="' || caseCode || '"'
        || ', sexCode="' || sexCode || '"'
        || '):'
        || sqlerrm
        || '.'
      , true
    );
end convertNameInCase;

end pkg_ConvertNameInCase;
/
