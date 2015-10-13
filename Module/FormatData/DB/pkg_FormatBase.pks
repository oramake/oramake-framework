create or replace package pkg_FormatBase is
/* package: pkg_FormatBase
  Базовые константы и функции модуля.

  SVN root: Oracle/Module/FormatData
*/

/* group: Константы */

/* const: Module_Name
  Название модуля, к которому относится пакет.
*/
Module_Name constant varchar2(30) := 'FormatData';

/* const: Zero_Value
  Строка для указания отсутствия значения.
*/
Zero_Value constant varchar2(10) := '-';

/* group: Тип синонима */

/* const: FirstName_AliasTypeCode
  Код типа синонимов "Имя"
*/
FirstName_AliasTypeCode constant varchar2(10) := 'FN';

/* const: MiddleName_AliasTypeCode
  Код типа синонимов "Отчество"
*/
MiddleName_AliasTypeCode constant varchar2(10) := 'MN';

/* const: NoValue_AliasTypeCode
  Код типа синонимов для указания отсутствия значения.
*/
NoValue_AliasTypeCode constant varchar2(10) := 'NV';

end pkg_FormatBase;
/
