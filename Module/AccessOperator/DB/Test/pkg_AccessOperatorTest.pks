create or replace package pkg_AccessOperatorTest is
/* package: pkg_AccessOperatorTest
  Тестовый пакет модуля.

  SVN root: Module/AccessOperator
*/

/* const: TestOperator_LoginPrefix
  Префикс логинов тестовых операторов, создаваемых функцией <getTestOperatorId>.
*/
TestOperator_LoginPrefix constant varchar2(50) := 'TestOp-';



/* group: Функции */

/* pfunc: getTestOperatorId
  Возвращает Id тестового оператора.
  Если тестового оператора не существует, он создается, если существует, то
  выданные ему роли корректируются согласно списку ( если он указан).

  Параметры:
  baseName                    - Уникальное базовое имя оператора
                                ( используется для формирования логина,
                                  по которому затем проверяется наличие
                                  оператора)
  roleSNameList               - Список кратких наименований ролей, которые
                                должны быть выданы оператору
                                ( по умолчанию роли не проверяются)

  Возврат:
  Id оператора

  ( <body::getTestOperatorId>)
*/
function getTestOperatorId(
  baseName varchar2
  , roleSNameList cmn_string_table_t := null
)
return integer;

end pkg_AccessOperatorTest;
/
