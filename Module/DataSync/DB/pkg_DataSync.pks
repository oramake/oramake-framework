create or replace package pkg_DataSync
authid current_user
is
/* package: pkg_DataSync
  ������� ���������� ������, ��������������� ��� ������������� � ����������
  �������.

  ����� ����������� � ������� ����������� ( authid current_user).

  SVN root: Oracle/Module/DataSync
*/



/* group: ��������� */

/* const: Module_Name
  �������� ������, � �������� ��������� �����.
*/
Module_Name constant varchar2(30) := 'DataSync';



/* group: ������ ���������� */

/* const: Compare_RefreshMethodCode
  ��� ������ ���������� ������� � ������� ��������� ������.
*/
Compare_RefreshMethodCode constant varchar2(1) := 'd';

/* const: CompareTemp_RefreshMethodCode
  ��� ������ ���������� ������� � ������� ��������� ������ � ��������������
  ��������� �������.
*/
CompareTemp_RefreshMethodCode constant varchar2(1) := 't';

/* const: MView_RefreshMethodCode
  ��� ������ ���������� ������� � ������� ������������������ �������������.
*/
MView_RefreshMethodCode constant varchar2(1) := 'm';



/* group: ������� */



/* group: ���������� � ������� ��������� */

/* pproc: refreshByCompare
  ��������� ������ ������� � ������� ��������� ������������ � ��� � ����������
  ������ � �������� ����������� ��������� ��������� merge � delete.

  ���������:
  targetTable                 - ������� ��� ���������� ( ��� �������, ��������
                                � ��������� �����, ��� ����� ��������)
  dataSource                  - �������� ���������� ������
  tempTableName               - ��������� ������� ��� �������������� ����������
                                ���������� ������ � ������������� � ��������
                                merge � delete ( ��� �������, ��������
                                � ��������� �����, ��� ����� ��������)
                                ( �� ��������� � �������� merge � delete
                                  ������������ �������� ���������� ������)
  excludeColumnList           - ������ ������� �������, ����������� ��
                                ���������� ( � ������������ �������, ��� �����
                                ��������)
                                ( �� ��������� ������, �.�. ����������� ���
                                  ������� �������)

  ���������:
  - � ������� ������ ���� ��������� ����;
  - � dataSource ����� ���� ������� ����� ���������, �� �������� �����
    ��������� ������� � ��������� ���� �������, �������������� � ������� ���
    ����������, �� ����������� ��������� � excludeColumnList;
  - �� ��������� ������� ������ ���� ��� �������, �������������� � ������� ���
    ����������, �� ����������� ��������� � excludeColumnList;

  ( <body::refreshByCompare>)
*/
procedure refreshByCompare(
  targetTable varchar2
  , dataSource varchar2
  , tempTableName varchar2 := null
  , excludeColumnList varchar2 := null
);



/* group: ���������� � �������������� ���������� ����� */

/* pproc: appendData
  �������� ������ � �������(�) � �������� �� �� ���������� �����.

  ���������:
  targetDbLink                - ���� � �� ����������
  tableName                   - ������� ��� ��������
  idTableName                 - ������������ �������� ������� ��� ������
                                �������� ���������� ����� (��-���������
                                tableName)
  addonTableName              - �������������� ������� ��� ��������
  useSourceViewFlag           - ������������ ������������� � �������� �������� ������
  (��� �������������
  toDate                      - ����, �� ������� ���������� ������
                                ( rq_find_request.date_ins < toDate, ��
                                  ��������� �� ������ ����������� ����)
  maxExecTime                 - ������������ ����� ���������� ��������� ( �
                                ������, ���� ����� ��������� � �������� ������
                                ��� ���������, ��������� ��������� ������
                                � ������� ������������� � ���, �� ���������
                                ��� �����������)

  �������:
  - ����� ����������� �������;

  ���������:
  - ������� ����������� � ���������� ���������� � ������ commit ����� ��������
    ������������� ����� �������;

  ( <body::appendData>)
*/
function appendData(
  targetDbLink                varchar2
, tableName                   varchar2
, idTableName                 varchar2 := null
, addonTableName              varchar2 := null
, useViewFlag                 boolean := null
, toDate                      date := null
, maxExecTime                 interval day to second := null
)
return integer;



/* group: ���������� � ������� ������������������ ������������� */

