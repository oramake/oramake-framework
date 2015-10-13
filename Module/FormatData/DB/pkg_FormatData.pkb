create or replace package body pkg_FormatData is
/* package body: pkg_FormatData::body */



/* group: Типы */

/* itype: TColAlias
  Тип для кэша синонимов.
*/
type TColAlias is table of fd_alias.base_name%type index by varchar2(60);

/* group: Константы */

/* iconst: Latin_SimilarChar
  Строка символов латиницы, похожих по написанию на символы кириллицы.
*/
Latin_SimilarChar constant varchar2(30) := 'AaBCcEeKMHOoPpTXxYy';

/* iconst: Cyrillic_SimilarChar
  Строка символов кириллицы, похожих по написанию на символы латиницы.
*/
Cyrillic_SimilarChar constant varchar2(30) := 'АаВСсЕеКМНОоРрТХхУу';

/* iconst: Code_TrimChar
  Символы, удаляемые с крайних позиций при нормализации кода.
*/
Code_TrimChar constant varchar2(30) := '.,_=';

/* iconst: Code_DelChar
  Строка символов, удаляемых при нормализации кода.
*/
Code_DelChar constant varchar2(30) := '- ' || chr(9);

/* iconst: Code_InChar
  Строка исходных символов для нормализации кода.
*/
Code_InChar constant varchar2(30) := '0' || Code_DelChar;

/* iconst: Code_OutChar
  Строка результирующих символов для нормализации кода.
*/
Code_OutChar constant varchar2(30) := '0';

/* iconst: BaseCode_DelChar
  Строка символов, удаляемых при получении базового значения кода.
*/
BaseCode_DelChar constant varchar2(30) := Code_DelChar || '*';

/* iconst: BaseCode_InChar
  Строка исходных символов для получения базового значения кода.
*/
BaseCode_InChar constant varchar2(30) :=
  'ЁёЗЙй' || Cyrillic_SimilarChar || Code_DelChar || '*'
;

/* iconst: BaseCode_OutChar
  Строка результирующих символов для получения базового значения кода.
*/
BaseCode_OutChar constant varchar2(30) :=
  'Ee3Ии' || Latin_SimilarChar
;

/* iconst: String_InChar
  Строка исходных символов для нормализации строки.
*/
String_InChar constant varchar2(30) := chr(9);

/* iconst: String_OutChar
  Строка результирующих символов для нормализации строки.
*/
String_OutChar constant varchar2(30) := ' ';

/* iconst: CyrillicString_InChar
  Строка исходных символов для нормализации строки с кириллицей.
*/
CyrillicString_InChar constant varchar2(30) := Latin_SimilarChar || 'Ёё';

/* iconst: CyrillicString_OutChar
  Строка результирующих символов для нормализации строки с кириллицей.
*/
CyrillicString_OutChar constant varchar2(30) := Cyrillic_SimilarChar || 'Ее';

/* const: BaseName_InChar
  Строка исходных символов для получения базовой формы названия.
*/
BaseName_InChar constant varchar2(30) := 'Йй';

/* const: BaseName_OutChar
  Строка результирующих символов для получения базовой формы названия.
*/
BaseName_OutChar constant varchar2(30) := 'Ии';

/* iconst: BaseName_TrimChar
  Символы, удаляемые с крайних позиций при получении базовой формы названия.
*/
BaseName_TrimChar constant varchar2(30) := '.,_=' || pkg_FormatBase.Zero_Value;

/* iconst: UpperLatin_Char
  Строка с буквами латинского алфавита в верхнем регистре.
*/
UpperLatin_Char constant varchar2(26) := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';

/* iconst: UpperLatin_CharLength
  Длина строки с буквами латинского алфавита в верхнем регистре
  <UpperLatin_Char>.
*/
UpperLatin_CharLength constant pls_integer := 26;

/* iconst: UpperCyrillic_Char
  Строка с буквами кириллического алфавита в верхнем регистре.
*/
UpperCyrillic_Char constant varchar2(33) := 'АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ';

/* iconst: UpperCyrillic_CharLength
  Длина строки с буквами кириллического алфавита в верхнем регистре
  <UpperCyrillic_Char>.
*/
UpperCyrillic_CharLength constant pls_integer := 33;

/* iconst: Vin_Char
  Строка с символами, допустимыми в VIN ( идентификационном номере автомобиля).
*/
Vin_Char constant varchar2(50) := '0123456789ABCDEFGHJKLMNPRSTUVWXYZ';

/* iconst: Vin_Length
  Длина корректного VIN ( идентификационного номера автомобиля).
*/
Vin_Length constant pls_integer := 17;



/* group: Переменные */

/* ivar: logger
  Логер пакета.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => pkg_FormatBase.Module_Name
  , objectName  => 'pkg_FormatData'
);

/* ivar: colAlias
  Кэш синонимов.
*/
colAlias TColAlias;



/* group: Функции */

/* func: getZeroValue
  Возвращает строку, обозначающую отсутствие значения.

  Возврат: значение константы <pkg_FormatBase.Zero_Value>.
*/
function getZeroValue
return varchar2
is
begin
  return pkg_FormatBase.Zero_Value;
end getZeroValue;



/* group: Форматирование */

/* func: formatCode
  Возвращает нормализованный код.

  Нормализация:
  - удаляются символы пробела, табуляции и тире;
  - обрезаются все ведущие/завершающие символы точка, запятая, подчеркивание;
  - если указана длина кода ( newLength), то значение обрезается до нужной
    длины или дополняется ведущими нулями;

  Параметры:
  sourceCode                  - исходный код
  newLength                   - требуемая длина кода

  Возврат:
  - нормализованный код
*/
function formatCode(
  sourceCode varchar2
  , newLength integer := null
)
return varchar2
is



  function formatCodeString(
    sourceCode varchar2
  )
  return varchar2
  is
  begin
    return
      rtrim(
        ltrim(
          translate( sourceCode, Code_InChar, Code_OutChar)
          , Code_TrimChar
        )
        , Code_TrimChar
      )
    ;
  end formatCodeString;



