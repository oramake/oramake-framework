create or replace package pkg_ConvertNameInCase is
/* package: pkg_ConvertNameInCase
  Интерфейсный пакет модуля ConvertNameInCase.
  Функции для работы со склонением ФИО по падежам.
*/



/* group: Константы */

/* const: Module_Name
  Название модуля, к которому относится пакет.
*/
Module_Name constant varchar2(30) := 'ConvertNameInCase';

/* const: LastName_TypeExceptionCode
  Код типа исключения "Фамилия".
*/
LastName_TypeExceptionCode constant varchar2(1) := 'L';

/* const: FirstName_TypeExceptionCode
  Код типа исключения "Имя".
*/
FirstName_TypeExceptionCode constant varchar2(1) := 'F';

/* const: MiddleName_TypeExceptionCode
  Код типа исключения "Отчество".
*/
MiddleName_TypeExceptionCode constant varchar2(1) := 'M';

/* const: Native_CaseCode
  Код именительного падежа.
*/
Native_CaseCode constant varchar2(10) := 'NAT';

/* const: Genetive_CaseCode
  Код родительного падежа.
*/
Genetive_CaseCode constant varchar2(10) := 'GEN';

/* const: Dative_CaseCode
  Код дательного падежа.
*/
Dative_CaseCode constant varchar2(10) := 'DAT';

/* const: Accusative_CaseCode
  Код винительного падежа.
*/
Accusative_CaseCode constant varchar2(10) := 'ACC';

/* const: Ablative_CaseCode
  Код творительного падежа.
*/
Ablative_CaseCode constant varchar2(10) := 'ABL';

/* const: Preposition_CaseCode
  Код предложного падежа.
*/
Preposition_CaseCode constant varchar2(10) := 'PREP';

/* const: Men_Code
  Код мужского пола.
*/
Men_SexCode constant varchar2(10) := 'M';

/* const: Women_Code
  Код женского пола.
*/
Women_SexCode constant varchar2(10) := 'W';



/* group: Функции */

/* pproc: updateExceptionCase
  Процедура добавления/обновления записи в справочнике исключений.

  Входные параметры:
    exceptionCaseId             - ИД записи исключения
    stringException             - Строка исключения
    stringNativeCase            - Строка исключения в именительном падеже
    strConvertInCase            - Строка, полученная склонением функцией
                                  convertNameInCase
    formatString                - формат строки для преобразования (
                                  "L"- строка содержит фамилию
                                  , "F"- строка содержит имя
                                  , "M" - строка содержит отчество)
                                  , если параметр null, то считаем,
                                  что формат строки "LFM"
    sexCode                     - Пол (M – мужской, W - женский)
    caseCode                    - код падежа (NAT – именительный
                                  , GEN - родительный
                                  , DAT - дательный, ACC – винительный
                                  , ABL - творительный, PREP - предложный)
    operatorId                  - ИД оператора

  Выходные параметры отсутствуют.

  ( <body::updateExceptionCase>)
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
);

/* pfunc: convertNameInCase
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

  ( <body::convertNameInCase>)
*/
function convertNameInCase(
  nameText varchar2
  , formatString varchar2
  , caseCode varchar2
  , sexCode varchar2 default null
)
return varchar2;

end pkg_ConvertNameInCase;
/
