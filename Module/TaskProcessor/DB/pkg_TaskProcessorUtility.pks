create or replace package pkg_TaskProcessorUtility is
/* package: pkg_TaskProcessorUtility
  ��������� ������ TaskProcessor.

  SVN root: Oracle/Module/TaskProcessor
*/

/* group: ������� */

/* pfunc: ClearOldTask
  ������� ������ �������
  ( <body::ClearOldTask>).
*/
function ClearOldTask
return integer;

end pkg_TaskProcessorUtility;
/