/* pproc: createMLog
  ������� ����������� ���� ����������������� �������������.

  ���������:
  mlogList                    - ������ ����� �-������������� � �������
                                <tableName>[:<createOption>], ��� tableName
                                ��� ������� ������� ( ��� ����� ��������),
                                createOption ����� ��� �������� ����
                                ( ������: "tmp_table:with rowid")
  viewList                    - ������ �������������, ������������ ���
                                ���������� ( ����������� ��� ������������� ���
                                ����� ��������)
                                ( ���������� ��������� ������ � ������
                                  grantPrivsFlag ������� 1, ����� ����������
                                  �������������, ������� ����� ������ �����,
                                  �� ��������� �����������)
  moduleSvnRoot               - ���� � ��������� �������� ������ � Subversion
                                ( ������� � ����� �����������, ��������:
                                "Oracle/Module/ModuleInfo"). ���� ������, ��
                                � ����������� � �������, ���������� ���,
                                ����������� ������
                                " [ SVN root: <moduleSvnRoot>]"
                                ( �� ��������� �����������)
  forTableName                - ��������� ��� ������ ��� ��������� �������
                                �� ������
                                ( �� ��������� ��� �����������)
  recreateFlag                - ���� ������������ ����, ���� �� ����������
                                ( 1 ��, 0 ��� ( �� ���������))
  grantPrivsFlag              - ���� ������ �������������, ������� ����� ��
                                �������� �������������, � ������� ������������
                                ������� ����, ���� �� ��� � ������ ��� ��������
                                ( 1 ��, 0 ��� ( �� ���������))

  ( <body::createMLog>)
*/
procedure createMLog(
  mlogList cmn_string_table_t
  , viewList cmn_string_table_t := null
  , moduleSvnRoot varchar2 := null
  , forTableName varchar2 := null
  , recreateFlag integer := null
  , grantPrivsFlag integer := null
);

/* pproc: dropMLog
  ������� ���������������� ���� ����������������� �������������.

  ���������:
  mlogList                    - ������ ����� �-������������� � �������
                                <tableName>[:<createOption>], ��� tableName
                                ��� ������� ������� ( ��� ����� ��������),
                                createOption ����� ��� �������� ���� ( ��
                                ������������)
  moduleSvnRoot               - ���� � ��������� �������� ������ � Subversion
                                ( ������� � ����� �����������, ��������:
                                "Oracle/Module/ModuleInfo"). ���� ������, ��
                                �� ����������� � �������, ���������� ���,
                                ������������, ��� �� ��� ������ � ������ ������
                                ( �� ��������� �����������)
  forTableName                - ������� ��� ������ ��� ��������� �������
                                �� ������
                                ( �� ��������� ��� �����������)
  forceFlag                   - ���� �������� ���� ���� ���� �� �������� ��
                                ���������� � ������ ������
                                ( 1 ��, 0 ��� ( �� ���������))
  continueAfterErrorFlag      - ���������� ��������� ��������� ����� � ������
                                ������ ��� �������� ���� ������������������
                                �������������
                                ( 1 ��, 0 ��� ( �� ���������))

  ���������:
  - ���� ��� ��� �������� �����������, �� �������� �� ����������� � ���������
    ����������� ��� ������;

  ( <body::dropMLog>)
*/
procedure dropMLog(
  mlogList cmn_string_table_t
  , moduleSvnRoot varchar2 := null
  , forTableName varchar2 := null
  , forceFlag integer := null
  , continueAfterErrorFlag integer := null
);

/* pproc: grantPrivs
  ������ ����� ��� ��������� ������������, ��� ������� ����� �����������
  ������������ �������.

  ���������:
  viewList                    - ������ �������������, ������������ ���
                                ���������� ( ����������� ��� ������������� ���
                                ����� ��������)
  userName                    - ��� ������������, �������� �������� �����
  mlogList                    - ������ ����� �-������������� � �������
                                <tableName>[:<createOption>], ��� tableName
                                ��� ������� ������� ( ��� ����� ��������),
                                createOption ����� ��� �������� ���� ( ��
                                ������������)
                                ( �� ��������� �����������)
  forObjectName               - ���������� ������ ���� ������ ���������
                                �������������� ���� �������� ��������
                                � ��������� � ��� �����
                                ( ��� ������� ��� ����� ��������)
                                ( �� ��������� ��� �����������)

  ( <body::grantPrivs>)
*/
procedure grantPrivs(
  viewList cmn_string_table_t
  , userName varchar2
  , mlogList cmn_string_table_t := null
  , forObjectName varchar2 := null
);

