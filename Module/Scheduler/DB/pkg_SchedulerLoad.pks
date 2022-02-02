create or replace package pkg_SchedulerLoad is
/* package: pkg_SchedulerLoad
  ����� ��� �������� ������ �������� ������� � ��.

  SVN root: Oracle/Module/Scheduler
*/



/* group: ������� */



/* group: ������� */

/* pfunc: getAttributeString
  ��������� �������� �������� ������.

  ���������:
  xml                       - ������ xml
  xPath                     - ���� XPath � ����
  raiseExceptionFlag        - ������������ �� ����������, ���� ��� �� ������

  ( <body::getAttributeString>)
*/
function getAttributeString(
  xml xmltype
  , xPath varchar2
  , attributeName varchar2
  , raiseExceptionFlag boolean := null
)
return varchar2;

/* pfunc: getBatchTypeId
  ��������� id ���� �����.

  ���������:
  moduleId                    - id ������

  ( <body::getBatchTypeId>)
*/
function getBatchTypeId(
  moduleId integer
)
return integer;

/* pfunc: getXmlString
  ��������� ������ ��� �������� xml.

  ���������:
  sourceString                - �������� ������

  ( <body::getXmlString>)
*/
function getXmlString(
  sourceString varchar2
)
return varchar2;

/* pproc: setLoggingLevel
  ������������� ������� ����������� ������ ( <logger>).

  ���������:
  levelCode               - ������� �����������

  ( <body::setLoggingLevel>)
*/
procedure setLoggingLevel(
  levelCode varchar2
);

/* pfunc: normalizeText
  ����������� �����. ������� ������������ ������� � "." � ����� � � ������
  ������. ������� ���������� ������� � ����� �����. ����������� Windows-�����
  ����� � ��� Unix.

  ���������:
  sourceText                  - �������� ����

  �������:
  - ��������������� �����;

  ( <body::normalizeText>)
*/
function normalizeText(
  sourceText varchar2
)
return varchar2;



/* group: �������� ������ � �� */

/* pproc: loadJob(moduleId)
  �������� ������� (job) � ��.

  ���������:
  moduleId                    - id ������
  jobShortName                - �������� ������������ �������
  jobName                     - ������������ ������� ( �� �������)
  description                 - �������� �������
  jobWhat                     - plsql-��� �������
  publicFlag                  - ���� ������������� ������� ( 1 - ������� �����
                                ���� ������������ � ������ �������, 0 - �������
                                ����� ���� ������������ ������ � ������ ������,
                                ��-��������� 0)
  batchShortName              - �������� ������������ ��������� ������� ( �����),
                                ���� ������� ����� ���� ������������ ������
                                � ������ �������� ������� ( �����)
  skipCheckJob                - ���� �������� �������� ������������
                                ( ����������) PL/SQL-������ ������� ( "1" ��
                                ���������, �� ��������� ���������)

  ( <body::loadJob(moduleId)>)
*/
procedure loadJob(
  moduleId integer
  , jobShortName varchar2
  , jobName varchar2
  , description varchar2
  , jobWhat varchar2
  , publicFlag number := null
  , batchShortName varchar2 := null
  , skipCheckJob number := null
);

/* pproc: loadJob(jobName)
  �������� ������� (job) � ��.

  ���������:
  moduleName                  - �������� ������ ( �������� "ModuleInfo")
  moduleSvnRoot               - ���� � ��������� �������� ����������������
                                ������ � Subversion ( ������� � �����
                                �����������, ��������
                                "Oracle/Module/ModuleInfo")
  moduleInitialSvnPath        - �������������� ���� � ��������� ��������
                                ���������������� ������ � Subversion ( �������
                                � ����� ����������� � ������ ����� ������, �
                                ������� �� ��� ������, ��������
                                "Oracle/Module/ModuleInfo@711")
  jobShortName                - �������� ������������ �������
  jobName                     - ������������ ������� ( �� �������)
  jobWhat                     - PL/SQL-��� �������
  publicFlag                  - ���� ������������� ������� ( 1 - ������� �����
                                ���� ������������ � ������ �������, 0 - �������
                                ����� ���� ������������ ������ � ������ ������,
                                ��-��������� 0)
  batchShortName              - �������� ������������ ��������� ������� ( �����),
                                ���� ������� ����� ���� ������������ ������
                                � ������ �������� ������� ( �����)
  skipCheckJob                - ���� �������� �������� ������������
                                ( ����������) PL/SQL-������ ������� ( "1" ��
                                ���������, �� ��������� ���������)

  ����������:
  - ������ ���� ����� ���� �� ���� �� ��� ���������� moduleName,
    moduleSvnRoot, moduleInitialSvnPath;

  ( <body::loadJob(jobName)>)
*/
procedure loadJob(
  moduleName varchar2 := null
  , moduleSvnRoot varchar2 := null
  , moduleInitialSvnPath varchar2 := null
  , jobShortName varchar2
  , jobName varchar2
  , jobWhat varchar2
  , description varchar2
  , publicFlag number := null
  , batchShortName varchar2 := null
  , skipCheckJob number := null
);

