create or replace package pkg_AccessOperatorPrivateTest is
/* package: pkg_AccessOperatorTest
  Тестовый пакет для private части модуля.

  SVN root: Module/AccessOperator
*/



/* group: Функции */

/* pproc: testAdminOperation
  Тестирует функции создания/редактирования/удаления
  операторов/ролей/групп.

  ( <body::testAdminOperation>)
*/
procedure testAdminOperation;

end pkg_AccessOperatorPrivateTest;
/
