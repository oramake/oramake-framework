create or replace package pkg_TaskProcessorUtility is
/* package: pkg_TaskProcessorUtility
  Константы модуля TaskProcessor.

  SVN root: Oracle/Module/TaskProcessor
*/

/* group: Функции */

/* pfunc: ClearOldTask
  Удаляет старые задания
  ( <body::ClearOldTask>).
*/
function ClearOldTask
return integer;

end pkg_TaskProcessorUtility;
/
