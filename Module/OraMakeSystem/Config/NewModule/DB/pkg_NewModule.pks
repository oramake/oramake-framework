create or replace package $(packageName) is
/* package: $(packageName)
  ������������ ����� ������ $(moduleName).

  SVN root: $(svnModuleRoot)
*/

/* const: Module_Name
  �������� ������, � �������� ��������� �����.
*/
Module_Name constant varchar2(30) := '$(moduleName)';

end $(packageName);
/
