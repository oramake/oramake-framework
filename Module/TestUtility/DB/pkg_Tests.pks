create or replace package pkg_Tests
authid current_user
as
/* package: pkg_Tests
   Пакет содержит набор стандартных тестов.

   SVN root: Oracle/Module/TestUtility
*/


/* group: Константы */


/* const: Module_Name
  Название модуля, к которому относится пакет.
*/
Module_Name constant varchar2(30) := 'TestUtility';



/* group: Функции */

/* pproc: testTriggerUpdatePrimaryKey
   Выполняет тест на наличие первичного ключа в триггере на update указанной таблицы
*/
procedure testTriggerUpdatePrimaryKey (
  tableName in varchar2
  );

end pkg_Tests;
/