--formatCode
begin
  return
    case when newLength is null then
      formatCodeString( sourceCode)
    else
      lpad(
        formatCodeString( sourceCode)
        , newLength
        , '0'
      )
    end
  ;
end formatCode;

/* func: formatCodeExpr
  Возвращает выражение для нормализации кода.
  Предназначено для использования в динамическом SQL ( например, через
  execute immediate), нормализация идентична выполняемой в функции
  <formatCode>.

  Параметры:
  varName                     - имя переменной с исходным кодом
  newLength                   - требуемая длина кода

  Возврат:
  - строка с SQL-выражением над переменной varName для выполнения нормализации
*/
function formatCodeExpr(
  varName varchar2
  , newLength integer := null
)
return varchar2
is
--formatCodeExpr
begin
  return
    case when newLength is not null then
        'lpad( '
      end
    || 'rtrim( '
      || 'ltrim( '
        || 'translate( '
          || varName
          || ', ''' || Code_InChar || ''''
          || ', ''' || Code_OutChar || ''''
        || ')'
        || ', ''' || Code_TrimChar || ''''
      || ')'
      || ', ''' || Code_TrimChar || ''''
    || ')'
    || case when newLength is not null then
        ', ' || to_char( newLength) || ', ''0'')'
      end
  ;
end formatCodeExpr;

/* ifunc: formatString( INTERNAL)
  Возвращает нормализованную строку.

  Нормализация выполняется согласно описанию в функции <formatString>.
  Может быть выполнена дополнительная трансляция символов в случае указания
  соответствующих параметров.

  Параметры:
  sourceString                - исходная строка
  addonInChar                 - строка исходных символов для дополнительной
                                трансляции
  addonOutChar                - строка результирующих символов для
                                дополнительной трансляции

  Возврат:
  - нормализованная строка
*/
function formatString(
  sourceString varchar2
  , addonInChar varchar2
  , addonOutChar varchar2
)
return varchar2
is

--formatString
begin
  return
    replace( replace( trim( translate(
      sourceString
      , String_InChar || addonInChar
      , String_OutChar || addonOutChar
    )), '   ', ' '), '  ', ' ')
  ;
end formatString;

/* ifunc: formatStringExpr( INTERNAL)
  Возвращает выражение для нормализации строки.
  Предназначено для использования в динамическом SQL ( например, через
  execute immeaidiate), нормализация идентична выполняемой в функции
  <formatString( INTERNAL)>.

  Параметры:
  varName                     - имя переменной с исходной строкой
  addonInChar                 - строка исходных символов для дополнительной
                                трансляции
  addonOutChar                - строка результирующих символов для
                                дополнительной трансляции

  Возврат:
  - строка с SQL-выражением над переменной varName для выполнения нормализации
*/
function formatStringExpr(
  varName varchar2
  , addonInChar varchar2
  , addonOutChar varchar2
)
return varchar2
is
--formatStringExpr
begin
  return
    'replace( replace( trim( translate( '
    || varName
    || ', ''' || String_InChar || addonInChar || ''''
    || ', ''' || String_OutChar || addonOutChar || ''''
    || ')), ''   '', '' ''), ''  '', '' '')'
  ;
end formatStringExpr;

/* func: formatString
  Возвращает нормализованную строку.

  Нормализация:
  - символ табуляции заменяется на пробел;
  - обрезаются начальные и конечные пробелы;
  - несколько идущих подряд пробелов ( от 2 до 4) внутри строки заменяются на
    один пробел;

  Параметры:
  sourceString                - исходная строка

  Возврат:
  - нормализованная строка
*/
function formatString(
  sourceString varchar2
)
return varchar2
is

--formatString
begin
  return
    formatString(
      sourceString    => sourceString
      , addonInChar   => null
      , addonOutChar  => null
    )
  ;
end formatString;

/* func: formatStringExpr
  Возвращает выражение для нормализации строки.
  Предназначено для использования в динамическом SQL ( например, через
  execute immediate), нормализация идентична выполняемой в функции
  <formatString>.

  Параметры:
  varName                     - имя переменной с исходной строкой
                                дополнительной трансляции

  Возврат:
  - строка с SQL-выражением над переменной varName для выполнения нормализации
*/
function formatStringExpr(
  varName varchar2
)
return varchar2
is
--formatStringExpr
begin
  return
    formatStringExpr(
      varName         => varName
      , addonInChar   => null
      , addonOutChar  => null
    )
  ;
end formatStringExpr;

/* func: formatCyrillicString
  Возвращает нормализованную строку с кириллицей.

  Дополнительно к нормализации, выполняемой функцией <formatString>,
  производится:
  - заменой сходных по написанию латинских символов на кириллические;
  - замена буквы "ё" на букву "е";

  Параметры:
  sourceString                - исходная строка

  Возврат:
  - нормализованная строка
*/
function formatCyrillicString(
  sourceString varchar2
)
return varchar2
is

--formatCyrillicString
begin
  return
    formatString(
      sourceString    => sourceString
      , addonInChar   => CyrillicString_InChar
      , addonOutChar  => CyrillicString_OutChar
    )
  ;
end formatCyrillicString;

/* func: formatCyrillicStringExpr
  Возвращает выражение для нормализации строки с кириллицей.
  Предназначено для использования в динамическом SQL ( например, через
  execute immediate), нормализация идентична выполняемой в функции
  <formatCyrillicString>.

  Параметры:
  varName                     - имя переменной с исходной строкой
                                дополнительной трансляции

  Возврат:
  - строка с SQL-выражением над переменной varName для выполнения нормализации
*/
function formatCyrillicStringExpr(
  varName varchar2
)
return varchar2
is
--formatCyrillicStringExpr
begin
  return
    formatStringExpr(
      varName         => varName
      , addonInChar   => CyrillicString_InChar
      , addonOutChar  => CyrillicString_OutChar
    )
  ;
end formatCyrillicStringExpr;

/* func: formatName
  Возвращает нормализованное название.

  Дополнительно к нормализации, выполняемой функцией <formatCyrillicString>,
  производится:
  - установка регистра символов ( первая буква слова заглавная, остальные
    строчные);

  Параметры:
  sourceString                - исходная строка с названием

  Возврат:
  - нормализованное имя
*/
function formatName(
  sourceString varchar2
)
return varchar2
is
--formatName
begin
  return
    initcap( formatCyrillicString( sourceString))
  ;
end formatName;

/* func: formatNameExpr
  Возвращает выражение для нормализации названия.
  Предназначено для использования в динамическом SQL ( например, через
  execute immediate), нормализация идентична выполняемой в функции
  <formatName>.

  Параметры:
  varName                     - имя переменной с исходной строкой

  Возврат:
  - строка с SQL-выражением над переменной varName для выполнения нормализации
*/
function formatNameExpr(
  varName varchar2
)
return varchar2
is
--formatNameExpr
begin
  return
    'initcap( ' || formatCyrillicStringExpr( varName) || ')'
  ;
end formatNameExpr;



/* group: Базовая форма */

/* ifunc: findBaseName
  Ищет базовое значение по синониму.
  Синонимы берутся из таблицы <fd_alias> ( кэшируются при первом обращении).

  Переметры:
  aliasName                   - синоним
  aliasTypeCode               - код типа синонима

  Возврат:
  - базовое значение или null, если не найдено

  Замечания:
  - для корректной работы aliasName должна передаваться в нормализованном
    виде ( в котором заполняется поле alias_name в таблице <fd_alias>);
*/
function findBaseName(
  aliasName varchar2
  , aliasTypeCode varchar2
)
return varchar2
is



  function getKey(
    aliasTypeCode varchar2
    , aliasName varchar2
  )
  return varchar2
  is
  --Возвращает ключ поиска в кэше синонимов.
  begin
    return aliasTypeCode || ':' || aliasName;
  end getKey;



  procedure LoadAlias
  is
  --Загружает синонимы в кэш.

    cursor curAliasData is
      select
        a.alias_type_code
        , a.alias_name
        , a.base_name
      from
        fd_alias a
    ;

    type TColAliasData is table of curAliasData%rowtype;
    colAliasData TColAliasData;

  --LoadAlias
  begin
    open curAliasData;
    fetch curAliasData bulk collect into colAliasData;
    close curAliasData;
    if colAliasData.count > 0 then
      for i in colAliasData.first .. colAliasData.last loop
        colAlias( getKey(
              aliasTypeCode => colAliasData( i).alias_type_code
              , aliasName => colAliasData( i).alias_name
            )
          )
          := colAliasData( i).base_name
        ;
      end loop;
    end if;
  end LoadAlias;



--findBaseName
begin
                                        --Загружаем синонимы в кэш если пустой
  if colAlias.count = 0 then
    LoadAlias;
  end if;
                                        --Поиск и замена синонима
  if aliasName is not null
      and colAlias.exists( getKey( aliasTypeCode, aliasName))
      then
    return colAlias( getKey( aliasTypeCode, aliasName));
  else
    return null;
  end if;
end findBaseName;

/* ifunc: findBaseNameExpr
  Возвращает выражение для получения базового значения кода.
  Предназначено для использования в динамическом SQL ( например, через
  execute immediate), результат аналогичен получаемому в функции
  <findBaseName>.

  Параметры:
  varName                     - имя переменной с исходным синонимом
  aliasTypeCode               - код типа синонима

  Возврат:
  - строка с SQL-выражением над переменной varName

  Замечания:
  - для корректной работы значение в varName должно быть в нормализованном
    виде ( в котором заполняется поле alias_name в таблице <fd_alias>);
*/
function findBaseNameExpr(
  varName varchar2
  , aliasTypeCode varchar2
)
return varchar2
is
--findBaseNameExpr
begin
  return
    '( select al.base_name from '
      || case aliasTypeCode
          when pkg_FormatBase.FirstName_AliasTypeCode then
            'v_fd_first_name_alias'
          when pkg_FormatBase.MiddleName_AliasTypeCode then
            'v_fd_middle_name_alias'
          when pkg_FormatBase.NoValue_AliasTypeCode then
            'v_fd_no_value_alias'
        end
      || ' al'
    || ' where al.alias_name=' || varName
    || ')'
  ;
end findBaseNameExpr;

/* ifunc: replaceAlias
  Заменяет синоним на базовое значение.
  Синонимы берутся из таблицы <fd_alias> ( кэшируются при первом обращении).

  Переметры:
  nameString                  - строка с именем
  aliasTypeCode               - код типа синонима

  Возврат:
  - базовое значение, если исходная строка являлась синонимом, иначе исходная
    строка без изменений;

  Замечания:
  - для корректной работы nameString должна передаваться в нормализованном
    виде ( в котором заполняется поле alias_name в таблице <fd_alias>);
*/
function replaceAlias(
  nameString varchar2
  , aliasTypeCode varchar2
)
return varchar2
is
begin
  return
    coalesce(
      findBaseName( nameString, aliasTypeCode)
      , nameString
    )
  ;
end replaceAlias;

/* ifunc: replaceAliasExpr
  Возвращает выражение для замены синонима на базовое значение.
  Предназначено для использования в динамическом SQL ( например, через
  execute immediate), результат аналогичен получаемому в функции
  <replaceAlias>.

  Параметры:
  varName                     - имя переменной с исходным синонимом
  aliasTypeCode               - код типа синонима

  Возврат:
  - строка с SQL-выражением над переменной varName

  Замечания:
  - для корректной работы значение в varName должно быть в нормализованном
    виде ( в котором заполняется поле alias_name в таблице <fd_alias>);
*/
function replaceAliasExpr(
  varName varchar2
  , aliasTypeCode varchar2
)
return varchar2
is
--replaceAliasExpr
begin
  return
    'coalesce( '
      || findBaseNameExpr( varName, aliasTypeCode)
      || ', ' || varName
    || ')'
  ;
end replaceAliasExpr;

/* func: getBaseCode
  Возвращает базовое значение кода.

  Нормализация:
  - удаляются символы пробела, табуляции, тире, звездочка ( "*");
  - выполняется преобразование схожих по написанию символов кириллицы в
    латиницу;
  - буква "З" заменяется на цифру 3, буква "Йй" на "Ии";
  - обрезаются все ведущие/завершающие символы точка, запятая, подчеркивание,
    равенство;
  - символы переводятся в верхний регистр;
  - выполняется замена значения "-", а также синонимов отсутствующего значения
    из <fd_alias>, на null;
  - если задан minLength и длина кода меньше minLength, то он считается
    некорректным и устанавливается значение null;

  Параметры:
  sourceCode                  - исходный код
  minLength                   - минимальная длина кода ( если длина кода меньше,
                                то он считается некорректным и заменяется на
                                null, по умолчанию без ограничения)

  Возврат:
  - базовое значение кода
*/
function getBaseCode(
  sourceCode varchar2
  , minLength integer := null
)
return varchar2
is

--getBaseCode
begin
  return
    case when minLength > 1
      and length(
          rtrim(
            ltrim(
              translate(
                sourceCode
                , BaseCode_InChar
                , BaseCode_OutChar
              )
              , Code_TrimChar
            )
            , Code_TrimChar
          )
        ) < minLength
    then
      null
    else
      nullif(
        upper(
          rtrim(
            ltrim(
              translate(
                coalesce(
                  findBaseName(
                    formatName( sourceCode)
                    , pkg_FormatBase.NoValue_AliasTypeCode
                  )
                  , sourceCode
                )
                , BaseCode_InChar
                , BaseCode_OutChar
              )
              , Code_TrimChar
            )
            , Code_TrimChar
          )
        )
        , pkg_FormatBase.Zero_Value
      )
    end
  ;
end getBaseCode;

/* func: getBaseCodeExpr
  Возвращает выражение для получения базового значения кода.
  Предназначено для использования в динамическом SQL ( например, через
  execute immediate), нормализация аналогична выполняемой в функции
  <getBaseCode>.

  Параметры:
  varName                     - имя переменной с исходным кодом
  minLength                   - минимальная длина кода ( если длина кода меньше,
                                то он считается некорректным и заменяется на
                                null, по умолчанию без ограничения)

  Возврат:
  - строка с SQL-выражением над переменной varName для выполнения нормализации
*/
function getBaseCodeExpr(
  varName varchar2
  , minLength integer := null
)
return varchar2
is
--getBaseCodeExpr
begin
  return
    case when minLength > 1 then
      'case when length( '
          || 'rtrim( '
            || 'ltrim( '
              || 'translate( '
                || varName
                || ', ''' || BaseCode_InChar || ''''
                || ', ''' || BaseCode_OutChar || ''''
              || ')'
              || ', ''' || Code_TrimChar || ''''
            || ')'
            || ', ''' || Code_TrimChar || ''''
          || ')'
        || ') < ' || to_char( minLength)
      || ' then null else '
    end
    || 'nullif( '
        || 'upper( '
          || 'rtrim( '
            || 'ltrim( '
              || 'translate( '
                || 'coalesce( '
                  || findBaseNameExpr(
                      formatNameExpr( varName)
                      , pkg_FormatBase.NoValue_AliasTypeCode
                    )
                  || ', ' || varName
                || ')'
                || ', ''' || BaseCode_InChar || ''''
                || ', ''' || BaseCode_OutChar || ''''
              || ')'
              || ', ''' || Code_TrimChar || ''''
            || ')'
            || ', ''' || Code_TrimChar || ''''
          || ')'
        || ')'
      || ', ''' || pkg_FormatBase.Zero_Value || ''''
      || ')'
    || case when minLength > 1 then
      ' end'
      end
  ;
end getBaseCodeExpr;

/* func: getBaseName
  Возвращает базовую форму названия для использования при сравнении.

  Дополнительно к преобразованиям, выполняемым функцией <formatName>,
  производится:
  - замена синонимов отсутствующего значения из <fd_alias>, на null;
  - замена буквы "й" на "и";
  - обрезаются все ведущие/завершающие символы точка, запятая, подчеркивание,
    равенство, тире;

  Параметры:
  sourceName                  - исходная строка с названием

  Возврат:
  - базовая форма названия
*/
function getBaseName(
  sourceName varchar2
)
return varchar2
is
begin
                                        --Zero_Value преобразуется в null за
                                        --счет обрезания BaseName_TrimChar,
                                        --в который оно включено
  return
    rtrim(
      ltrim(
        translate(
          replaceAlias(
            formatName( sourceName)
            , pkg_FormatBase.NoValue_AliasTypeCode
          )
          , BaseName_InChar
          , BaseName_OutChar
        )
        , BaseName_TrimChar
      )
      , BaseName_TrimChar
    )
  ;
end getBaseName;

/* func: getBaseNameExpr
  Возвращает выражение для получения базового значения названия.
  Предназначено для использования в динамическом SQL ( например, через
  execute immediate), нормализация аналогична выполняемой в функции
  <getBaseName>.

  Параметры:
  varName                     - имя переменной с исходным значением

  Возврат:
  - строка с SQL-выражением над переменной varName для выполнения нормализации
*/
function getBaseNameExpr(
  varName varchar2
)
return varchar2
is
--getBaseStringExpr
begin
  return
       'rtrim( '
      || 'ltrim( '
        || 'translate( '
          || replaceAliasExpr(
              formatNameExpr( varName)
              , pkg_FormatBase.NoValue_AliasTypeCode
            )
          || ', ''' || BaseName_InChar || ''''
          || ', ''' || BaseName_OutChar || ''''
        || ')'
        || ', ''' || BaseName_TrimChar || ''''
      || ')'
      || ', ''' || BaseName_TrimChar || ''''
    || ')'
  ;
end getBaseNameExpr;

/* func: getBaseLastName
  Возвращает базовую форму фамилии для использования при сравнении.

  Дополнительно к преобразованиям, выполняемым функцией <formatName>,
  производится замена буквы "й" на "и".

  Параметры:
  lastName                    - исходная строка с фамилией

  Возврат:
  - базовая форма фамилии
*/
function getBaseLastName(
  lastName varchar2
)
return varchar2
is
--getBaseLastName
begin
  return
    translate(
      formatName( lastName)
      , BaseName_InChar
      , BaseName_OutChar
    )
  ;
end getBaseLastName;

/* func: getBaseLastNameExpr
  Возвращает выражение для получения базового значения фамилии.
  Предназначено для использования в динамическом SQL ( например, через
  execute immediate), нормализация аналогична выполняемой в функции
  <getBaseLastName>.

  Параметры:
  varName                     - имя переменной с исходным значением

  Возврат:
  - строка с SQL-выражением над переменной varName для выполнения нормализации
*/
function getBaseLastNameExpr(
  varName varchar2
)
return varchar2
is
--getBaseLastNameExpr
begin
  return
    'translate( '
    || formatNameExpr( varName)
    || ', ''' || BaseName_InChar || ''''
    || ', ''' || BaseName_OutChar || ''''
    || ')'
  ;
end getBaseLastNameExpr;

/* func: getBaseFirstName
  Возвращает базовую форму имени для использования при сравнении.

  Аналогично функции <getBaseLastName> с дополнительной заменой синонимов имени
  на базовую форму.

  Параметры:
  firstName                - исходная строка с именем

  Возврат:
  - базовая форма имени
*/
function getBaseFirstName(
  firstName varchar2
)
return varchar2
is
begin
  return
    translate(
      replaceAlias(
        formatName( firstName)
        , pkg_FormatBase.FirstName_AliasTypeCode
      )
      , BaseName_InChar
      , BaseName_OutChar
    )
  ;
end getBaseFirstName;

/* func: getBaseFirstNameExpr
  Возвращает выражение для получения базового значения имени.
  Предназначено для использования в динамическом SQL ( например, через
  execute immediate), нормализация аналогична выполняемой в функции
  <getBaseFirstName>.

  Параметры:
  varName                     - имя переменной с исходным значением

  Возврат:
  - строка с SQL-выражением над переменной varName для выполнения нормализации
*/
function getBaseFirstNameExpr(
  varName varchar2
)
return varchar2
is
--getBaseFirstNameExpr
begin
  return
    'translate( '
      || replaceAliasExpr(
          formatNameExpr( varName)
          , pkg_FormatBase.FirstName_AliasTypeCode
        )
      || ', ''' || BaseName_InChar || ''''
      || ', ''' || BaseName_OutChar || ''''
    || ')'
  ;
end getBaseFirstNameExpr;

/* func: getBaseMiddleName
  Возвращает базовую форму отчества для использования при сравнении.

  Аналогично функции <getBaseLastName> с дополнительной заменой синонимов
  отчества на базовую форму и возврата '-' ( <getZeroValue>) вместо null.

  Параметры:
  middleName                  - исходная строка с отчеством

  Возврат:
  - базовая форма отчества
*/
function getBaseMiddleName(
  middleName varchar2
)
return varchar2
is
begin
  return
    coalesce(
      translate(
        replaceAlias(
          formatName( middleName)
          , pkg_FormatBase.MiddleName_AliasTypeCode
        )
        , BaseName_InChar
        , BaseName_OutChar
      )
      , pkg_FormatBase.Zero_Value
    )
  ;
end getBaseMiddleName;

/* func: getBaseMiddleNameExpr
  Возвращает выражение для получения базового значения отчества.
  Предназначено для использования в динамическом SQL ( например, через
  execute immediate), нормализация аналогична выполняемой в функции
  <getBaseMiddleName>.

  Параметры:
  varName                     - имя переменной с исходным значением

  Возврат:
  - строка с SQL-выражением над переменной varName для выполнения нормализации
*/
function getBaseMiddleNameExpr(
  varName varchar2
)
return varchar2
is
--getBaseMiddleNameExpr
begin
  return
    'coalesce( '
      || 'translate( '
        || replaceAliasExpr(
            formatNameExpr( varName)
            , pkg_FormatBase.MiddleName_AliasTypeCode
          )
        || ', ''' || BaseName_InChar || ''''
        || ', ''' || BaseName_OutChar || ''''
      || ')'
    || ', ''' || pkg_FormatBase.Zero_Value || ''''
    || ')'
  ;
end getBaseMiddleNameExpr;



/* group: Проверка корректности */

/* func: checkDrivingLicense
  Проверяет корректность номера водительского удостоверения.

  Условие корректности: соответствует шаблону "99ЯЯ999999" ( где "9" любая
  цифра от 0 до 9, "Я" любая кириллическая буква).

  Параметры:
  sourceCode                  - номер документа ( все незначащие символы должны
                                быть предварительно удалены)

  Возврат:
  1     - корректный номер
  0     - некорректный номер
  null  - значение отсутствует ( если в качестве параметра был передан null)
*/
function checkDrivingLicense(
  sourceCode varchar2
)
return integer
is
begin
  return
case
  when
      translate(
        upper( sourceCode)
        , '0123456789' || UpperCyrillic_Char
        , '9999999999' || rpad( 'Я', UpperCyrillic_CharLength, 'Я')
      )
      = '99ЯЯ999999'
    then 1
  when
      sourceCode is not null
    then 0
end
  ;
end checkDrivingLicense;

/* func: checkDrivingLicenseExpr
  Возвращает выражение для проверки корректности номера водительского
  удостоверения, результат вычисления которого идентичен вызову функции
  <checkDrivingLicense>.

  Параметры:
  varName                     - имя переменной с номером документа

  Возврат:
  строка с SQL-выражением над переменной varName для выполнения проверки.
*/
function checkDrivingLicenseExpr(
  varName varchar2
)
return varchar2
is
begin
  return
    replace( replace( replace( replace( replace(
'case
  when
      translate(
        upper( sourceCode)
        , ''0123456789' || UpperCyrillic_Char || '''
        , ''9999999999' || rpad( 'Я', UpperCyrillic_CharLength, 'Я') || '''
      )
      = ''99ЯЯ999999''
    then 1
  when
      sourceCode is not null
    then 0