/* pproc: loadJob(fileText)
  �������� ������� (job) � ��.

  ���������:
  moduleName                  - �������� ������ ( �������� "ModuleInfo")
  moduleSvnRoot               - ���� � ��������� �������� ����������������
                                ������ � Subversion ( ������� � �����
                                �����������, ��������
                                "Oracle/Module/ModuleInfo")
  moduleInitialSvnPath        - �������������� ���� � ��������� ��������
                                ���������������� ������ � Subversion ( �������
                                � ����� ����������� � ������ ����� ������, �
                                ������� �� ��� ������, ��������
                                "Oracle/Module/ModuleInfo@711")
  jobShortName                - �������� ������������ �������
  fileText                    - ����� ��������� ����� ��� ��������
  publicFlag                  - ���� ������������� ������� ( 1 - ������� �����
                                ���� ������������ � ������ �������, 0 - �������
                                ����� ���� ������������ ������ � ������ ������,
                                ��-��������� 0)
  batchShortName              - �������� ������������ ��������� ������� ( �����),
                                ���� ������� ����� ���� ������������ ������
                                � ������ �������� ������� ( �����)
  skipCheckJob                - ���� �������� �������� ������������
                                ( ����������) PL/SQL-������ ������� ( "1" ��
                                ���������, �� ��������� ���������)

  ����������:
  - ������ ���� ����� ���� �� ���� �� ��� ���������� moduleName,
    moduleSvnRoot, moduleInitialSvnPath;

  ( <body::loadJob(fileText)>)
*/
procedure loadJob(
  moduleName varchar2 := null
  , moduleSvnRoot varchar2 := null
  , moduleInitialSvnPath varchar2 := null
  , jobShortName varchar2
  , fileText clob
  , publicFlag number := null
  , batchShortName varchar2 := null
  , skipCheckJob number := null
);

/* pproc: loadBatchConfig(batchShortName)
  �������� �������� ��������� ������� ( ������) � �� �� XML.

  ���������:
  moduleId                    - id ������
  batchConfigXml              - xml � ������� ��������
  batchShortName              - �������� ������������ �����
                                ���� ������, �� �������������� �������� ������������
                                � ��������� short_name. ���� �� �����, ��
                                ����������� ������� ������� ������������ ����� ��
                                �������� short_name;
  batchNewFlag                - ��������� �� ���� ����� ( ��� �����������
                                ������������� �������� ����������)
  updateScheduleFlag          - ��������� �� ���������� ������������� �����
                                ( ��-��������� ����������� ���������� ������
                                  ������ �����)
  skipLoadOption              - ���� ���������� �������� ���������� ��������
                                ������� ( "1" �� ���������, �� ���������
                                ��������� ��������� �������������� ��������
                                �������)
  updateOptionValue           - ��������� �� �������� ������������ ����������

  ( <body::loadBatchConfig(batchShortName)>)
*/
procedure loadBatchConfig(
  moduleId integer
  , batchConfigXml xmltype
  , batchShortName varchar2
  , batchNewFlag number
  , updateScheduleFlag number
  , skipLoadOption number
  , updateOptionValue number
);

