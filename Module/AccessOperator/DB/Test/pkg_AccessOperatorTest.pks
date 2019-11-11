create or replace package pkg_AccessOperatorTest is
/* package: pkg_AccessOperatorTest
  Тестовый пакет для public части модуля.

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
  login                       - Логин оператора ( при задании используется
                                в качестве пароля)
  baseName                    - Уникальное базовое имя оператора
                                ( используется для формирования логина,
                                  по которому затем проверяется наличие
                                  оператора). Может быть задан либо
                                login либо baseName.
  roleSNameList               - Список кратких наименований ролей, которые
                                должны быть выданы оператору
                                ( по умолчанию роли не проверяются)

  Возврат:
  Id оператора

  ( <body::getTestOperatorId>)
*/
function getTestOperatorId(
  baseName        varchar2           := null
  , login         varchar2           := null
  , roleSNameList cmn_string_table_t := null
)
return integer;

/* pfunc: isUserAdmin
  Возвращает:
    1 в случае успеха <pkg_Operator.isUserAdmin>
    0 в случае исключения в <pkg_Operator.isUserAdmin>

  Параметры:
    ..
    [список параметров <pkg_Operator.isUserAdmin>]
    ..

  Возврат:
    1 в случае успеха <pkg_Operator.isUserAdmin>
    0 в случае исключения в <pkg_Operator.isUserAdmin>

  ( <body::getTestOperatorId>)
*/
function isUserAdmin(
 OPERATORID INTEGER
 , TARGETOPERATORID INTEGER := null
 , ROLEID INTEGER := null
 , GROUPID INTEGER := null
)
return integer;

end pkg_AccessOperatorTest;
/