end'
      -- удаляем лишние пробелы, чтобы сократить длину
      , '     ', ' ')
      , '   '  , ' ')
      , '  '   , ' ')
      , chr(10) || ' ' , chr(10))
      -- подставляем имя переменой
      ,  'sourceCode', varName)
  ;
end checkDrivingLicenseExpr;

/* func: checkForeignPassport
  Проверяет корректность номера заграничного паспорта.

  Условие корректности: соответствует шаблону "999999999" ( девять цифр от
  0 до 9).

  Параметры:
  sourceCode                  - номер документа ( все незначащие символы должны
                                быть предварительно удалены)

  Возврат:
  1     - корректный номер
  0     - некорректный номер
  null  - значение отсутствует ( если в качестве параметра был передан null)
*/
function checkForeignPassport(
  sourceCode varchar2
)
return integer
is
begin
  return
case
  when
      translate(
        sourceCode
        , '0123456789'
        , '9999999999'
      )
      = '999999999'
    then 1
  when
      sourceCode is not null
    then 0
end
  ;
end checkForeignPassport;

/* func: checkForeignPassportExpr
  Возвращает выражение для проверки корректности номера заграничного паспорта,
  результат вычисления которого идентичен вызову функции
  <checkForeignPassport>.

  Параметры:
  varName                     - имя переменной с номером документа

  Возврат:
  строка с SQL-выражением над переменной varName для выполнения проверки.
*/
function checkForeignPassportExpr(
  varName varchar2
)
return varchar2
is
begin
  return
    replace( replace( replace( replace( replace(
'case
  when
      translate(
        sourceCode
        , ''0123456789''
        , ''9999999999''
      )
      = ''999999999''
    then 1
  when
      sourceCode is not null
    then 0
end'
      -- удаляем лишние пробелы, чтобы сократить длину
      , '     ', ' ')
      , '   '  , ' ')
      , '  '   , ' ')
      , chr(10) || ' ' , chr(10))
      -- подставляем имя переменой
      ,  'sourceCode', varName)
  ;
