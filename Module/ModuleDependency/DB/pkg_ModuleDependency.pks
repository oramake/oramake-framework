create or replace package pkg_ModuleDependency is
/* package: pkg_ModuleDependency
  ������������ ����� ������ ModuleDependency.
  ����� �������� ������� ���������� ����� ����������� ������� 
  ������ �� ���������� ������ map.xml 
  � ��������� ������������� Oracle
  
  SVN root: Oracle/Module/ModuleDependency
*/



/* group: ��������� */

/* const: Module_Name
  �������� ������, � �������� ��������� �����.
*/
Module_Name constant varchar2(30) := 'ModuleDependency';



/* group: ���� ���������� ���������� ������������ */

/* const: MapXML_SourceTypeCode
  ��� �������� ���������� ����������� �� MAP.XML �����.
*/
MapXML_SourceTypeCode constant varchar2(10) := 'MAP.XML';

/* const: Sys_SourceTypeCode
  ��� ��������� ���������� ����������� ������ �� ��������� ������������� Oracle.
*/
Sys_SourceTypeCode constant varchar2(10) := 'SYS';



/* group: ������� */

/* pproc: refreshDependencyFromMapXML
  ��������� ������ ������������ ������ �� ������ �������
  �� ���������� map.xml.

  ���������:
  svnRoot                     - ���� � ��������� �������� ������ � Subversion
*/
procedure refreshDependencyFromMapXML(
  svnRoot varchar2
);

/* pproc: refreshDependencyFromMapXML
  ��������� ������ ������������ ������ �� ������ �������
  �� ���������� ���������� ������������� all_dependencies.

  ���������:
  svnRoot                     - ���� � ��������� �������� ������ � Subversion
*/
procedure refreshDependencyFromSYS(
  svnRoot varchar2
);

/* pproc: createDependency
  ������� ����������� ������ �� ������.

  ���������:
  svnRoot                     - ���� � ��������� �������� ������ � Subversion
  referencedSvnRoot varchar2  - ���� � ��������� �������� ������, �� �������� �������
  buildSource varchar2        - ��������, �� �������� ��������� �����������.
                              - ���������� ��������: SYS, MAP.XML
*/
procedure createDependency(
  svnRoot varchar2
  , referencedSvnRoot varchar2
  , buildSource varchar2
);

/* pproc: findDependency
  ������� ���������� ������ ������������ ��� ������,
  �������������� ����������� � ����������� � ������� md_module_dependency

  ���������:
  svnRoot                     - ���� � ��������� �������� ������ � Subversion
  referencedSvnRoot varchar2  - ���� � ��������� �������� ������, �� �������� �������
  buildSource varchar2        - ��������, �� �������� ��������� �����������.
                              - ���������� ��������: SYS, MAP.XML

  ������� ( ������ ):
  svnRoot                     - ���� � ��������� �������� ������ � Subversion
  referencedSvnRoot varchar2  - ���� � ��������� �������� ������, �� �������� �������
  buildSource varchar2        - ��������, �� �������� ��������� �����������.
                              - ���������� ��������: SYS, MAP.XML
  last_refresh_date           - ���� ���������� ���������� ������
  date_ins                    - ���� ���������� ������

*/
function findDependency(
  svnRoot varchar2
  , referencedSvnRoot varchar2
  , buildSource varchar2
)
return sys_refcursor;

/* pproc: deleteDependency
  ������� ������� ����������� ������, ����������� � ������� md_module_dependency

  ���������:
  svnRoot                     - ���� � ��������� �������� ������ � Subversion
  referencedSvnRoot varchar2  - ���� � ��������� �������� ������, �� �������� �������
*/
procedure deleteDependency(
  svnRoot varchar2
  , referencedSvnRoot varchar2
);

/* pproc: refreshAllDependencyFromSVN
  ��������� ������ ������������ ���� ������� �� SVN
  �� ���������� map.xml.
*/
procedure refreshAllDependencyFromSVN;

/* pproc: refreshAllDependencyFromSYS
  ��������� ������ ������������ ���� ������� �� SVN
  �� ���������� ���������� ������������� all_dependencies.
*/
procedure refreshAllDependencyFromSYS;


end pkg_ModuleDependency;
/
