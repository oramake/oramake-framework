create or replace package pkg_FormatData is
/* package: pkg_FormatData
  Интерфейсный пакет модуля FormatData.

  SVN root: Oracle/Module/FormatData
*/



/* group: Функции */

/* pfunc: getZeroValue
  Возвращает строку, обозначающую отсутствие значения.

  Возврат: значение константы <pkg_FormatBase.Zero_Value>.

  ( <body::getZeroValue>)
*/
function getZeroValue
return varchar2;



/* group: Форматирование */

/* pfunc: formatCode
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

  ( <body::formatCode>)
*/
function formatCode(
  sourceCode varchar2
  , newLength integer := null
)
return varchar2;

/* pfunc: formatCodeExpr
  Возвращает выражение для нормализации кода.
  Предназначено для использования в динамическом SQL ( например, через
  execute immediate), нормализация идентична выполняемой в функции
  <formatCode>.

  Параметры:
  varName                     - имя переменной с исходным кодом
  newLength                   - требуемая длина кода

  Возврат:
  - строка с SQL-выражением над переменной varName для выполнения нормализации

  ( <body::formatCodeExpr>)
*/
function formatCodeExpr(
  varName varchar2
  , newLength integer := null
)
return varchar2;

/* pfunc: formatString
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

  ( <body::formatString>)
*/
function formatString(
  sourceString varchar2
)
return varchar2;

/* pfunc: formatStringExpr
  Возвращает выражение для нормализации строки.
  Предназначено для использования в динамическом SQL ( например, через
  execute immediate), нормализация идентична выполняемой в функции
  <formatString>.

  Параметры:
  varName                     - имя переменной с исходной строкой
                                дополнительной трансляции

  Возврат:
  - строка с SQL-выражением над переменной varName для выполнения нормализации

  ( <body::formatStringExpr>)
*/
function formatStringExpr(
  varName varchar2
)
return varchar2;

/* pfunc: formatCyrillicString
  Возвращает нормализованную строку с кириллицей.

  Дополнительно к нормализации, выполняемой функцией <formatString>,
  производится:
  - заменой сходных по написанию латинских символов на кириллические;
  - замена буквы "ё" на букву "е";

  Параметры:
  sourceString                - исходная строка

  Возврат:
  - нормализованная строка

  ( <body::formatCyrillicString>)
*/
function formatCyrillicString(
  sourceString varchar2
)
return varchar2;

/* pfunc: formatCyrillicStringExpr
  Возвращает выражение для нормализации строки с кириллицей.
  Предназначено для использования в динамическом SQL ( например, через
  execute immeaidiate), нормализация идентична выполняемой в функции
  <formatCyrillicString>.

  Параметры:
  varName                     - имя переменной с исходной строкой
                                дополнительной трансляции

  Возврат:
  - строка с SQL-выражением над переменной varName для выполнения нормализации

  ( <body::formatCyrillicStringExpr>)
*/
function formatCyrillicStringExpr(
  varName varchar2
)
return varchar2;

/* pfunc: formatName
  Возвращает нормализованное название.

  Дополнительно к нормализации, выполняемой функцией <formatCyrillicString>,
  производится:
  - установка регистра символов ( первая буква слова заглавная, остальные
    строчные);

  Параметры:
  sourceString                - исходная строка с названием

  Возврат:
  - нормализованное имя

  ( <body::formatName>)
*/
function formatName(
  sourceString varchar2
)
return varchar2;

/* pfunc: formatNameExpr
  Возвращает выражение для нормализации названия.
  Предназначено для использования в динамическом SQL ( например, через
  execute immeaidiate), нормализация идентична выполняемой в функции
  <formatName>.

  Параметры:
  varName                     - имя переменной с исходной строкой

  Возврат:
  - строка с SQL-выражением над переменной varName для выполнения нормализации

  ( <body::formatNameExpr>)
*/
function formatNameExpr(
  varName varchar2
)
return varchar2;



/* group: Базовая форма */

/* pfunc: getBaseCode
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

  ( <body::getBaseCode>)
*/
function getBaseCode(
  sourceCode varchar2
  , minLength integer := null
)
return varchar2;