end checkForeignPassportExpr;

/* func: checkInn
  Проверяет корректность ИНН ( идентификационного номера налогоплательщика)
  с помощью проверки контрольных сумм номера.

  Параметры:
  sourceCode                  - ИНН ( все незначащие символы должны быть
                                предварительно удалены)

  Возврат:
  1     - корректный номер
  0     - некорректный номер
  null  - значение отсутствует ( если в качестве параметра был передан null)
*/
function checkInn(
  sourceCode varchar2
)
return integer
is
begin
  return
case
  when
    translate( sourceCode, '.0123456789', '.') is null
    and (
      length( sourceCode) = 12
        and mod( mod(
              to_number( substr( sourceCode, 1, 1)) *  7
            + to_number( substr( sourceCode, 2, 1)) *  2
            + to_number( substr( sourceCode, 3, 1)) *  4
            + to_number( substr( sourceCode, 4, 1)) * 10
            + to_number( substr( sourceCode, 5, 1)) *  3
            + to_number( substr( sourceCode, 6, 1)) *  5
            + to_number( substr( sourceCode, 7, 1)) *  9
            + to_number( substr( sourceCode, 8, 1)) *  4
            + to_number( substr( sourceCode, 9, 1)) *  6
            + to_number( substr( sourceCode,10, 1)) *  8
            , 11), 10)
          = to_number( substr( sourceCode, 11, 1))
        and mod( mod(
              to_number( substr( sourceCode, 1, 1)) *  3
            + to_number( substr( sourceCode, 2, 1)) *  7
            + to_number( substr( sourceCode, 3, 1)) *  2
            + to_number( substr( sourceCode, 4, 1)) *  4
            + to_number( substr( sourceCode, 5, 1)) * 10
            + to_number( substr( sourceCode, 6, 1)) *  3
            + to_number( substr( sourceCode, 7, 1)) *  5
            + to_number( substr( sourceCode, 8, 1)) *  9
            + to_number( substr( sourceCode, 9, 1)) *  4
            + to_number( substr( sourceCode,10, 1)) *  6
            + to_number( substr( sourceCode,11, 1)) *  8
            , 11), 10)
          = to_number( substr( sourceCode, 12, 1))
      or length( sourceCode) = 10
        and mod( mod(
              to_number( substr( sourceCode, 1, 1)) *  2
            + to_number( substr( sourceCode, 2, 1)) *  4
            + to_number( substr( sourceCode, 3, 1)) * 10
            + to_number( substr( sourceCode, 4, 1)) *  3
            + to_number( substr( sourceCode, 5, 1)) *  5
            + to_number( substr( sourceCode, 6, 1)) *  9
            + to_number( substr( sourceCode, 7, 1)) *  4
            + to_number( substr( sourceCode, 8, 1)) *  6
            + to_number( substr( sourceCode, 9, 1)) *  8
            , 11), 10)
          = to_number( substr( sourceCode, 10, 1))
      )
    then 1
  when
    sourceCode is not null
    then 0