/* pproc: loadBatchConfig
  �������� �������� �������� ������� ( ������) � �� �� XML.

  ���������:
  moduleName                  - �������� ������ ( �������� "ModuleInfo")
  moduleSvnRoot               - ���� � ��������� �������� ����������������
                                ������ � Subversion ( ������� � �����
                                �����������, ��������
                                "Oracle/Module/ModuleInfo")
  moduleInitialSvnPath        - �������������� ���� � ��������� ��������
                                ���������������� ������ � Subversion ( �������
                                � ����� ����������� � ������ ����� ������, �
                                ������� �� ��� ������, ��������
                                "Oracle/Module/ModuleInfo@711")
  xmlText                     - ����� xml � ������� ��������
  updateScheduleFlag          - ��������� �� ���������� ������������� �����
                                ( ��-��������� ����������� ���������� ������
                                  ������ �����)
  skipLoadOption              - ���� ���������� �������� ���������� ��������
                                ������� ( "1" �� ���������, �� ���������
                                ��������� ��������� �������������� ��������
                                �������)
  updateOptionValue           - ��������� �� �������� ������������ ����������

  ( <body::loadBatchConfig>)
*/
procedure loadBatchConfig(
  moduleName varchar2 := null
  , moduleSvnRoot varchar2 := null
  , moduleInitialSvnPath varchar2 := null
  , xmlText clob
  , updateScheduleFlag number := null
  , skipLoadOption number := null
  , updateOptionValue number := null
);

/* pproc: loadBatch(moduleId)
  �������� ��������� ������� ( �����) � �� �� XML.

  ���������:
  moduleId                    - id ������
  batchShortName              - �������� ������������ ��������� ������� ( �����)
                                ( ������ ��������������� ������ XML)
  xmlText                     - ���������� ��������� ������� � ���� xml
  updateScheduleFlag          - ��������� �� ���������� ������������� �����
                                ( ��-��������� ����������� ���������� ������
                                  ������ �����)
  skipLoadOption              - ���� ���������� �������� ���������� ��������
                                ������� ( "1" �� ���������, �� ���������
                                ��������� ��������� ��������������� ��������
                                �������)
  updateOptionValue           - ��������� �� �������� ������������ ����������

  ( <body::loadBatch(moduleId)>)
*/
procedure loadBatch(
  moduleId integer
  , batchShortName varchar2
  , xmlText clob
  , updateScheduleFlag number := null
  , skipLoadOption number := null
  , updateOptionValue number := null
);

/* pproc: loadBatch
  �������� ��������� ������� ( �����) � �� �� XML.

  ���������:
  moduleName                  - �������� ������ ( �������� "ModuleInfo")
  moduleSvnRoot               - ���� � ��������� �������� ����������������
                                ������ � Subversion ( ������� � �����
                                �����������, ��������
                                "Oracle/Module/ModuleInfo")
  moduleInitialSvnPath        - �������������� ���� � ��������� ��������
                                ���������������� ������ � Subversion ( �������
                                � ����� ����������� � ������ ����� ������, �
                                ������� �� ��� ������, ��������
                                "Oracle/Module/ModuleInfo@711")
  batchShortName              - �������� ������������ ��������� ������� ( �����)
                                ( ������ ��������������� ������ XML)
  xmlText                     - ���������� ��������� ������� � ���� xml
  updateScheduleFlag          - ��������� �� ���������� ������������� �����
                                ( ��-��������� ����������� ���������� ������
                                  ������ �����)
  skipLoadOption              - ���� ���������� �������� ���������� ��������
                                ������� ( "1" �� ���������, �� ���������
                                ��������� ��������� ��������������� ��������
                                �������)
  updateOptionValue           - ��������� �� �������� ������������ ����������

  ( <body::loadBatch>)
*/
procedure loadBatch(
  moduleName varchar2 := null
  , moduleSvnRoot varchar2 := null
  , moduleInitialSvnPath varchar2 := null
  , batchShortName varchar2
  , xmlText clob
  , updateScheduleFlag number := null
  , skipLoadOption number := null
  , updateOptionValue number := null
);

/* pproc: renameBatch( INTERNAL)
  ��������������� �������� �������.

  ���������:
  batchRec                    - ������ ��������� �������
  newBatchShortName           - ����� �������� ������������ ��������� �������

  ( <body::renameBatch( INTERNAL)>)
*/
procedure renameBatch(
  batchRec sch_batch%rowtype
  , newBatchShortName varchar2
);

/* pproc: renameBatch( batchId)
  ��������������� �������� �������.

  ���������:
  batchId                     - Id ��������� �������
  newBatchShortName           - ����� �������� ������������ ��������� �������

  ( <body::renameBatch( batchId)>)
*/
procedure renameBatch(
  batchId integer
  , newBatchShortName varchar2
);