/* pfunc: getBaseCodeExpr
  Возвращает выражение для получения базового значения кода.
  Предназначено для использования в динамическом SQL ( например, через
  execute immeaidiate), нормализация аналогична выполняемой в функции
  <getBaseCode>.

  Параметры:
  varName                     - имя переменной с исходным кодом
  minLength                   - минимальная длина кода ( если длина кода меньше,
                                то он считается некорректным и заменяется на
                                null, по умолчанию без ограничения)

  Возврат:
  - строка с SQL-выражением над переменной varName для выполнения нормализации

  ( <body::getBaseCodeExpr>)
*/
function getBaseCodeExpr(
  varName varchar2
  , minLength integer := null
)
return varchar2;

/* pfunc: getBaseName
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

  ( <body::getBaseName>)
*/
function getBaseName(
  sourceName varchar2
)
return varchar2;

/* pfunc: getBaseNameExpr
  Возвращает выражение для получения базового значения названия.
  Предназначено для использования в динамическом SQL ( например, через
  execute immeaidiate), нормализация аналогична выполняемой в функции
  <getBaseName>.

  Параметры:
  varName                     - имя переменной с исходным значением

  Возврат:
  - строка с SQL-выражением над переменной varName для выполнения нормализации

  ( <body::getBaseNameExpr>)
*/
function getBaseNameExpr(
  varName varchar2
)
return varchar2;

/* pfunc: getBaseLastName
  Возвращает базовую форму фамилии для использования при сравнении.

  Дополнительно к преобразованиям, выполняемым функцией <formatName>,
  производится замена буквы "й" на "и".

  Параметры:
  lastName                    - исходная строка с фамилией

  Возврат:
  - базовая форма фамилии

  ( <body::getBaseLastName>)
*/
function getBaseLastName(
  lastName varchar2
)
return varchar2;

/* pfunc: getBaseLastNameExpr
  Возвращает выражение для получения базового значения фамилии.
  Предназначено для использования в динамическом SQL ( например, через
  execute immeaidiate), нормализация аналогична выполняемой в функции
  <getBaseLastName>.

  Параметры:
  varName                     - имя переменной с исходным значением

  Возврат:
  - строка с SQL-выражением над переменной varName для выполнения нормализации

  ( <body::getBaseLastNameExpr>)
*/
function getBaseLastNameExpr(
  varName varchar2
)
return varchar2;

/* pfunc: getBaseFirstName
  Возвращает базовую форму имени для использования при сравнении.

  Аналогично функции <getBaseLastName> с дополнительной заменой синонимов имени
  на базовую форму.

  Параметры:
  firstName                - исходная строка с именем

  Возврат:
  - базовая форма имени

  ( <body::getBaseFirstName>)
*/
function getBaseFirstName(
  firstName varchar2
)
return varchar2;

/* pfunc: getBaseFirstNameExpr
  Возвращает выражение для получения базового значения имени.
  Предназначено для использования в динамическом SQL ( например, через
  execute immeaidiate), нормализация аналогична выполняемой в функции
  <getBaseFirstName>.

  Параметры:
  varName                     - имя переменной с исходным значением

  Возврат:
  - строка с SQL-выражением над переменной varName для выполнения нормализации

  ( <body::getBaseFirstNameExpr>)
*/
function getBaseFirstNameExpr(
  varName varchar2
)
return varchar2;

/* pfunc: getBaseMiddleName
  Возвращает базовую форму отчества для использования при сравнении.

  Аналогично функции <getBaseLastName> с дополнительной заменой синонимов
  отчества на базовую форму и возврата '-' ( <getZeroValue>) вместо null.

  Параметры:
  middleName                  - исходная строка с отчеством

  Возврат:
  - базовая форма отчества

  ( <body::getBaseMiddleName>)
*/
function getBaseMiddleName(
  middleName varchar2
)
return varchar2;

/* pfunc: getBaseMiddleNameExpr
  Возвращает выражение для получения базового значения отчества.
  Предназначено для использования в динамическом SQL ( например, через
  execute immeaidiate), нормализация аналогична выполняемой в функции
  <getBaseMiddleName>.

  Параметры:
  varName                     - имя переменной с исходным значением

  Возврат:
  - строка с SQL-выражением над переменной varName для выполнения нормализации

  ( <body::getBaseMiddleNameExpr>)
*/
function getBaseMiddleNameExpr(
  varName varchar2
)
return varchar2;



/* group: Проверка корректности */

/* pfunc: checkDrivingLicense
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

  ( <body::checkDrivingLicense>)
*/
function checkDrivingLicense(
  sourceCode varchar2
)
return integer;