/* pproc: dropMViewPreserveTable
  ������� ����������������� ������������� � ����������� ����������� �������
  � �������.

  ���������:
  tableName                   - ��� ������� ( �-�������������)

  ( <body::dropMViewPreserveTable>)
*/
procedure dropMViewPreserveTable(
  tableName varchar2
);

/* pproc: refreshByMView
  ��������� ������ ������������ ������� � ������� fast-������������
  ������������������ �������������.

  ���������:
  tableName                   - ��� ������� ( �-�������������) ��������
                                ������������
  sourceView                  - ��� ������������� � ��������� �������, ��������
                                � ��������� �����
                                ( ��� ����� ��������, ������������ � ������
                                  �������� �-�������������)
                                ( �� ��������� �����������)
  excludeColumnList           - ������ ������� �������, ����������� ��
                                ���������� ( � ������������ �������, ��� �����
                                ��������)
                                ( �� ��������� ������, �.�. ����������� ���
                                  ������� �������)
  allowDropMViewList          - ������ ����������������� ������������� ��������
                                ������������, ������� ����� ���� �������, ����
                                ��� ������� �� ����������� ����������� �������
                                ( ��� ���������� ������ "ORA-32334: cannot
                                  create prebuilt materialized view on a table
                                  already referenced by a MV" ��� ��������
                                  ������������������ �������������)
                                ( ��� ����� ��������, �� ��������� ������
                                  ������ � �������� �� �����������)
  createMViewFlag             - ��������� ����������������� ������������� ���
                                ���������� �������, ���� ��� ����������� ����
                                ��� ���������� ������������ ��� ����������
                                ( 1 ��, 0 ��� ( �� ���������), ������������ �
                                  � ������ �������� forceCreateMViewFlag ������
                                  1)
  forceCreateMViewFlag        - ���������� ��������� ( �������������)
                                ����������������� ������������� ��� ����������
                                �������
                                ( 1 ��, 0 ��� ( �� ���������))

  ���� �������� createMViewFlag ����� 1, �� ��� ���������� ���������
  ����������������� ������������� �����:
  - ������� � ������ ��� ����������;
  - ����������� � ������ ������������ ����� �������� ������, �� ������� ���
    �������� ( ��� ������������� ������
    "ORA-12034: materialized view log on "..." younger than last refresh"
    �� ����� ���������� ���� ���� ���� �������� ���������� ����
    ( ������������ � ��� �� ��, ��� � ����������������� �������������) ������
    ��� ����� ���� �������� ������������������ �������������);

  ���� �������� forceCreateMViewFlag ����� 1, �� ��� ���������� ���������
  � ����� ������ ����� ������� ����� ����������������� �������������.

  ���������:
  - ��� ���������� ������� ����������� commit;
  - ��� ���������� �������� ��������� � �������� ������ ����� ���������
    �-������������� ��������������� ������������ ���������� �� �������
    ��� ���������� � �� ������� � ��������� �������, �� ������� �������
    �������� �������������, � ����������� ���������� ������ ������� � �������
    ��������� ������ ( ��. <refreshByCompare>);

  ( <body::refreshByMView>)
*/
procedure refreshByMView(
  tableName varchar2
  , sourceView varchar2 := null
  , excludeColumnList varchar2 := null
  , allowDropMViewList cmn_string_table_t := null
  , createMViewFlag integer := null
  , forceCreateMViewFlag integer := null
);



/* group: ���������� ������ ������ */

/* pfunc: getTableConfigString
  ���������� ��������������� ������ � ����������� ���������� ��� �������.

  ���������:
  srcString                   - �������� ������
                                ( ������� ������ ������, ������������� �
                                  �������� �������� �������� tableList �������
                                  <refresh>)
  sourceSchema                - ��� ����� �� ��������� ��� ��������
                                �������������
                                ( �� ��������� �����������)

  �������:
  ��������������� ������.

  ������ ���������������
  ������:

  <tableName>:<refreshMethod>:<sourceView>:<tempTableName>:<excludeColumnList>

  ( <body::getTableConfigString>)
*/
function getTableConfigString(
  srcString varchar2
  , sourceSchema varchar2 := null
)
return varchar2;