end
  ;
end checkInn;

/* func: checkInnExpr
  Возвращает выражение для проверки корректности ИНН ( идентификационного
  номера налогоплательщика), результат вычисления которого идентичен вызову
  функции <checkInn>.

  Параметры:
  varName                     - имя переменной со значением ИНН

  Возврат:
  строка с SQL-выражением над переменной varName для выполнения проверки
*/
function checkInnExpr(
  varName varchar2
)
return varchar2
is
begin
  return
    replace( replace( replace( replace( replace(
'case
  when
    translate( sourceCode, ''.0123456789'', ''.'') is null
    and (
      length( sourceCode) = 12
        and mod( mod(
              to_number( substr( sourceCode, 1, 1)) *  7
            + to_number( substr( sourceCode, 2, 1)) *  2
            + to_number( substr( sourceCode, 3, 1)) *  4
            + to_number( substr( sourceCode, 4, 1)) * 10
            + to_number( substr( sourceCode, 5, 1)) *  3
            + to_number( substr( sourceCode, 6, 1)) *  5
            + to_number( substr( sourceCode, 7, 1)) *  9
            + to_number( substr( sourceCode, 8, 1)) *  4
            + to_number( substr( sourceCode, 9, 1)) *  6
            + to_number( substr( sourceCode,10, 1)) *  8
            , 11), 10)
          = to_number( substr( sourceCode, 11, 1))
        and mod( mod(
              to_number( substr( sourceCode, 1, 1)) *  3
            + to_number( substr( sourceCode, 2, 1)) *  7
            + to_number( substr( sourceCode, 3, 1)) *  2
            + to_number( substr( sourceCode, 4, 1)) *  4
            + to_number( substr( sourceCode, 5, 1)) * 10
            + to_number( substr( sourceCode, 6, 1)) *  3
            + to_number( substr( sourceCode, 7, 1)) *  5
            + to_number( substr( sourceCode, 8, 1)) *  9
            + to_number( substr( sourceCode, 9, 1)) *  4
            + to_number( substr( sourceCode,10, 1)) *  6
            + to_number( substr( sourceCode,11, 1)) *  8
            , 11), 10)
          = to_number( substr( sourceCode, 12, 1))
      or length( sourceCode) = 10
        and mod( mod(
              to_number( substr( sourceCode, 1, 1)) *  2
            + to_number( substr( sourceCode, 2, 1)) *  4
            + to_number( substr( sourceCode, 3, 1)) * 10
            + to_number( substr( sourceCode, 4, 1)) *  3
            + to_number( substr( sourceCode, 5, 1)) *  5
            + to_number( substr( sourceCode, 6, 1)) *  9
            + to_number( substr( sourceCode, 7, 1)) *  4
            + to_number( substr( sourceCode, 8, 1)) *  6
            + to_number( substr( sourceCode, 9, 1)) *  8
            , 11), 10)
          = to_number( substr( sourceCode, 10, 1))
      )
    then 1
  when
    sourceCode is not null
    then 0
end'
      -- удаляем лишние пробелы, чтобы сократить длину
      , '     ', ' ')
      , '   '  , ' ')
      , '  '   , ' ')
      , chr(10) || ' ' , chr(10))
      -- подставляем имя переменой
      ,  'sourceCode', varName)
  ;