/* pproc: renameBatch
  ��������������� �������� �������.

  ���������:
  batchShortName              - �������� ������������ ��������� �������
  newBatchShortName           - ����� �������� ������������ ��������� �������

  ( <body::renameBatch>)
*/
procedure renameBatch(
  batchShortName varchar2
  , newBatchShortName varchar2
);

/* pproc: deleteBatch(batchId)
  �������� �����.

  ���������:
  batchId                     - id �����

  ( <body::deleteBatch(batchId)>)
*/
procedure deleteBatch(
  batchId integer
);

/* pproc: deleteBatch
  �������� �����.

  ���������:
  batchShortName              - �������� ������������ �����
  activatedFlag               - ���� �������� �������������� ������
                                ( 1 - ������� �������������� ����
                                  0 - ������� ���������������� ����)

  ( <body::deleteBatch>)
*/
procedure deleteBatch(
  batchShortName varchar2
  , activatedFlag number := 0
);

/* pproc deleteModuleBatch
  �������� ���� ������, ������������� ������
  ������������ ��� �������� ������, ������������� ������ ��� ��� �������������
  
  ���������:
  moduleName                  - ������������ ������
*/
procedure deleteModuleBatch(
  moduleName varchar2 
);



/* group: �������� ������ �� �� */

/* pfunc: createBatchConfigXml
  �������� �������� ����� � XML.

  ���������:
  batchShortName              - �������� ������������ �����
  seperateFileFlag            - �������� �� ����������� xml ���������
                                ( ��� batch.xml)
                                ( 1 ��, 0 ��� ( �� ���������))

  ( <body::createBatchConfigXml>)
*/
function createBatchConfigXml(
  batchShortName varchar2
  , separateFileFlag integer := null
)
return clob;

/* pproc: unloadBatchConfigXml
  �������� �������� ����� � XML-����.

  ���������:
  batchShortName              - �������� ������������ �����
  filePath                    - ���� � ����� ��� �������

  ( <body::unloadBatchConfigXml>)
*/
procedure unloadBatchConfigXml(
  batchShortName varchar2
  , filePath varchar2
);

/* pfunc: createBatchXml
  �������� ������ ����� � XML.

  ���������:
  batchShortName              - �������� ������������ �����
  skipConfigFlag              - ���������� �� ��������� �����
                                ( ��-��������� ���������)

  ( <body::createBatchXml>)
*/
function createBatchXml(
  batchShortName varchar2
  , skipConfigFlag number := null
)
return clob;

/* pproc: unloadBatchXml
  �������� ������ ����� � XML-����.

  ���������:
  batchShortName              - �������� ������������ �����
  filePath                    - ���� � ����� ��� �������
  skipConfigFlag              - ���������� �� ��������� �����
                                ( ��-��������� ���������)

  ( <body::unloadBatchXml>)
*/
procedure unloadBatchXml(
  batchShortName varchar2
  , filePath varchar2
  , skipConfigFlag number := null
);

/* pfunc: createJobText
  �������������� ������ ������� ( job) � ��������� ������.

  ���������:
  jobId                       - id ������� ( job)
  xmlText                     - ���������� ����� xml

  ( <body::createJobText>)
*/
function createJobText(
  jobId integer
)
return clob;

/* pproc: unloadJob(filePath)
  �������� ������ ������� ( job) � ����.

  ���������:
  jobId                       - id ������� ( job)
  filePath                    - ���� � ����� ��� ��������

  ( <body::unloadJob(filePath)>)
*/
procedure unloadJob(
  jobId integer
  , filePath varchar2
);

/* pproc: unloadBatch
  �������� ������ �����.

  ���������:
  batchShortNameList          - ������ �������� ������������ ������ ����� ','
  batchParentPath             - �������� ���������� ��� ������
  publicJobPath               - ���������� ��� ��������� job-��
                                � ������ �������������� ������ �����
  configPath                  - ���������� ��� �������� �������� ������
                                ��-��������� ��������� ����������� ������ �
                                ������� �����.

  ( <body::unloadBatch>)
*/
procedure unloadBatch(
  batchShortNameList varchar2
  , batchParentPath varchar2
  , publicJobPath varchar2
  , configPath varchar2 := null
);

end pkg_SchedulerLoad;
/