/* pproc: refresh
  ��������� ������ � ������������ ��������.

  ���������:
  tableList                   - ������ ������ ��� ���������� ( ������ ��. ����)
  sourceSchema                - ��� ����� �� ��������� ��� ��������
                                �������������
                                ( �� ��������� �����������)
  forTableName                - ���������� ������ ��������� �������
                                ( ��� ������� ��� ����� ��������)
                                ( �� ��������� ��� �����������)
  createMViewFlag             - ��������� ����������������� ������������� ���
                                ���������� �������, ���� ��� ����������� ����
                                ��� ���������� ������������ ��� ����������, �
                                ��� ������� ������ ����� ���������� � �������
                                �-�������������
                                ( 1 ��, 0 ��� ( �� ���������), ������������ �
                                  � ������ �������� forceCreateMViewFlag ������
                                  1)
  forceCreateMViewFlag        - ���������� ��������� ( �������������)
                                ����������������� ������������� ��� ����������
                                �������, ���� ��� ������� ������ �����
                                ���������� � ������� �-�������������
                                ( 1 ��, 0 ��� ( �� ���������))
  continueAfterErrorFlag      - ���������� ��������� ��������� ������ � ������
                                ������ ��� ����������
                                ( 1 ��, 0 ��� ( �� ���������))

  �������� ������ ������ ��� ���������� ( �������� tableList) ����������� � �������:

  <tableName>[:[<refreshMethod>][:[<sourceView>][:[<tempTableName>]]]][:[<optionList>]]

  tableName             - ��� ������� ��� ���������� ( ��� ����� ��������)
                          ( � ������ ���������� � ������� ������������������
                          ������������� ������� ������ ������������ ��������
                          ������������, ����� ����� ������ �������
                          ����� ������� �����)
  refreshMethod         - ����� ���������� ( "d" ���������� ������ ( ��
                          ���������), "m" � ������� ������������������
                          �������������, "t" ���������� � ��������������
                          ��������� �������)
  sourceView            - ��� ��������� �������������, �������� � ���������
                          ����� ( ��� ����� ��������, �� ��������� �������� ��
                          ������ ����� ������� ��� ���������� �����������
                          �������� "v_", � �������� ����� �� ���������
                          ������������ �������� ��������� sourceSchema)
  tempTableName         - ��� ��������� ������� ( ��� ����� ��������),
                          ������������ ��� ���������� ������� "t" ( ��
                          ��������� �������� �� ������ ����� ������� ���
                          ���������� ����������� ��������� "_tmp")
  optionList            - ������ �������������� ����� ( � ������������ ������)
                          � ������� "<optName>=<optValue>", ���������� �����
                          ����������� ����;

  ��������� ��������������
  ����� ( ����������� � <optionList>):

  excludeColumnList     - ������ ������� �������, ����������� �� ����������
                          ( � ������������ �������, ��� ����� ��������,
                           ���������� ������� ������������) ( �� ���������
                          � ���������� ��������� ��� �������)

  ������� ��������� ( 0x09), �������� ������� ( 0x0D), �������� ������ ( 0x0A)
  ��������������� ��� ���������� � ������������, ���� ��� ������� �� ��� �����
  ��������� ������.

  ���������:
  - ����� ���������� ������ ������� ����������� commit;

  ( <body::refresh>)
*/
procedure refresh(
  tableList cmn_string_table_t
  , sourceSchema varchar2 := null
  , forTableName varchar2 := null
  , createMViewFlag integer := null
  , forceCreateMViewFlag integer := null
  , continueAfterErrorFlag integer := null
);

/* pproc: dropRefreshMView
  ������� ����������������� �������������, ��������� ��� ����������
  ������������ ������.
  �������� ����������� ������ � ������, ���� � ������ ������ ��� �������
  ������ ����� ���������� � ������� ������������������ �������������
  (  ������� ��� �������� �-������������� �����������).

  ���������:
  tableList                   - ������ ������ ��� ���������� ( ������ ��. �
                                �������� ��������� <refresh>)
  forTableName                - ��������� ������ ��������� �������
                                ( ��� ������� ��� ����� ��������)
                                ( �� ��������� ��� �����������)
  ignoreNotExistsFlag         - ������������ ���������� ������������������
                                ������������� ��� ��������
                                ( 1 ������������, 0 ����������� ������
                                  ( �� ���������))
  continueAfterErrorFlag      - ���������� ��������� ��������� ������ � ������
                                ������ ��� �������� ������������������
                                �������������
                                ( 1 ��, 0 ��� ( �� ���������))

  ( <body::dropRefreshMView>)
*/
procedure dropRefreshMView(
  tableList cmn_string_table_t
  , forTableName varchar2 := null
  , ignoreNotExistsFlag integer := null
  , continueAfterErrorFlag integer := null
);

end pkg_DataSync;
/
