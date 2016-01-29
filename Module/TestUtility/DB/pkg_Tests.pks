create or replace package pkg_Tests
authid current_user
as
/* package: pkg_Tests
   ����� �������� ����� ����������� ������.

   SVN root: Oracle/Module/TestUtility
*/


/* group: ��������� */


/* const: Module_Name
  �������� ������, � �������� ��������� �����.
*/
Module_Name constant varchar2(30) := 'TestUtility';



/* group: ������� */

/* pproc: testTriggerUpdatePrimaryKey
   ��������� ���� �� ������� ���������� ����� � �������� �� update ��������� �������
*/
procedure testTriggerUpdatePrimaryKey (
  tableName in varchar2
  );

end pkg_Tests;
/