/* pfunc: checkDrivingLicenseExpr
  Возвращает выражение для проверки корректности номера водительского
  удостоверения, результат вычисления которого идентичен вызову функции
  <checkDrivingLicense>.

  Параметры:
  varName                     - имя переменной с номером документа

  Возврат:
  строка с SQL-выражением над переменной varName для выполнения проверки.

  ( <body::checkDrivingLicenseExpr>)
*/
function checkDrivingLicenseExpr(
  varName varchar2
)
return varchar2;

/* pfunc: checkForeignPassport
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

  ( <body::checkForeignPassport>)
*/
function checkForeignPassport(
  sourceCode varchar2
)
return integer;

/* pfunc: checkForeignPassportExpr
  Возвращает выражение для проверки корректности номера заграничного паспорта,
  результат вычисления которого идентичен вызову функции
  <checkForeignPassport>.

  Параметры:
  varName                     - имя переменной с номером документа

  Возврат:
  строка с SQL-выражением над переменной varName для выполнения проверки.

  ( <body::checkForeignPassportExpr>)
*/
function checkForeignPassportExpr(
  varName varchar2
)
return varchar2;

/* pfunc: checkInn
  Проверяет корректность ИНН ( идентификационного номера налогоплательщика)
  с помощью проверки контрольных сумм номера.

  Параметры:
  sourceCode                  - ИНН ( все незначащие символы должны быть
                                предварительно удалены)

  Возврат:
  1     - корректный номер
  0     - некорректный номер
  null  - значение отсутствует ( если в качестве параметра был передан null)

  ( <body::checkInn>)
*/
function checkInn(
  sourceCode varchar2
)
return integer;

/* pfunc: checkInnExpr
  Возвращает выражение для проверки корректности ИНН ( идентификационного
  номера налогоплательщика), результат вычисления которого идентичен вызову
  функции <checkInn>.

  Параметры:
  varName                     - имя переменной со значением ИНН

  Возврат:
  строка с SQL-выражением над переменной varName для выполнения проверки

  ( <body::checkInnExpr>)
*/
function checkInnExpr(
  varName varchar2
)
return varchar2;

/* pfunc: checkPensionFundNumber
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

  ( <body::checkPensionFundNumber>)
*/
function checkPensionFundNumber(
  sourceCode varchar2
)
return integer;

/* pfunc: checkPensionFundNumberExpr
  Возвращает выражение для проверки корректности номера пенсионного
  свидетельства, результат вычисления которого идентичен вызову функции
  <checkPensionFundNumber>.

  Параметры:
  varName                     - имя переменной с номером пенсионного
                                свидетельства

  Возврат:
  строка с SQL-выражением над переменной varName для выполнения проверки

  ( <body::checkPensionFundNumberExpr>)
*/
function checkPensionFundNumberExpr(
  varName varchar2
)
return varchar2;

/* pfunc: checkPts
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

  ( <body::checkPts>)
*/
function checkPts(
  sourceCode varchar2
  , isUseCyrillic integer := null
  , isUseLatin integer := null
)
return integer;

/* pfunc: checkPtsExpr
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

  ( <body::checkPtsExpr>)
*/
function checkPtsExpr(
  varName varchar2
  , isUseCyrillic integer := null
  , isUseLatin integer := null
)
return varchar2;

/* pfunc: checkVin
  Проверяет корректность VIN ( идентификационного номера автомобиля).

  Условие корректности: длина равна 17 и используются только допустимые символы.

  Параметры:
  sourceCode                  - VIN ( все незначащие символы должны
                                быть предварительно удалены)

  Возврат:
  1     - корректный номер
  0     - некорректный номер
  null  - значение отсутствует ( если в качестве параметра был передан null)

  ( <body::checkVin>)
*/
function checkVin(
  sourceCode varchar2
)
return integer;

/* pfunc: checkVinExpr
  Возвращает выражение для проверки корректности VIN ( идентификационного
  номера автомобиля), результат вычисления которого идентичен вызову функции
  <checkVin>.

  Параметры:
  varName                     - имя переменной со значением VIN

  Возврат:
  строка с SQL-выражением над переменной varName для выполнения проверки.

  ( <body::checkVinExpr>)
*/
function checkVinExpr(
  varName varchar2
)
return varchar2;

end pkg_FormatData;
/
