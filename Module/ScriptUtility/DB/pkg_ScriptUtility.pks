create or replace package pkg_ScriptUtility as
/* package: pkg_ScriptUtility
  ��������� ��������������� �������, ������������ ��� ����������.

  SVN root: Oracle/Module/ScriptUtility
*/



/* group: ������� */

/* pproc: deleteComments
 ������� ����������� �� �������

  ( <body::deleteComments>)
*/
function deleteComments(
  text in clob
)
return clob;

/* pproc: makeColumnList
  ������� ������ ������� �������.

  ( <body::makeColumnList>)
*/
procedure makeColumnList(
  tableName varchar2
  , prefix varchar2 := ', '
  , postFix varchar2 := ''
  , lastPostFix varchar2 := ''
  , withDataType boolean := false
  , trimVarchar boolean := false
  , letterCase integer := 1
  , duplicateWithAs boolean := false
  , inQuotas boolean := false
  , eraseUnderline boolean := false
);

/* pproc: generateInsertFake
  ��������� ������� �� ���������� fake-������ � �������.

  ���������:
  tableName                   - ��� �������
  owner                       - ��� ������������ ( ��-���������, �������)

  ( <body::generateInsertFake>)
*/
procedure generateInsertFake(
  tableName varchar2
  , owner varchar2 := null
);

/* pproc: tableDefinition
  �������� ����������� �������

  ( <body::tableDefinition>)
*/
procedure tableDefinition(
  tableName varchar2
  , sourceDbLink varchar2
  , sourceUser varchar2
);

/* pfunc: getColumnDefinition(type)
  ���������� ������ ���������� ���� ������� � �������

  ���������
     DataType -  ������������� Data_Type �� all_tab_cols
     DataPrecision -  ������������� Data_Precision �� all_tab_cols
     DataScale - ������������� Data_Scale �� all_tab_cols
     DataLength - ������������� Data_Length �� all_tab_cols
     CharLength - ������������� Char_Length �� all_tab_cols

  ( <body::getColumnDefinition(type)>)
*/
function getColumnDefinition(
  dataType all_tab_cols.Data_Type%type
  , dataPrecision all_tab_cols.Data_Precision%type
  , dataScale  all_tab_cols.Data_Scale%type
  , dataLength  all_tab_cols.Data_Length%type
  , charLength  all_tab_cols.Char_Length%type
) return varchar2;

/* pfunc: getColumnDefinition(table)
  ���������� ������ ���������� ���� ������� � �������.

  ���������:
    tableName - ��� �������
    columnName - ��� �������

  �������:
  - ����������� ���� �������

  ( <body::getColumnDefinition(table)>)
*/
function getColumnDefinition(
  tableName varchar2
  , columnName varchar2
  , raiseWhenNoDataFound integer := null
)
return varchar2;

/* pproc: generateApi
  ��������� body ������ API ��� �������.

  ���������:
  ignoreColumnList            - ������ ������������ ������� ����� ","

  ( <body::generateApi>)
*/
procedure generateApi(
  tableName varchar2
  , entityNameObjectiveCase varchar2
  , ignoreColumnList varchar2 := null
);

/* pproc: generateHistoryStructure
  ��������� ������ ������������ ���������

  outputType                 - ��� ������ � dbms_output.
                               null-�� �������� ����������
                               1-���������� ��������
                               2-������������ ��������
                               3-�������� �������������������
                               4-�������� �������������

  ( <body::generateHistoryStructure>)
*/
procedure generateHistoryStructure(
  tableName varchar2
  , outputFilePath varchar2
  , moduleName varchar2
  , tableComment varchar2
  , svnRoot varchar2
  , abbrFrom varchar2 := null
  , abbrTo varchar2 := null
  , abbrFrom2 varchar2 := null
  , abbrTo2 varchar2 := null
  , historyProcedureName varchar2:= null
  , outputType integer := null
);



/* group: ������������ ������� ( ������ Oracle/Module/DataSync) */

/* pproc: generateInterfaceTable
  ��������� �������� �������� ������������ ������ �� �������������� �
  ��������� �������.

  ���������:
  outputFilePath              - ���� � �������� ��� ����������� ������
  objectPrefix                - ������� �������� ������ ( ������ �����������,
                                ���� �� ������ �������� ��������� viewName)
  viewName                    - �������� �������������
                                ( ����� ��� like � �������� ������������� "\",
                                �� ��������� ��� ������������� ��������
                                �������� �������� ������)
  tableName                   - ��� ������������ ������� ( ����� ��������������
                                ������ ���� �������������� ���� ��������
                                �������������, �� ��������� �� ������ �����
                                ��������� �������������)

  ���������:
  - ��� ��������� ��� ������������ ������� ��������� ��������� ���� ��
    ������� ���� ( ���� ��� �� ���, ����� ������� �������� ������);
  - ����������� ��� ������������ ������� ������� �� ����������� � ���������
    ������������� � ��������� ������ "( �������� ������)", �������������
    ����� ������ � SVN root, �.�. ��������������� ������� � ���������
    ������������ ����������� ����:
    "<�������� ������ �������> ( �������� ������) [ SVN root: <moduleSvnRoot>]"
  - � ������, ���� � ������� ������������ ���� ���� rowid � ������
    "int_%_rid", �� ��� ���� ��������� ������;

  ( <body::generateInterfaceTable>)
*/
procedure generateInterfaceTable(
  outputFilePath varchar2
  , objectPrefix varchar2 := null
  , viewName varchar2 := null
  , tableName varchar2 := null
);

/* pproc: generateInterfaceTempTable
  ��������� �������� �������� ��������� ������� ��� ���������� ������������
  ������ �� �������������� � ��������� �������.

  ���������:
  outputFilePath              - ���� � �������� ��� ����������� ������
  objectPrefix                - ������� �������� ������ ( ������ �����������,
                                ���� �� ������ �������� ��������� viewName)
  viewName                    - �������� �������������
                                ( ����� ��� like � �������� ������������� "\",
                                �� ��������� ��� ������������� ��������
                                �������� �������� ������)
  tableName                   - ��� ������� ( ����� ��������������
                                ������ ���� �������������� ���� ��������
                                �������������, �� ��������� �� ������ �����
                                ��������� �������������)

  ���������:
  - ��� ��������� ��� ������� ��������� ��������� ���� �� ������� ���� ( ����
    ��� �� ���, ����� ������� �������� ������);
  - ����������� ��� ������������ ������� ������� �� ����������� � ���������
    ������������� � ��������� ������ "( �������� ������)", �������������
    ����� ������ � SVN root, � ����������� ������ ��� ������
    "( ��������� ������� ��� ���������� ������), �.�. ��������������� �������
    � ��������� ������������ ����������� ����:
    "<�������� ������ �������> ( �������� ������) [ SVN root: <moduleSvnRoot>]"

  ( <body::generateInterfaceTempTable>)
*/
procedure generateInterfaceTempTable(
  outputFilePath varchar2
  , objectPrefix varchar2 := null
  , viewName varchar2 := null
  , tableName varchar2 := null
);

end;
/
