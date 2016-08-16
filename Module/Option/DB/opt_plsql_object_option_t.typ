-- ��� Oracle 11.2 � ���� ��� ������������ ���� ������������ ����� "force"
-- � create type, ��� ����� ������ ������ ������������ "drop type force"
set define on

@oms-default forceOption "' || case when to_number( '&_O_RELEASE') >= 1102000000 then 'force' else '--' end || '"

@oms-default dropTypeScript "' || case when '&forceOption' = '--' then './oms-drop-type.sql' else '' end || '"

@oms-run "&dropTypeScript" opt_plsql_object_option_t

create or replace type
  opt_plsql_object_option_t
&forceOption
under opt_option_list_t
(
/* db object type: opt_plsql_object_option_t
  ����������� ��������� PL/SQL �������
  ( ��������� ��� ���������� �������, ������� ����� <opt_option_list_t>).

  SVN root: Oracle/Module/Option
*/




/* group: ������� */



/* group: ������������ */

/* pfunc: opt_plsql_object_option_t
  ������� ����� ����������� ���������� PL/SQL ������� � ������������� ���
  ��������.

  ���������:
  findModuleString            - ������ ��� ������ ������ (
                                ����� ��������� � ����� �� ���� ���������
                                ������: ���������, ����� � ��������� ��������,
                                �������������� ����� � ��������� �������� �
                                Subversion)
  objectName                  - ��� PL/SQL ������� ( ������, SQL-����
                                � �.�.), � �������� ��������� ���������
  moduleName                  - ������������ ������ ( �������� "ModuleInfo")
  moduleSvnRoot               - ���� � ��������� �������� ������ � Subversion
                                ( ������� � ����� �����������, ��������
                                "Oracle/Module/ModuleInfo")

  ���������:
  - ��� PL/SQL ������� ( objectName) ������������ ��� ������� ������������
    �������, � �������� ��������� ��������� ( ���� object_short_name �������
    <opt_option>);
  - ��� ����������� ������ ������ ���� ����� ���� �� ����������
    findModuleString, moduleName, moduleSvnRoot � ������ �� ����
    ������ ������������ ����������, ����� ����� ��������� ����������;

  ( <body::opt_plsql_object_option_t>)
*/
constructor function opt_plsql_object_option_t(
  findModuleString varchar2 := null
  , objectName varchar2
  , moduleName varchar2 := null
  , moduleSvnRoot varchar2 := null
)
return self as result,

/* pfunc: opt_plsql_object_option_t( moduleId)
  ������� ����� ����������� ���������� PL/SQL ������� � ������������� ���
  ��������.

  ���������:
  moduleId                    - Id ������, � �������� ��������� ���������
  objectName                  - ��� PL/SQL ������� ( ������, SQL-����
                                � �.�.), � �������� ��������� ���������

  ���������:
  - ��� PL/SQL ������� ( objectName) ������������ ��� ������� ������������
    �������, � �������� ��������� ��������� ( ���� object_short_name �������
    <opt_option>);

  ( <body::opt_plsql_object_option_t( moduleId)>)
*/
constructor function opt_plsql_object_option_t(
  moduleId integer
  , objectName varchar2
)
return self as result

)
/