end checkInnExpr;

/* func: checkPensionFundNumber
  Проверяет корректность номера пенсионного свидетельства с помощью проверки
  контрольных сумм номера.

  Параметры:
  sourceCode                  - номера пенсионного свидетельства ( все
                                незначащие символы должны быть предварительно
                                удалены)

  Возврат:
  1     - корректный номер
  0     - некорректный номер
  null  - значение отсутствует ( если в качестве параметра был передан null)
*/
function checkPensionFundNumber(
  sourceCode varchar2
)
return integer
is
begin
  return
case
  when
    length( sourceCode) = 11
    and translate( sourceCode, '.0123456789', '.') is null
    and mod( mod(
          to_number( substr( sourceCode, 1, 1)) * 9
        + to_number( substr( sourceCode, 2, 1)) * 8
        + to_number( substr( sourceCode, 3, 1)) * 7
        + to_number( substr( sourceCode, 4, 1)) * 6
        + to_number( substr( sourceCode, 5, 1)) * 5
        + to_number( substr( sourceCode, 6, 1)) * 4
        + to_number( substr( sourceCode, 7, 1)) * 3
        + to_number( substr( sourceCode, 8, 1)) * 2
        + to_number( substr( sourceCode, 9, 1)) * 1
        , 101), 100)
      = to_number( substr( sourceCode, 10, 2))
    then 1
  when
    sourceCode is not null
    then 0
