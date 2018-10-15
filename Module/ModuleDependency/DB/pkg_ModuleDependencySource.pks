create or replace package pkg_ModuleDependencySource is
/* package: pkg_ModuleDependency
  ��������� ����������� �� all_dependencies.

  SVN root:
*/



/* group: ��������� */

/* const: Module_Name
  �������� ������, � �������� ��������� �����.
*/
Module_Name constant varchar2(30) := 'ModuleDependency';



/* group: ������� */

/* pproc: unloadObjectDependency
  ��������� ����������� �� all_dependencies.

  ���������:
  targetDbLink                - dbLink �� �� ���������� ��� ��������
                                ������������ all_dependencies.
*/
procedure unloadObjectDependency(
  targetDbLink varchar2 default null
);

end pkg_ModuleDependencySource;
/