end
  ;
end checkPensionFundNumber;

/* func: checkPensionFundNumberExpr
  Возвращает выражение для проверки корректности номера пенсионного
  свидетельства, результат вычисления которого идентичен вызову функции
  <checkPensionFundNumber>.

  Параметры:
  varName                     - имя переменной с номером пенсионного
                                свидетельства

  Возврат:
  строка с SQL-выражением над переменной varName для выполнения проверки
*/
function checkPensionFundNumberExpr(
  varName varchar2
)
return varchar2
is
begin
  return
    replace( replace( replace( replace( replace(
'case
  when
    length( sourceCode) = 11
    and translate( sourceCode, ''.0123456789'', ''.'') is null
    and mod( mod(
          to_number( substr( sourceCode, 1, 1)) * 9
        + to_number( substr( sourceCode, 2, 1)) * 8
        + to_number( substr( sourceCode, 3, 1)) * 7
        + to_number( substr( sourceCode, 4, 1)) * 6
        + to_number( substr( sourceCode, 5, 1)) * 5
        + to_number( substr( sourceCode, 6, 1)) * 4
        + to_number( substr( sourceCode, 7, 1)) * 3
        + to_number( substr( sourceCode, 8, 1)) * 2
        + to_number( substr( sourceCode, 9, 1)) * 1
        , 101), 100)
      = to_number( substr( sourceCode, 10, 2))
    then 1
  when
    sourceCode is not null
    then 0
end'
      -- удаляем лишние пробелы, чтобы сократить длину
      , '     ', ' ')
      , '   '  , ' ')
      , '  '   , ' ')
      , chr(10) || ' ' , chr(10))
      -- подставляем имя переменой
      ,  'sourceCode', varName)
  ;
end checkPensionFundNumberExpr;

/* func: checkPts
  Проверяет корректность серии и номера ПТС ( паспорта транспортного средства).

  Условие корректности: соответствует шаблону "99CC999999" ( где "9" любая
  цифра от 0 до 9, "C" любая буква ( по умолчанию только кириллица, см.
  параметры ниже)).

  Параметры:
  sourceCode                  - серия и номер документа ( все незначащие
                                символы должны быть предварительно удалены)
  isUseCyrillic               - в шаблоне в позициях "С" может использоваться
                                кириллица
                                ( 1 да ( по умолчанию), 0 нет)
  isUseLatin                  - в шаблоне в позициях "С" может использоваться
                                латиница
                                ( 1 да, 0 нет ( по умолчанию))

  Возврат:
  1     - корректное значение
  0     - некорректное значение
  null  - значение отсутствует ( если в качестве параметра был передан null)
*/
function checkPts(
  sourceCode varchar2
  , isUseCyrillic integer := null
  , isUseLatin integer := null
)
return integer
is

  -- Параметры трансляции нецифровых символов
  inChar varchar2(100);
  outChar varchar2(100);
  charPattern varchar2(10);

begin

  if coalesce( isUseCyrillic != 0, true) then
    charPattern := 'ЯЯ';
    inChar := UpperCyrillic_Char;
    outChar := rpad( charPattern, UpperCyrillic_CharLength, charPattern);
  end if;

  if isUseLatin = 1 then
    if charPattern is null then
      charPattern := 'ZZ';
    end if;
    inChar := inChar || UpperLatin_Char;
    outChar :=
      outChar || rpad( charPattern, UpperLatin_CharLength, charPattern)
    ;
  end if;

  if charPattern is null then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Не указан допустимый алфавит для букв.'
    );
  end if;

  return
case
  when
      translate(
        upper( sourceCode)
        , '0123456789' || inChar
        , '9999999999' || outChar
      )
      = '99' || charPattern || '999999'
    then 1
  when
      sourceCode is not null
    then 0
end
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при проверке серии и номера ПТС ('
        || ' sourceCode="' || sourceCode || '"'
        || ', isUseCyrillic=' || isUseCyrillic
        || ', isUseLatin=' || isUseLatin
        || ').'
      )
    , true
  );
end checkPts;

/* func: checkPtsExpr
  Возвращает выражение для проверки корректности серии и номера ПТС
  ( паспорта транспортного средства), результат вычисления которого идентичен
  вызову функции <checkPts>.

  Параметры:
  varName                     - имя переменной с номером документа
  isUseCyrillic               - в шаблоне в позициях "С" может использоваться
                                кириллица
                                ( 1 да ( по умолчанию), 0 нет)
  isUseLatin                  - в шаблоне в позициях "С" может использоваться
                                латиница
                                ( 1 да, 0 нет ( по умолчанию))

  Возврат:
  строка с SQL-выражением над переменной varName для выполнения проверки.
*/
function checkPtsExpr(
  varName varchar2
  , isUseCyrillic integer := null
  , isUseLatin integer := null
)
return varchar2
is

  -- Параметры трансляции нецифровых символов
  inChar varchar2(100);
  outChar varchar2(100);
  charPattern varchar2(10);

begin

  if coalesce( isUseCyrillic != 0, true) then
    charPattern := 'ЯЯ';
    inChar := UpperCyrillic_Char;
    outChar := rpad( charPattern, UpperCyrillic_CharLength, charPattern);
  end if;

  if isUseLatin = 1 then
    if charPattern is null then
      charPattern := 'ZZ';
    end if;
    inChar := inChar || UpperLatin_Char;
    outChar :=
      outChar || rpad( charPattern, UpperLatin_CharLength, charPattern)
    ;
  end if;

  if charPattern is null then
    raise_application_error(
      pkg_Error.IllegalArgument
      , 'Не указан допустимый алфавит для букв.'
    );
  end if;

  return
    replace( replace( replace( replace( replace(
'case
  when
      translate(
        upper( sourceCode)
        , ''0123456789' || inChar || '''
        , ''9999999999' || outChar || '''
      )
      = ''99' || charPattern || '999999''
    then 1
  when
      sourceCode is not null
    then 0
end'
      -- удаляем лишние пробелы, чтобы сократить длину
      , '     ', ' ')
      , '   '  , ' ')
      , '  '   , ' ')
      , chr(10) || ' ' , chr(10))
      -- подставляем имя переменой
      ,  'sourceCode', varName)
  ;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        'Ошибка при получении выражения для проверки серии и номера ПТС ('
        || ' varName="' || varName || '"'
        || ', isUseCyrillic=' || isUseCyrillic
        || ', isUseLatin=' || isUseLatin
        || ').'
      )
    , true
  );
end checkPtsExpr;

/* func: checkVin
  Проверяет корректность VIN ( идентификационного номера автомобиля).

  Условие корректности: длина равна 17 и используются только допустимые символы.

  Параметры:
  sourceCode                  - VIN ( все незначащие символы должны
                                быть предварительно удалены)

  Возврат:
  1     - корректный номер
  0     - некорректный номер
  null  - значение отсутствует ( если в качестве параметра был передан null)
*/
function checkVin(
  sourceCode varchar2
)
return integer
is
begin
  return
case
  when
      length( sourceCode) = Vin_Length
      and translate(
          sourceCode
          , '.' || Vin_Char
          , '.'
        )
        is null
    then 1
  when
      sourceCode is not null
    then 0
end
  ;
end checkVin;

/* func: checkVinExpr
  Возвращает выражение для проверки корректности VIN ( идентификационного
  номера автомобиля), результат вычисления которого идентичен вызову функции
  <checkVin>.

  Параметры:
  varName                     - имя переменной со значением VIN

  Возврат:
  строка с SQL-выражением над переменной varName для выполнения проверки.
*/
function checkVinExpr(
  varName varchar2
)
return varchar2
is
begin
  return
    replace( replace( replace( replace( replace(
'case
  when
      length( sourceCode) = ' || Vin_Length || '
      and translate(
          sourceCode
          , ''.' || Vin_Char || '''
          , ''.''
        )
        is null
    then 1
  when
      sourceCode is not null
    then 0
end'
      -- удаляем лишние пробелы, чтобы сократить длину
      , '     ', ' ')
      , '   '  , ' ')
      , '  '   , ' ')
      , chr(10) || ' ' , chr(10))
      -- подставляем имя переменой
      ,  'sourceCode', varName)
  ;
end checkVinExpr;

end pkg_FormatData;
/
