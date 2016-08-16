-- ��� Oracle 11.2 � ���� ��� ������������ ���� ������������ ����� "force"
-- � create type, ��� ����� ������ ������ ������������ "drop type force"
set define on

@oms-default forceOption "' || case when to_number( '&_O_RELEASE') >= 1102000000 then 'force' else '--' end || '"

@oms-default dropTypeScript "' || case when '&forceOption' = '--' then './oms-drop-type.sql' else '' end || '"

@oms-run "&dropTypeScript" opt_option_list_t

create or replace type
  opt_option_list_t
&forceOption
as object
(
/* db object type: opt_option_list_t
  ����� ����������� ���������� ( ��������� ��� ���������� �������).

  SVN root: Oracle/Module/Option
*/



/* group: �������� ���������� */

/* ivar: moduleId
  Id ������, � �������� ��������� ���������.
*/
moduleId integer,

/* ivar: objectShortName
  ������� ������������ ������� ������, � �������� ��������� ���������
  ( null ���� ��������� ��������� �� ����� ������).
*/
objectShortName varchar2(100),

/* ivar: objectTypeId
  Id ���� ������� ( null ��� ���������� �������).
*/
objectTypeId integer,

/* ivar: usedOperatorId
  Id ���������, ��� �������� ����� �������������� �������� ( null ���
  �����������).
*/
usedOperatorId integer,



/* group: ���������� ���������� */

/* ivar: logger
  ����� �������
*/
logger lg_logger_t,



/* group: ������� */



/* group: ���������� ���������� */

/* pproc: initialize
  �������������� ��������� �������.

  ���������:
  moduleId                    - Id ������, � �������� ��������� ���������
  objectShortName             - ������� ������������ ������� ������, � ��������
                                ��������� ��������� ( �� ��������� �����������
                                �� ����� ������)
  objectTypeShortName         - ������� ������������ ���� �������
                                ( ����� ��������� ���� ������ objectShortName,
                                  �� ��������� �����������)
  objectTypeModuleId          - Id ������, � �������� ��������� ��� �������
                                ( �� ��������� � ���� �� ������, ��� �
                                  ���������)
  usedOperatorId              - Id ���������, ��� �������� �����
                                �������������� ��������
                                ( null ��� ����������� ( �� ���������))

  ( <body::initialize>)
*/
member procedure initialize(
  moduleId integer
  , objectShortName varchar2 := null
  , objectTypeShortName varchar2 := null
  , objectTypeModuleId integer := null
  , usedOperatorId integer := null
),



/* group: ������ ������� ����� ��������� */

/* pfunc: getFullAccessLevelCode
  ���������� ��� ������ ������� "������ ������".

  ( <body::getFullAccessLevelCode>)
*/
static function getFullAccessLevelCode
return varchar2,

/* pfunc: getReadAccessLevelCode
  ���������� ��� ������ ������� "������ ��� ������".

  ( <body::getReadAccessLevelCode>)
*/
static function getReadAccessLevelCode
return varchar2,

/* pfunc: getValueAccessLevelCode
  ���������� ��� ������ ������� "��������� ��������".

  ( <body::getValueAccessLevelCode>)
*/
static function getValueAccessLevelCode
return varchar2,



/* group: ���� �������� ���������� */

/* pfunc: getDateValueTypeCode
  ���������� ��� ���� �������� "���� ( �� ��������)".

  ( <body::getDateValueTypeCode>)
*/
static function getDateValueTypeCode
return varchar2,

/* pfunc: getNumberValueTypeCode
  ���������� ��� ���� �������� "�����".

  ( <body::getNumberValueTypeCode>)
*/
static function getNumberValueTypeCode
return varchar2,

/* pfunc: getStringValueTypeCode
  ���������� ��� ���� �������� "������".

  ( <body::getStringValueTypeCode>)
*/
static function getStringValueTypeCode
return varchar2,



/* group: ���� �������� */

/* pfunc: getPlsqlObjectTypeSName
  ���������� ������� ������������ ���� ������� "PL/SQL ������".

  ( <body::getPlsqlObjectTypeSName>)
*/
static function getPlsqlObjectTypeSName
return varchar2,



/* group: ��������� �������� ��������� */

/* pproc: updateDateValue
  �������� �������� ������������ ��������� ���� ����.

  ���������:
  valueId                     - Id ��������
  dateValue                   - �������� ��������� ���� ����
  valueIndex                  - ������ �������� � ������ ��������
                                ( ������� � 1, 1 ����� ����� ��������� ���
                                ��������� �������� ���������, �� �������������
                                ������ ��������, 0 ��� ���������� �������� �
                                ������ ������, -1 ��� ���������� �������� �
                                ����� ������, ���� ������ ������ ����� ��������
                                � ������, �� ����������� �������������
                                null-��������, null � ������ ��������� �����
                                �������� ( ��� ���� � ������ ������ ��������
                                ���������� ������ �� ������ ����������
                                ��������))
                                ( �� ��������� null)
  operatorId                  - Id ��������� ( �� ��������� �������)

  ( <body::updateDateValue>)
*/
static procedure updateDateValue(
  valueId integer
  , dateValue date
  , valueIndex integer := null
  , operatorId integer := null
),

/* pproc: updateNumberValue
  �������� �������� �������� ������������ ���������.

  ���������:
  valueId                     - Id ��������
  numberValue                 - �������� �������� ���������
  valueIndex                  - ������ �������� � ������ ��������
                                ( ������� � 1, 1 ����� ����� ��������� ���
                                ��������� �������� ���������, �� �������������
                                ������ ��������, 0 ��� ���������� �������� �
                                ������ ������, -1 ��� ���������� �������� �
                                ����� ������, ���� ������ ������ ����� ��������
                                � ������, �� ����������� �������������
                                null-��������, null � ������ ��������� �����
                                �������� ( ��� ���� � ������ ������ ��������
                                ���������� ������ �� ������ ����������
                                ��������))
                                ( �� ��������� null)
  operatorId                  - Id ��������� ( �� ��������� �������)

  ( <body::updateNumberValue>)
*/
static procedure updateNumberValue(
  valueId integer
  , numberValue number
  , valueIndex integer := null
  , operatorId integer := null
),

/* pproc: updateStringValue
  �������� ��������� �������� ������������ ���������.

  ���������:
  valueId                     - Id ��������
  stringValue                 - ��������� �������� ���������
  valueIndex                  - ������ �������� � ������ ��������
                                ( ������� � 1, 1 ����� ����� ��������� ���
                                ��������� �������� ���������, �� �������������
                                ������ ��������, 0 ��� ���������� �������� �
                                ������ ������, -1 ��� ���������� �������� �
                                ����� ������, ���� ������ ������ ����� ��������
                                � ������, �� ����������� �������������
                                null-��������, null � ������ ��������� �����
                                �������� ( ��� ���� � ������ ������ ��������
                                ���������� ������ �� ������ ����������
                                ��������))
                                ( �� ��������� null)
  operatorId                  - Id ��������� ( �� ��������� �������)

  ( <body::updateStringValue>)
*/
static procedure updateStringValue(
  valueId integer
  , stringValue varchar2
  , valueIndex integer := null
  , operatorId integer := null
),



/* group: �������� �������� �� value_id */

/* pproc: deleteValue( VALUE_ID)
  ������� �������� ������������ ���������.

  ���������:
  valueId                     - Id ��������
  operatorId                  - Id ��������� ( �� ��������� �������)

  ( <body::deleteValue( VALUE_ID)>)
*/
static procedure deleteValue(
  valueId integer
  , operatorId integer := null
),



/* group: ������������ */

/* pfunc: opt_option_list_t
  ������� ����� ����������� ���������� � ������������� ��� ��������.

  ���������:
  findModuleString            - ������ ��� ������ ������ (
                                ����� ��������� � ����� �� ���� ���������
                                ������: ���������, ����� � ��������� ��������,
                                �������������� ����� � ��������� �������� �
                                Subversion)
  objectShortName             - ������� ������������ ������� ������, � ��������
                                ��������� ��������� ( �� ��������� �����������
                                �� ����� ������)
  objectTypeShortName         - ������� ������������ ���� �������
                                ( ����� ��������� ���� ������ objectShortName,
                                  �� ��������� �����������)
  objectTypeFindModuleString  - ������ ��� ������ ������ ���� �������
                                ( ���������� findModuleString, �� ���������
                                  �����������)
  usedOperatorId              - Id ���������, ��� �������� �����
                                �������������� ��������
                                ( null ��� ����������� ( �� ���������))
  moduleName                  - ������������ ������ ( �������� "ModuleInfo")
  moduleSvnRoot               - ���� � ��������� �������� ������ � Subversion
                                ( ������� � ����� �����������, ��������
                                "Oracle/Module/ModuleInfo")
  objectTypeModuleName        - ������������ ������ ���� �������
                                ( ���������� moduleName, �� ���������
                                  �����������)
  objectTypeModuleSvnRoot     - ���� � ��������� �������� ������ ���� �������
                                � Subversion ( ���������� moduleSvnRoot, ��
                                ��������� �����������)

  ���������:
  - ��� ����������� ������ ������ ���� ����� ���� �� ����������
    findModuleString, moduleName, moduleSvnRoot � ������ �� ����
    ������ ������������ ����������, ����� ����� ��������� ����������
    ( �� �� ����� �������� ���������� ����������� ������ ���� �������);
  - ���� �� ������ ��������� ��� ����������� ������ ���� �������, �� ���������,
    ��� ��� ������� ��������� � ���� �� ������, ��� � ���������;

  ( <body::opt_option_list_t>)
*/
constructor function opt_option_list_t(
  findModuleString varchar2 := null
  , objectShortName varchar2 := null
  , objectTypeShortName varchar2 := null
  , objectTypeFindModuleString varchar2 := null
  , usedOperatorId integer := null
  , moduleName varchar2 := null
  , moduleSvnRoot varchar2 := null
  , objectTypeModuleName varchar2 := null
  , objectTypeModuleSvnRoot varchar2 := null
)
return self as result,

/* pfunc: opt_option_list_t( moduleId)
  ������� ����� ����������� ���������� � ������������� ��� ��������.

  ���������:
  moduleId                    - Id ������, � �������� ��������� ���������
  objectShortName             - ������� ������������ ������� ������, � ��������
                                ��������� ��������� ( �� ��������� �����������
                                �� ����� ������)
  objectTypeShortName         - ������� ������������ ���� �������
                                ( ����� ��������� ���� ������ objectShortName,
                                  �� ��������� �����������)
  objectTypeModuleId          - Id ������, � �������� ��������� ��� �������
                                ( �� ��������� � ���� �� ������, ��� �
                                  ���������)
  usedOperatorId              - Id ���������, ��� �������� �����
                                �������������� ��������
                                ( null ��� ����������� ( �� ���������))

  ( <body::opt_option_list_t( moduleId)>)
*/
constructor function opt_option_list_t(
  moduleId integer
  , objectShortName varchar2 := null
  , objectTypeShortName varchar2 := null
  , objectTypeModuleId integer := null
  , usedOperatorId integer := null
)
return self as result,



/* group: ��������������� ������� */

/* pfunc: existsOption
  ��������� ������� ������������ ���������.

  ���������:
  optionShortName             - ������� ������������ ���������

  �������:
  1 � ������ ������� ���������, ����� 0.

  ( <body::existsOption>)
*/
member function existsOption(
  optionShortName varchar2
)
return integer,

/* pfunc: getModuleId
  ���������� Id ������, � �������� ��������� ���������.

  �������:
  Id ������ ( �� ������� mod_module ������ ModuleInfo).

  ( <body::getModuleId>)
*/
member function getModuleId
return integer,

/* pfunc: getObjectShortName
  ���������� ������� ������������ ������� ������, � �������� ��������� ���������.

  �������:
  ������� ������������ ������� ( null ���� ��������� ��������� �� ����� ������).

  ( <body::getObjectShortName>)
*/
member function getObjectShortName
return varchar2,

/* pfunc: getObjectTypeId
  ���������� Id ���� �������, � �������� ��������� ���������.

  �������:
  Id ���� ������� ( null ��� ���������� �������).

  ( <body::getObjectTypeId>)
*/
member function getObjectTypeId
return integer,

/* pfunc: getObjectTypeId( objectTypeShortName)
  ���������� Id ���� �������.

  ���������:
  objectTypeShortName         - ������� ������������ ���� �������
  raiseNotFoundFlag           - ����������� �� ���������� � ������ ����������
                                ���� ������� ( 1 ��, 0 ��� ( �� ���������))

  �������:
  Id ���� �������.

  ���������:
  - ���������, ��� ��� ������� ��������� � ������, ��� �������� ��� ������
    ������� ��������� ������� opt_option_list_t;

  ( <body::getObjectTypeId( objectTypeShortName)>)
*/
member function getObjectTypeId(
  objectTypeShortName varchar2
  , raiseNotFoundFlag integer := null
)
return integer,

/* pfunc: getOptionId
  ���������� Id ������������ ���������.

  ���������:
  optionShortName             - ������� ������������ ���������
  raiseNotFoundFlag           - ����������� �� ���������� � ������ ����������
                                ��������� ( 1 �� ( �� ���������), 0 ���)

  �������:
  Id ��������� ���� null, ���� �������� ��
  ������ � �������� raiseNotFoundFlag ����� 0.

  ( <body::getOptionId>)
*/
member function getOptionId(
  optionShortName varchar2
  , raiseNotFoundFlag integer := null
)
return integer,

/* pfunc: getUsedOperatorId
  Id ���������, ��� �������� ����� �������������� ��������.

  �������:
  Id ��������� ( null ��� �����������).

  ( <body::getUsedOperatorId>)
*/
member function getUsedOperatorId
return integer,

/* pfunc: getValueId
  ���������� Id ���������� �������� ( ������ ��������) ������������ ���������.

  ���������:
  optionShortName             - ������� ������������ ���������
  prodValueFlag               - ���� ������������� �������� ������ �
                                ������������ ( ���� ��������) ��
                                ( 1 ������ � ������������ ��, 0 ������ �
                                �������� ��, null ��� �����������)
  instanceName                - ��� ���������� ��, � ������� �����
                                �������������� ��������
                                ( null ��� ����������� ( �� ���������))
  raiseNotFoundFlag           - ����������� �� ���������� � ������ ����������
                                ��������� ( 1 �� ( �� ���������), 0 ���)

  �������:
  Id �������� ( �� ������� <opt_value>) ���� null, ���� ��������� ��������
  �� ������.

  ( <body::getValueId>)
*/
member function getValueId(
  optionShortName varchar2
  , prodValueFlag integer
  , instanceName varchar2 := null
  , raiseNotFoundFlag integer := null
)
return integer,

/* pfunc: getValueId( USED)
  ���������� Id ������������� � ������� �� �������� ( ������ ��������)
  ������������ ���������.

  ���������:
  optionShortName             - ������� ������������ ���������
  raiseNotFoundFlag           - ����������� �� ���������� � ������ ����������
                                ��������� ( 1 �� ( �� ���������), 0 ���)

  �������:
  Id �������� ( �� ������� <opt_value>) ���� null, ���� ����������� ���
  ������������� �������� ��������� �� ������.

  ( <body::getValueId( USED)>)
*/
member function getValueId(
  optionShortName varchar2
  , raiseNotFoundFlag integer := null
)
return integer,

/* pfunc: getValueCount
  ���������� ����� ��������� �������� ������������ ���������.

  ���������:
  optionShortName             - ������� ������������ ���������
  prodValueFlag               - ���� ������������� �������� ������ �
                                ������������ ( ���� ��������) ��
                                ( 1 ������ � ������������ ��, 0 ������ �
                                �������� ��, null ��� �����������)
  instanceName                - ��� ���������� ��, � ������� �����
                                �������������� ��������
                                ( null ��� ����������� ( �� ���������))
  raiseNotFoundFlag           - ����������� �� ���������� � ������ ����������
                                ��������� ( 1 �� ( �� ���������), 0 ���)

  �������:
  0 ���� �������� ( � �.�. null) �� ������, ����� ������������� ����� ��������
  �������� ( 1 ���� ������ �������� ��� ���������, �� ������������� ������
  ��������, ���� ����� �������� � ������ �������� ���������).

  ( <body::getValueCount>)
*/
member function getValueCount(
  optionShortName varchar2
  , prodValueFlag integer
  , instanceName varchar2 := null
  , raiseNotFoundFlag integer := null
)
return integer,

/* pfunc: getValueCount( USED)
  ���������� ����� ������������ � ������� �� �������� ������������ ���������.

  ���������:
  optionShortName             - ������� ������������ ���������
  raiseNotFoundFlag           - ����������� �� ���������� � ������ ����������
                                ��������� ( 1 �� ( �� ���������), 0 ���)

  �������:
  0 ���� �������� ( � �.�. null) �� ������, ����� ������������� ����� ��������
  �������� ( 1 ���� ������ �������� ��� ���������, �� ������������� ������
  ��������, ���� ����� �������� � ������ �������� ���������).

  ( <body::getValueCount( USED)>)
*/
member function getValueCount(
  optionShortName varchar2
  , raiseNotFoundFlag integer := null
)
return integer,

/* pfunc: getValueListSeparator
  ���������� ������, ������������ � �������� ����������� � ��������� ������
  �������� ������������ ���������.

  ���������:
  optionShortName             - ������� ������������ ���������
  prodValueFlag               - ���� ������������� �������� ������ �
                                ������������ ( ���� ��������) ��
                                ( 1 ������ � ������������ ��, 0 ������ �
                                �������� ��, null ��� �����������)
  instanceName                - ��� ���������� ��, � ������� �����
                                �������������� ��������
                                ( null ��� ����������� ( �� ���������))
  raiseNotFoundFlag           - ����������� �� ���������� � ������ ����������
                                ��������� ( 1 �� ( �� ���������), 0 ���)

  �������:
  ������, ������������ � �������� ����������� � ������ ��������, ���� null,
  ���� ��� ��������� �� ������������ ������ �������� ��� �������� �� ������.

  ( <body::getValueListSeparator>)
*/
member function getValueListSeparator(
  optionShortName varchar2
  , prodValueFlag integer
  , instanceName varchar2 := null
  , raiseNotFoundFlag integer := null
)
return varchar2,

/* pfunc: getValueListSeparator( USED)
  ���������� ������, ������������ � �������� ����������� � ������������ �
  ������� �� ������ �������� ������������ ���������.

  ���������:
  optionShortName             - ������� ������������ ���������
  raiseNotFoundFlag           - ����������� �� ���������� � ������ ����������
                                ��������� ( 1 �� ( �� ���������), 0 ���)

  �������:
  ������, ������������ � �������� ����������� � ������ ��������, ���� null,
  ���� ��� ��������� �� ������������ ������ �������� ��� �������� �� ������.

  ( <body::getValueListSeparator( USED)>)
*/
member function getValueListSeparator(
  optionShortName varchar2
  , raiseNotFoundFlag integer := null
)
return varchar2,



/* group: ���������� ��������� */

/* pproc: addDate
  ��������� ����������� �������� �� ��������� ���� ����, ���� �� �� ��� ������
  �����.

  ���������:
  optionShortName             - ������� ������������ ���������
  optionName                  - ������������ ���������
  accessLevelCode             - ��� ������ ������� � ��������� �����
                                ���������������� ���������
                                ( �� ��������� ������ ������)
  optionDescription           - �������� ���������
                                ( �� ��������� �����������)
  instanceName                - ��� ���������� ��, � ������� �����
                                �������������� ��������
                                ( null ��� ����������� ( �� ���������))
  dateValue                   - �������� ��������� ���� ����
                                ( �� ��������� null)
  changeValueFlag             - ���������� �������� ���������, ���� �� ���
                                ������ �����
                                ( 1 ��, 0 ��� ( �� ���������))
  operatorId                  - Id ��������� ( �� ��������� �������)

  ( <body::addDate>)
*/
member procedure addDate(
  self in opt_option_list_t
  , optionShortName varchar2
  , optionName varchar2
  , accessLevelCode varchar2 := null
  , optionDescription varchar2 := null
  , instanceName varchar2 := null
  , dateValue date := null
  , changeValueFlag integer := null
  , operatorId integer := null
),

/* pproc: addDate( TEST_PROD)
  ��������� ����������� �������� � ������������ � �������� ���������� ����
  ���� ���� �� �� ��� ������ �����.

  ���������:
  optionShortName             - ������� ������������ ���������
  optionName                  - ������������ ���������
  accessLevelCode             - ��� ������ ������� � ��������� �����
                                ���������������� ���������
                                ( �� ��������� ������ ������)
  optionDescription           - �������� ���������
                                ( �� ��������� �����������)
  instanceName                - ��� ���������� ��, � ������� �����
                                �������������� ��������
                                ( null ��� ����������� ( �� ���������))
  prodDateValue               - �������� ��������� ���� ���� ��� ������������
                                ��
  testDateValue               - �������� ��������� ���� ���� ��� �������� ��
  changeValueFlag             - ���������� �������� ���������, ���� �� ���
                                ������ �����
                                ( 1 ��, 0 ��� ( �� ���������))
  operatorId                  - Id ��������� ( �� ��������� �������)

  ( <body::addDate( TEST_PROD)>)
*/
member procedure addDate(
  self in opt_option_list_t
  , optionShortName varchar2
  , optionName varchar2
  , accessLevelCode varchar2 := null
  , optionDescription varchar2 := null
  , instanceName varchar2 := null
  , prodDateValue date
  , testDateValue date
  , changeValueFlag integer := null
  , operatorId integer := null
),

/* pproc: addDateList
  ��������� ����������� �������� �� ������� �������� ���� ���� ���� �� �� ���
  ������ �����.

  ���������:
  optionShortName             - ������� ������������ ���������
  optionName                  - ������������ ���������
  accessLevelCode             - ��� ������ ������� � ��������� �����
                                ���������������� ���������
                                ( �� ��������� ������ ������)
  optionDescription           - �������� ���������
                                ( �� ��������� �����������)
  instanceName                - ��� ���������� ��, � ������� �����
                                �������������� ��������
                                ( null ��� ����������� ( �� ���������))
  valueList                   - ������ �� ������� �������� ���������
                                ( �� ��������� null)
  listSeparator               - ������, ������������ � �������� ����������� �
                                ������ �� ������� ��������
                                ( �� ��������� ������������ ";")
  valueFormat                 - ������ ��������� � ������ �� ������� ��������
                                ( �� ��������� ������������
                                "yyyy-mm-dd hh24:mi:ss" � ������������ ���������
                                �������)
  changeValueFlag             - ���������� �������� ���������, ���� �� ���
                                ������ �����
                                ( 1 ��, 0 ��� ( �� ���������))
  operatorId                  - Id ��������� ( �� ��������� �������)

  ���������:
  - ������ ������ � �������� ������ �������� ��������������� ��� ������ ��
    ������ �������� null;

  ( <body::addDateList>)
*/
member procedure addDateList(
  self in opt_option_list_t
  , optionShortName varchar2
  , optionName varchar2
  , accessLevelCode varchar2 := null
  , optionDescription varchar2 := null
  , instanceName varchar2 := null
  , valueList varchar2 := null
  , listSeparator varchar2 := null
  , valueFormat varchar2 := null
  , changeValueFlag integer := null
  , operatorId integer := null
),

/* pproc: addDateList( TEST_PROD)
  ��������� ����������� �������� � ������������ � �������� �������� ��������
  ���� ���� ���� �� �� ��� ������ �����.

  ���������:
  optionShortName             - ������� ������������ ���������
  optionName                  - ������������ ���������
  accessLevelCode             - ��� ������ ������� � ��������� �����
                                ���������������� ���������
                                ( �� ��������� ������ ������)
  optionDescription           - �������� ���������
                                ( �� ��������� �����������)
  instanceName                - ��� ���������� ��, � ������� �����
                                �������������� ��������
                                ( null ��� ����������� ( �� ���������))
  prodValueList               - ������ �� ������� �������� ��������� ���
                                ������������ ��
  testValueList               - ������ �� ������� �������� ��������� ���
                                �������� ��
  listSeparator               - ������, ������������ � �������� ����������� �
                                ������ �� ������� ��������
                                ( �� ��������� ������������ ";")
  valueFormat                 - ������ ��������� � ������ �� ������� ��������
                                ( �� ��������� ������������
                                "yyyy-mm-dd hh24:mi:ss" � ������������ ���������
                                �������)
  changeValueFlag             - ���������� �������� ���������, ���� �� ���
                                ������ �����
                                ( 1 ��, 0 ��� ( �� ���������))
  operatorId                  - Id ��������� ( �� ��������� �������)

  ���������:
  - ������ ������ � �������� ������ �������� ��������������� ��� ������ ��
    ������ �������� null;

  ( <body::addDateList( TEST_PROD)>)
*/
member procedure addDateList(
  self in opt_option_list_t
  , optionShortName varchar2
  , optionName varchar2
  , accessLevelCode varchar2 := null
  , optionDescription varchar2 := null
  , instanceName varchar2 := null
  , prodValueList varchar2
  , testValueList varchar2
  , listSeparator varchar2 := null
  , valueFormat varchar2 := null
  , changeValueFlag integer := null
  , operatorId integer := null
),

/* pproc: addNumber
  ��������� ����������� �������� � �������� ���������, ���� �� �� ��� ������
  �����.

  ���������:
  optionShortName             - ������� ������������ ���������
  optionName                  - ������������ ���������
  accessLevelCode             - ��� ������ ������� � ��������� �����
                                ���������������� ���������
                                ( �� ��������� ������ ������)
  optionDescription           - �������� ���������
                                ( �� ��������� �����������)
  instanceName                - ��� ���������� ��, � ������� �����
                                �������������� ��������
                                ( null ��� ����������� ( �� ���������))
  numberValue                 - �������� �������� ���������
                                ( �� ��������� null)
  changeValueFlag             - ���������� �������� ���������, ���� �� ���
                                ������ �����
                                ( 1 ��, 0 ��� ( �� ���������))
  operatorId                  - Id ��������� ( �� ��������� �������)

  ( <body::addNumber>)
*/
member procedure addNumber(
  self in opt_option_list_t
  , optionShortName varchar2
  , optionName varchar2
  , accessLevelCode varchar2 := null
  , optionDescription varchar2 := null
  , instanceName varchar2 := null
  , numberValue number := null
  , changeValueFlag integer := null
  , operatorId integer := null
),

/* pproc: addNumber( TEST_PROD)
  ��������� ����������� �������� � ������������ � �������� ��������� ����������
  ���� �� �� ��� ������ �����.

  ���������:
  optionShortName             - ������� ������������ ���������
  optionName                  - ������������ ���������
  accessLevelCode             - ��� ������ ������� � ��������� �����
                                ���������������� ���������
                                ( �� ��������� ������ ������)
  optionDescription           - �������� ���������
                                ( �� ��������� �����������)
  instanceName                - ��� ���������� ��, � ������� �����
                                �������������� ��������
                                ( null ��� ����������� ( �� ���������))
  prodNumberValue             - �������� �������� ��������� ��� ������������
                                ��
  testNumberValue             - �������� �������� ��������� ��� �������� ��
  changeValueFlag             - ���������� �������� ���������, ���� �� ���
                                ������ �����
                                ( 1 ��, 0 ��� ( �� ���������))
  operatorId                  - Id ��������� ( �� ��������� �������)

  ( <body::addNumber( TEST_PROD)>)
*/
member procedure addNumber(
  self in opt_option_list_t
  , optionShortName varchar2
  , optionName varchar2
  , accessLevelCode varchar2 := null
  , optionDescription varchar2 := null
  , instanceName varchar2 := null
  , prodNumberValue number
  , testNumberValue number
  , changeValueFlag integer := null
  , operatorId integer := null
),

/* pproc: addNumberList
  ��������� ����������� �������� �� ������� �������� �������� ���� �� �� ���
  ������ �����.

  ���������:
  optionShortName             - ������� ������������ ���������
  optionName                  - ������������ ���������
  accessLevelCode             - ��� ������ ������� � ��������� �����
                                ���������������� ���������
                                ( �� ��������� ������ ������)
  optionDescription           - �������� ���������
                                ( �� ��������� �����������)
  instanceName                - ��� ���������� ��, � ������� �����
                                �������������� ��������
                                ( null ��� ����������� ( �� ���������))
  valueList                   - ������ �� ������� �������� ���������
                                ( �� ��������� null)
  listSeparator               - ������, ������������ � �������� ����������� �
                                ������ �� ������� ��������
                                ( �� ��������� ������������ ";")
  decimalChar                 - ���������� ����������� ��� ������ �� �������
                                �������� ��������
                                ( �� ��������� ������������ �����)
  changeValueFlag             - ���������� �������� ���������, ���� �� ���
                                ������ �����
                                ( 1 ��, 0 ��� ( �� ���������))
  operatorId                  - Id ��������� ( �� ��������� �������)

  ���������:
  - ������ ������ � �������� ������ �������� ��������������� ��� ������ ��
    ������ �������� null;

  ( <body::addNumberList>)
*/
member procedure addNumberList(
  self in opt_option_list_t
  , optionShortName varchar2
  , optionName varchar2
  , accessLevelCode varchar2 := null
  , optionDescription varchar2 := null
  , instanceName varchar2 := null
  , valueList varchar2 := null
  , listSeparator varchar2 := null
  , decimalChar varchar2 := null
  , changeValueFlag integer := null
  , operatorId integer := null
),

/* pproc: addNumberList( TEST_PROD)
  ��������� ����������� �������� � ������������ � �������� �������� ��������
  �������� ���� �� �� ��� ������ �����.

  ���������:
  optionShortName             - ������� ������������ ���������
  optionName                  - ������������ ���������
  accessLevelCode             - ��� ������ ������� � ��������� �����
                                ���������������� ���������
                                ( �� ��������� ������ ������)
  optionDescription           - �������� ���������
                                ( �� ��������� �����������)
  instanceName                - ��� ���������� ��, � ������� �����
                                �������������� ��������
                                ( null ��� ����������� ( �� ���������))
  prodValueList               - ������ �� ������� �������� ��������� ���
                                ������������ ��
  testValueList               - ������ �� ������� �������� ��������� ���
                                �������� ��
  listSeparator               - ������, ������������ � �������� ����������� �
                                ������ �� ������� ��������
                                ( �� ��������� ������������ ";")
  decimalChar                 - ���������� ����������� ��� ������ �� �������
                                �������� ��������
                                ( �� ��������� ������������ �����)
  changeValueFlag             - ���������� �������� ���������, ���� �� ���
                                ������ �����
                                ( 1 ��, 0 ��� ( �� ���������))
  operatorId                  - Id ��������� ( �� ��������� �������)

  ���������:
  - ������ ������ � �������� ������ �������� ��������������� ��� ������ ��
    ������ �������� null;

  ( <body::addNumberList( TEST_PROD)>)
*/
member procedure addNumberList(
  self in opt_option_list_t
  , optionShortName varchar2
  , optionName varchar2
  , accessLevelCode varchar2 := null
  , optionDescription varchar2 := null
  , instanceName varchar2 := null
  , prodValueList varchar2
  , testValueList varchar2
  , listSeparator varchar2 := null
  , decimalChar varchar2 := null
  , changeValueFlag integer := null
  , operatorId integer := null
),

/* pproc: addString
  ��������� ����������� �������� �� ��������� ���������, ���� �� �� ��� ������
  �����.

  ���������:
  optionShortName             - ������� ������������ ���������
  optionName                  - ������������ ���������
  encryptionFlag              - ���� �������� �������� ��������� �
                                ������������� ����
                                ( 1 ��, 0 ��� ( �� ���������))
  accessLevelCode             - ��� ������ ������� � ��������� �����
                                ���������������� ���������
                                ( �� ��������� ������ ��������� �������� �
                                  ������ �������� �������� � �������������
                                  ����, ����� ������ ������)
  optionDescription           - �������� ���������
                                ( �� ��������� �����������)
  instanceName                - ��� ���������� ��, � ������� �����
                                �������������� ��������
                                ( null ��� ����������� ( �� ���������))
  stringValue                 - ��������� �������� ���������
                                ( �� ��������� null)
  changeValueFlag             - ���������� �������� ���������, ���� �� ���
                                ������ �����
                                ( 1 ��, 0 ��� ( �� ���������))
  operatorId                  - Id ��������� ( �� ��������� �������)

  ( <body::addString>)
*/
member procedure addString(
  self in opt_option_list_t
  , optionShortName varchar2
  , optionName varchar2
  , encryptionFlag integer := null
  , accessLevelCode varchar2 := null
  , optionDescription varchar2 := null
  , instanceName varchar2 := null
  , stringValue varchar2 := null
  , changeValueFlag integer := null
  , operatorId integer := null
),

/* pproc: addString( TEST_PROD)
  ��������� ����������� �������� � ������������ � �������� ���������� ����������
  ���� �� �� ��� ������ �����.

  ���������:
  optionShortName             - ������� ������������ ���������
  optionName                  - ������������ ���������
  encryptionFlag              - ���� �������� �������� ��������� �
                                ������������� ����
                                ( 1 ��, 0 ��� ( �� ���������))
  accessLevelCode             - ��� ������ ������� � ��������� �����
                                ���������������� ���������
                                ( �� ��������� ������ ��������� �������� �
                                  ������ �������� �������� � �������������
                                  ����, ����� ������ ������)
  optionDescription           - �������� ���������
                                ( �� ��������� �����������)
  instanceName                - ��� ���������� ��, � ������� �����
                                �������������� ��������
                                ( null ��� ����������� ( �� ���������))
  prodStringValue             - ��������� �������� ��������� ��� ������������
                                ��
  testStringValue             - ��������� �������� ��������� ��� �������� ��
  changeValueFlag             - ���������� �������� ���������, ���� �� ���
                                ������ �����
                                ( 1 ��, 0 ��� ( �� ���������))
  operatorId                  - Id ��������� ( �� ��������� �������)

  ( <body::addString( TEST_PROD)>)
*/
member procedure addString(
  self in opt_option_list_t
  , optionShortName varchar2
  , optionName varchar2
  , encryptionFlag integer := null
  , accessLevelCode varchar2 := null
  , optionDescription varchar2 := null
  , instanceName varchar2 := null
  , prodStringValue varchar2
  , testStringValue varchar2
  , changeValueFlag integer := null
  , operatorId integer := null
),

/* pproc: addStringList
  ��������� ����������� �������� �� ������� ��������� �������� ���� �� �� ���
  ������ �����.

  ���������:
  optionShortName             - ������� ������������ ���������
  optionName                  - ������������ ���������
  encryptionFlag              - ���� �������� �������� ��������� �
                                ������������� ����
                                ( 1 ��, 0 ��� ( �� ���������))
  accessLevelCode             - ��� ������ ������� � ��������� �����
                                ���������������� ���������
                                ( �� ��������� ������ ��������� �������� �
                                  ������ �������� �������� � �������������
                                  ����, ����� ������ ������)
  optionDescription           - �������� ���������
                                ( �� ��������� �����������)
  instanceName                - ��� ���������� ��, � ������� �����
                                �������������� ��������
                                ( null ��� ����������� ( �� ���������))
  valueList                   - ������ �� ������� �������� ���������
                                ( �� ��������� null)
  listSeparator               - ������, ������������ � �������� ����������� �
                                ������ �� ������� ��������
                                ( �� ��������� ������������ ";")
  changeValueFlag             - ���������� �������� ���������, ���� �� ���
                                ������ �����
                                ( 1 ��, 0 ��� ( �� ���������))
  operatorId                  - Id ��������� ( �� ��������� �������)

  ���������:
  - ������ ������ � �������� ������ �������� ��������������� ��� ������ ��
    ������ �������� null;

  ( <body::addStringList>)
*/
member procedure addStringList(
  self in opt_option_list_t
  , optionShortName varchar2
  , optionName varchar2
  , encryptionFlag integer := null
  , accessLevelCode varchar2 := null
  , optionDescription varchar2 := null
  , instanceName varchar2 := null
  , valueList varchar2 := null
  , listSeparator varchar2 := null
  , changeValueFlag integer := null
  , operatorId integer := null
),

/* pproc: addStringList( TEST_PROD)
  ��������� ����������� �������� � ������������ � �������� �������� ���������
  �������� ���� �� �� ��� ������ �����.

  ���������:
  optionShortName             - ������� ������������ ���������
  optionName                  - ������������ ���������
  encryptionFlag              - ���� �������� �������� ��������� �
                                ������������� ����
                                ( 1 ��, 0 ��� ( �� ���������))
  accessLevelCode             - ��� ������ ������� � ��������� �����
                                ���������������� ���������
                                ( �� ��������� ������ ��������� �������� �
                                  ������ �������� �������� � �������������
                                  ����, ����� ������ ������)
  optionDescription           - �������� ���������
                                ( �� ��������� �����������)
  instanceName                - ��� ���������� ��, � ������� �����
                                �������������� ��������
                                ( null ��� ����������� ( �� ���������))
  prodValueList               - ������ �� ������� �������� ��������� ���
                                ������������ ��
  testValueList               - ������ �� ������� �������� ��������� ���
                                �������� ��
  listSeparator               - ������, ������������ � �������� ����������� �
                                ������ �� ������� ��������
                                ( �� ��������� ������������ ";")
  changeValueFlag             - ���������� �������� ���������, ���� �� ���
                                ������ �����
                                ( 1 ��, 0 ��� ( �� ���������))
  operatorId                  - Id ��������� ( �� ��������� �������)

  ���������:
  - ������ ������ � �������� ������ �������� ��������������� ��� ������ ��
    ������ �������� null;

  ( <body::addStringList( TEST_PROD)>)
*/
member procedure addStringList(
  self in opt_option_list_t
  , optionShortName varchar2
  , optionName varchar2
  , encryptionFlag integer := null
  , accessLevelCode varchar2 := null
  , optionDescription varchar2 := null
  , instanceName varchar2 := null
  , prodValueList varchar2
  , testValueList varchar2
  , listSeparator varchar2 := null
  , changeValueFlag integer := null
  , operatorId integer := null
),



/* group: ��������� �������� ��������� */

/* pfunc: getDate
  ���������� ��������� �������� ������������ ��������� ���� ����.

  ���������:
  optionShortName             - ������� ������������ ���������
  prodValueFlag               - ���� ������������� �������� ������ �
                                ������������ ( ���� ��������) ��
                                ( 1 ������ � ������������ ��, 0 ������ �
                                �������� ��, null ��� �����������)
  instanceName                - ��� ���������� ��, � ������� �����
                                �������������� ��������
                                ( null ��� ����������� ( �� ���������))
  valueIndex                  - ������ �������� � ������ ��������
                                ( ������� � 1, 1 ����� ����� ��������� ���
                                ��������� �������� ���������, �� �������������
                                ������ ��������, �� ��������� 1)
  raiseNotFoundFlag           - ����������� �� ���������� � ������ ����������
                                ��������� ( 1 �� ( �� ���������), 0 ���)

  �������:
  �������� ���� ����.

  ���������:
  - � ������, ���� �������� ������������ ��������� �� ������ ( � �.�. �
    ������, ���� ������ �������� � valueIndex ��������� ����� �������� �
    ������ ���� ������ 1 ���� ������ �� ������������) ������������ null;

  ( <body::getDate>)
*/
member function getDate(
  optionShortName varchar2
  , prodValueFlag integer
  , instanceName varchar2 := null
  , valueIndex integer := null
  , raiseNotFoundFlag integer := null
)
return date,

/* pfunc: getDate( USED)
  ���������� ������������ � ������� �� �������� ������������ ��������� ����
  ����.

  ���������:
  optionShortName             - ������� ������������ ���������
  valueIndex                  - ������ �������� � ������ ��������
                                ( ������� � 1, 1 ����� ����� ��������� ���
                                ��������� �������� ���������, �� �������������
                                ������ ��������, �� ��������� 1)
  raiseNotFoundFlag           - ����������� �� ���������� � ������ ����������
                                ��������� ( 1 �� ( �� ���������), 0 ���)

  �������:
  �������� ���� ����.

  ���������:
  - � ������, ���� �������� ������������ ��������� �� ������ ( � �.�. �
    ������, ���� ������ �������� � valueIndex ��������� ����� �������� �
    ������ ���� ������ 1 ���� ������ �� ������������) ������������ null;

  ( <body::getDate( USED)>)
*/
member function getDate(
  optionShortName varchar2
  , valueIndex integer := null
  , raiseNotFoundFlag integer := null
)
return date,

/* pfunc: getNumber
  ���������� ��������� �������� �������� ������������ ���������.

  ���������:
  optionShortName             - ������� ������������ ���������
  prodValueFlag               - ���� ������������� �������� ������ �
                                ������������ ( ���� ��������) ��
                                ( 1 ������ � ������������ ��, 0 ������ �
                                �������� ��, null ��� �����������)
  instanceName                - ��� ���������� ��, � ������� �����
                                �������������� ��������
                                ( null ��� ����������� ( �� ���������))
  valueIndex                  - ������ �������� � ������ ��������
                                ( ������� � 1, 1 ����� ����� ��������� ���
                                ��������� �������� ���������, �� �������������
                                ������ ��������, �� ��������� 1)
  raiseNotFoundFlag           - ����������� �� ���������� � ������ ����������
                                ��������� ( 1 �� ( �� ���������), 0 ���)

  �������:
  �������� ��������.

  ���������:
  - � ������, ���� �������� ������������ ��������� �� ������ ( � �.�. �
    ������, ���� ������ �������� � valueIndex ��������� ����� �������� �
    ������ ���� ������ 1 ���� ������ �� ������������) ������������ null;

  ( <body::getNumber>)
*/
member function getNumber(
  optionShortName varchar2
  , prodValueFlag integer
  , instanceName varchar2 := null
  , valueIndex integer := null
  , raiseNotFoundFlag integer := null
)
return number,

/* pfunc: getNumber( USED)
  ���������� ������������ � ������� �� �������� �������� ������������ ���������.

  ���������:
  optionShortName             - ������� ������������ ���������
  valueIndex                  - ������ �������� � ������ ��������
                                ( ������� � 1, 1 ����� ����� ��������� ���
                                ��������� �������� ���������, �� �������������
                                ������ ��������, �� ��������� 1)
  raiseNotFoundFlag           - ����������� �� ���������� � ������ ����������
                                ��������� ( 1 �� ( �� ���������), 0 ���)

  �������:
  �������� ��������.

  ���������:
  - � ������, ���� �������� ������������ ��������� �� ������ ( � �.�. �
    ������, ���� ������ �������� � valueIndex ��������� ����� �������� �
    ������ ���� ������ 1 ���� ������ �� ������������) ������������ null;

  ( <body::getNumber( USED)>)
*/
member function getNumber(
  optionShortName varchar2
  , valueIndex integer := null
  , raiseNotFoundFlag integer := null
)
return number,

/* pfunc: getString
  ���������� ��������� ��������� �������� ������������ ���������.

  ���������:
  optionShortName             - ������� ������������ ���������
  prodValueFlag               - ���� ������������� �������� ������ �
                                ������������ ( ���� ��������) ��
                                ( 1 ������ � ������������ ��, 0 ������ �
                                �������� ��, null ��� �����������)
  instanceName                - ��� ���������� ��, � ������� �����
                                �������������� ��������
                                ( null ��� ����������� ( �� ���������))
  valueIndex                  - ������ �������� � ������ ��������
                                ( ������� � 1, 1 ����� ����� ��������� ���
                                ��������� �������� ���������, �� �������������
                                ������ ��������, �� ��������� 1)
  raiseNotFoundFlag           - ����������� �� ���������� � ������ ����������
                                ��������� ( 1 �� ( �� ���������), 0 ���)

  �������:
  ��������� ��������.

  ���������:
  - � ������, ���� �������� ������������ ��������� �� ������ ( � �.�. �
    ������, ���� ������ �������� � valueIndex ��������� ����� �������� �
    ������ ���� ������ 1 ���� ������ �� ������������) ������������ null;

  ( <body::getString>)
*/
member function getString(
  optionShortName varchar2
  , prodValueFlag integer
  , instanceName varchar2 := null
  , valueIndex integer := null
  , raiseNotFoundFlag integer := null
)
return varchar2,

/* pfunc: getString( USED)
  ���������� ������������ � ������� �� ��������� �������� ������������
  ���������.

  ���������:
  optionShortName             - ������� ������������ ���������
  valueIndex                  - ������ �������� � ������ ��������
                                ( ������� � 1, 1 ����� ����� ��������� ���
                                ��������� �������� ���������, �� �������������
                                ������ ��������, �� ��������� 1)
  raiseNotFoundFlag           - ����������� �� ���������� � ������ ����������
                                ��������� ( 1 �� ( �� ���������), 0 ���)

  �������:
  ��������� ��������.

  ���������:
  - � ������, ���� �������� ������������ ��������� �� ������ ( � �.�. �
    ������, ���� ������ �������� � valueIndex ��������� ����� �������� �
    ������ ���� ������ 1 ���� ������ �� ������������) ������������ null;

  ( <body::getString( USED)>)
*/
member function getString(
  optionShortName varchar2
  , valueIndex integer := null
  , raiseNotFoundFlag integer := null
)
return varchar2,

/* pfunc: getValueList
  ���������� ��������� ������ �������� ������������ ���������.

  ���������:
  optionShortName             - ������� ������������ ���������
  prodValueFlag               - ���� ������������� �������� ������ �
                                ������������ ( ���� ��������) ��
                                ( 1 ������ � ������������ ��, 0 ������ �
                                �������� ��, null ��� �����������)
  instanceName                - ��� ���������� ��, � ������� �����
                                �������������� ��������
                                ( null ��� ����������� ( �� ���������))
  raiseNotFoundFlag           - ����������� �� ���������� � ������ ����������
                                ��������� ( 1 �� ( �� ���������), 0 ���)

  �������:
  ������ �� ������� �������� ( ������, ������������ � �������� �����������,
  ������������ �������� <getValueListSeparator>).

  ���������:
  - � ������, ���� ��������� �������� ������������ ��������� �� ������,
    ������������ null;

  ( <body::getValueList>)
*/
member function getValueList(
  optionShortName varchar2
  , prodValueFlag integer
  , instanceName varchar2 := null
  , raiseNotFoundFlag integer := null
)
return varchar2,

/* pfunc: getValueList( USED)
  ���������� ������������ � ������� �� ������ �������� ������������ ���������.

  ���������:
  optionShortName             - ������� ������������ ���������
  raiseNotFoundFlag           - ����������� �� ���������� � ������ ����������
                                ��������� ( 1 �� ( �� ���������), 0 ���)

  �������:
  ������ �� ������� �������� ( ������, ������������ � �������� �����������,
  ������������ �������� <getValueListSeparator( USED)>).

  ���������:
  - � ������, ���� ��������� �������� ������������ ��������� �� ������,
    ������������ null;

  ( <body::getValueList( USED)>)
*/
member function getValueList(
  optionShortName varchar2
  , raiseNotFoundFlag integer := null
)
return varchar2,



/* group: ��������� �������� ��������� */

/* pproc: setDate
  ������������� ��������� �������� ������������ ��������� ���� ����.

  ���������:
  optionShortName             - ������� ������������ ���������
  prodValueFlag               - ���� ������������� �������� ������ �
                                ������������ ( ���� ��������) ��
                                ( 1 ������ � ������������ ��, 0 ������ �
                                �������� ��, null ��� �����������)
  instanceName                - ��� ���������� ��, � ������� �����
                                �������������� ��������
                                ( null ��� ����������� ( �� ���������))
  dateValue                   - �������� ��������� ���� ����
  valueIndex                  - ������ �������� � ������ ��������
                                ( ������� � 1, 1 ����� ����� ��������� ���
                                ��������� �������� ���������, �� �������������
                                ������ ��������, 0 ��� ���������� �������� �
                                ������ ������, -1 ��� ���������� �������� �
                                ����� ������, ���� ������ ������ ����� ��������
                                � ������, �� ����������� �������������
                                null-��������, null � ������ ��������� �����
                                �������� ( ��� ���� � ������ ������ ��������
                                ���������� ������ �� ������ ����������
                                ��������))
                                ( �� ��������� null)
  operatorId                  - Id ��������� ( �� ��������� �������)

  ( <body::setDate>)
*/
member procedure setDate(
  self in opt_option_list_t
  , optionShortName varchar2
  , prodValueFlag integer
  , instanceName varchar2 := null
  , dateValue date
  , valueIndex integer := null
  , operatorId integer := null
),

/* pproc: setDate( TEST_PROD)
  ������������� ������������ � �������� �������� ������������ ��������� ����
  ����.

  ���������:
  optionShortName             - ������� ������������ ���������
  prodDateValue               - �������� ��������� ���� ���� ��� ������������
                                ��
  testDateValue               - �������� ��������� ���� ���� ��� �������� ��
  valueIndex                  - ������ �������� � ������ ��������
                                ( ������� � 1, 1 ����� ����� ��������� ���
                                ��������� �������� ���������, �� �������������
                                ������ ��������, 0 ��� ���������� �������� �
                                ������ ������, -1 ��� ���������� �������� �
                                ����� ������, ���� ������ ������ ����� ��������
                                � ������, �� ����������� �������������
                                null-��������, null � ������ ��������� �����
                                �������� ( ��� ���� � ������ ������ ��������
                                ���������� ������ �� ������ ����������
                                ��������))
                                ( �� ��������� null)
  instanceName                - ��� ���������� ��, � ������� �����
                                �������������� ��������
                                ( null ��� ����������� ( �� ���������))
  operatorId                  - Id ��������� ( �� ��������� �������)

  ( <body::setDate( TEST_PROD)>)
*/
member procedure setDate(
  self in opt_option_list_t
  , optionShortName varchar2
  , prodDateValue date
  , testDateValue date
  , valueIndex integer := null
  , instanceName varchar2 := null
  , operatorId integer := null
),

/* pproc: setDate( USED)
  ������������� ������������ � ������� �� �������� ������������ ��������� ����
  ����.

  ���������:
  optionShortName             - ������� ������������ ���������
  dateValue                   - �������� ��������� ���� ����
  valueIndex                  - ������ �������� � ������ ��������
                                ( ������� � 1, 1 ����� ����� ��������� ���
                                ��������� �������� ���������, �� �������������
                                ������ ��������, 0 ��� ���������� �������� �
                                ������ ������, -1 ��� ���������� �������� �
                                ����� ������, ���� ������ ������ ����� ��������
                                � ������, �� ����������� �������������
                                null-��������, null � ������ ��������� �����
                                �������� ( ��� ���� � ������ ������ ��������
                                ���������� ������ �� ������ ����������
                                ��������))
                                ( �� ��������� null)
  createForInstanceFlag       - ��� ���������� ������������� �������� ��������
                                ��� ��� ������������� ������ � �������
                                ���������� ��
                                ( 1 ��, 0 ��� ( �� ���������))
  operatorId                  - Id ��������� ( �� ��������� �������)

  ( <body::setDate( USED)>)
*/
member procedure setDate(
  self in opt_option_list_t
  , optionShortName varchar2
  , dateValue date
  , valueIndex integer := null
  , createForInstanceFlag integer := null
  , operatorId integer := null
),

/* pproc: setNumber
  ������������� ��������� �������� �������� ������������ ���������.

  ���������:
  optionShortName             - ������� ������������ ���������
  prodValueFlag               - ���� ������������� �������� ������ �
                                ������������ ( ���� ��������) ��
                                ( 1 ������ � ������������ ��, 0 ������ �
                                �������� ��, null ��� �����������)
  instanceName                - ��� ���������� ��, � ������� �����
                                �������������� ��������
                                ( null ��� ����������� ( �� ���������))
  numberValue                 - �������� �������� ���������
  valueIndex                  - ������ �������� � ������ ��������
                                ( ������� � 1, 1 ����� ����� ��������� ���
                                ��������� �������� ���������, �� �������������
                                ������ ��������, 0 ��� ���������� �������� �
                                ������ ������, -1 ��� ���������� �������� �
                                ����� ������, ���� ������ ������ ����� ��������
                                � ������, �� ����������� �������������
                                null-��������, null � ������ ��������� �����
                                �������� ( ��� ���� � ������ ������ ��������
                                ���������� ������ �� ������ ����������
                                ��������))
                                ( �� ��������� null)
  operatorId                  - Id ��������� ( �� ��������� �������)

  ( <body::setNumber>)
*/
member procedure setNumber(
  self in opt_option_list_t
  , optionShortName varchar2
  , prodValueFlag integer
  , instanceName varchar2 := null
  , numberValue number
  , valueIndex integer := null
  , operatorId integer := null
),

/* pproc: setNumber( TEST_PROD)
  ������������� ������������ � �������� �������� �������� ������������
  ���������.

  ���������:
  optionShortName             - ������� ������������ ���������
  prodNumberValue             - �������� �������� ��������� ��� ������������
                                ��
  testNumberValue             - �������� �������� ��������� ��� �������� ��
  valueIndex                  - ������ �������� � ������ ��������
                                ( ������� � 1, 1 ����� ����� ��������� ���
                                ��������� �������� ���������, �� �������������
                                ������ ��������, 0 ��� ���������� �������� �
                                ������ ������, -1 ��� ���������� �������� �
                                ����� ������, ���� ������ ������ ����� ��������
                                � ������, �� ����������� �������������
                                null-��������, null � ������ ��������� �����
                                �������� ( ��� ���� � ������ ������ ��������
                                ���������� ������ �� ������ ����������
                                ��������))
                                ( �� ��������� null)
  instanceName                - ��� ���������� ��, � ������� �����
                                �������������� ��������
                                ( null ��� ����������� ( �� ���������))
  operatorId                  - Id ��������� ( �� ��������� �������)

  ( <body::setNumber( TEST_PROD)>)
*/
member procedure setNumber(
  self in opt_option_list_t
  , optionShortName varchar2
  , prodNumberValue number
  , testNumberValue number
  , valueIndex integer := null
  , instanceName varchar2 := null
  , operatorId integer := null
),

/* pproc: setNumber( USED)
  ������������� ������������ � ������� �� �������� �������� ������������
  ���������.

  ���������:
  optionShortName             - ������� ������������ ���������
  numberValue                 - �������� �������� ���������
  valueIndex                  - ������ �������� � ������ ��������
                                ( ������� � 1, 1 ����� ����� ��������� ���
                                ��������� �������� ���������, �� �������������
                                ������ ��������, 0 ��� ���������� �������� �
                                ������ ������, -1 ��� ���������� �������� �
                                ����� ������, ���� ������ ������ ����� ��������
                                � ������, �� ����������� �������������
                                null-��������, null � ������ ��������� �����
                                �������� ( ��� ���� � ������ ������ ��������
                                ���������� ������ �� ������ ����������
                                ��������))
                                ( �� ��������� null)
  createForInstanceFlag       - ��� ���������� ������������� �������� ��������
                                ��� ��� ������������� ������ � �������
                                ���������� ��
                                ( 1 ��, 0 ��� ( �� ���������))
  operatorId                  - Id ��������� ( �� ��������� �������)

  ( <body::setNumber( USED)>)
*/
member procedure setNumber(
  self in opt_option_list_t
  , optionShortName varchar2
  , numberValue number
  , valueIndex integer := null
  , createForInstanceFlag integer := null
  , operatorId integer := null
),

/* pproc: setString
  ������������� ��������� ��������� �������� ������������ ���������.

  ���������:
  optionShortName             - ������� ������������ ���������
  prodValueFlag               - ���� ������������� �������� ������ �
                                ������������ ( ���� ��������) ��
                                ( 1 ������ � ������������ ��, 0 ������ �
                                �������� ��, null ��� �����������)
  instanceName                - ��� ���������� ��, � ������� �����
                                �������������� ��������
                                ( null ��� ����������� ( �� ���������))
  stringValue                 - ��������� �������� ���������
  valueIndex                  - ������ �������� � ������ ��������
                                ( ������� � 1, 1 ����� ����� ��������� ���
                                ��������� �������� ���������, �� �������������
                                ������ ��������, 0 ��� ���������� �������� �
                                ������ ������, -1 ��� ���������� �������� �
                                ����� ������, ���� ������ ������ ����� ��������
                                � ������, �� ����������� �������������
                                null-��������, null � ������ ��������� �����
                                �������� ( ��� ���� � ������ ������ ��������
                                ���������� ������ �� ������ ����������
                                ��������))
                                ( �� ��������� null)
  operatorId                  - Id ��������� ( �� ��������� �������)

  ( <body::setString>)
*/
member procedure setString(
  self in opt_option_list_t
  , optionShortName varchar2
  , prodValueFlag integer
  , instanceName varchar2 := null
  , stringValue varchar2
  , valueIndex integer := null
  , operatorId integer := null
),

/* pproc: setString( TEST_PROD)
  ������������� ������������ � �������� ��������� �������� ������������
  ���������.

  ���������:
  optionShortName             - ������� ������������ ���������
  prodStringValue             - ��������� �������� ��������� ��� ������������
                                ��
  testStringValue             - ��������� �������� ��������� ��� �������� ��
  valueIndex                  - ������ �������� � ������ ��������
                                ( ������� � 1, 1 ����� ����� ��������� ���
                                ��������� �������� ���������, �� �������������
                                ������ ��������, 0 ��� ���������� �������� �
                                ������ ������, -1 ��� ���������� �������� �
                                ����� ������, ���� ������ ������ ����� ��������
                                � ������, �� ����������� �������������
                                null-��������, null � ������ ��������� �����
                                �������� ( ��� ���� � ������ ������ ��������
                                ���������� ������ �� ������ ����������
                                ��������))
                                ( �� ��������� null)
  instanceName                - ��� ���������� ��, � ������� �����
                                �������������� ��������
                                ( null ��� ����������� ( �� ���������))
  operatorId                  - Id ��������� ( �� ��������� �������)

  ( <body::setString( TEST_PROD)>)
*/
member procedure setString(
  self in opt_option_list_t
  , optionShortName varchar2
  , prodStringValue varchar2
  , testStringValue varchar2
  , valueIndex integer := null
  , instanceName varchar2 := null
  , operatorId integer := null
),

/* pproc: setString( USED)
  ������������� ������������ � ������� �� ��������� �������� ������������
  ���������.

  ���������:
  optionShortName             - ������� ������������ ���������
  stringValue                 - ��������� �������� ���������
  valueIndex                  - ������ �������� � ������ ��������
                                ( ������� � 1, 1 ����� ����� ��������� ���
                                ��������� �������� ���������, �� �������������
                                ������ ��������, 0 ��� ���������� �������� �
                                ������ ������, -1 ��� ���������� �������� �
                                ����� ������, ���� ������ ������ ����� ��������
                                � ������, �� ����������� �������������
                                null-��������, null � ������ ��������� �����
                                �������� ( ��� ���� � ������ ������ ��������
                                ���������� ������ �� ������ ����������
                                ��������))
                                ( �� ��������� null)
  createForInstanceFlag       - ��� ���������� ������������� �������� ��������
                                ��� ��� ������������� ������ � �������
                                ���������� ��
                                ( 1 ��, 0 ��� ( �� ���������))
  operatorId                  - Id ��������� ( �� ��������� �������)

  ( <body::setString( USED)>)
*/
member procedure setString(
  self in opt_option_list_t
  , optionShortName varchar2
  , stringValue varchar2
  , valueIndex integer := null
  , createForInstanceFlag integer := null
  , operatorId integer := null
),

/* pproc: setValueList
  ������������� ��������� ������ �������� ������������ ���������.

  ���������:
  optionShortName             - ������� ������������ ���������
  prodValueFlag               - ���� ������������� �������� ������ �
                                ������������ ( ���� ��������) ��
                                ( 1 ������ � ������������ ��, 0 ������ �
                                �������� ��, null ��� �����������)
  instanceName                - ��� ���������� ��, � ������� �����
                                �������������� ��������
                                ( null ��� ����������� ( �� ���������))
  valueList                   - ������ �� ������� �������� ���������
                                ( �� ��������� null)
  listSeparator               - ������, ������������ � �������� ����������� �
                                ������ �� ������� ��������
                                ( �� ��������� ������������ ";")
  valueFormat                 - ������ ��������� � ������ �� ������� ��������
                                ���� ���� ( �� ��������� ��� ��� ������������
                                "yyyy-mm-dd hh24:mi:ss" � ������������
                                ��������� �������)
  decimalChar                 - ���������� ����������� ��� ������ �� �������
                                �������� ��������
                                ( �� ��������� ������������ �����)
  operatorId                  - Id ��������� ( �� ��������� �������)

  ���������:
  - ������ ������ � �������� ������ �������� ��������������� ��� ������ ��
    ������ �������� null;

  ( <body::setValueList>)
*/
member procedure setValueList(
  self in opt_option_list_t
  , optionShortName varchar2
  , prodValueFlag integer
  , instanceName varchar2 := null
  , valueList varchar2 := null
  , listSeparator varchar2 := null
  , valueFormat varchar2 := null
  , decimalChar varchar2 := null
  , operatorId integer := null
),

/* pproc: setValueList( TEST_PROD)
  ������������� ������������ � �������� ������ �������� ������������ ���������.

  ���������:
  optionShortName             - ������� ������������ ���������
  prodValueList               - ������ �� ������� �������� ��������� ���
                                ������������ ��
  testValueList               - ������ �� ������� �������� ��������� ���
                                �������� ��
  instanceName                - ��� ���������� ��, � ������� �����
                                �������������� ��������
                                ( null ��� ����������� ( �� ���������))
  listSeparator               - ������, ������������ � �������� ����������� �
                                ������ �� ������� ��������
                                ( �� ��������� ������������ ";")
  valueFormat                 - ������ ��������� � ������ �� ������� ��������
                                ���� ���� ( �� ��������� ��� ��� ������������
                                "yyyy-mm-dd hh24:mi:ss" � ������������
                                ��������� �������)
  decimalChar                 - ���������� ����������� ��� ������ �� �������
                                �������� ��������
                                ( �� ��������� ������������ �����)
  operatorId                  - Id ��������� ( �� ��������� �������)

  ���������:
  - ������ ������ � �������� ������ �������� ��������������� ��� ������ ��
    ������ �������� null;

  ( <body::setValueList( TEST_PROD)>)
*/
member procedure setValueList(
  self in opt_option_list_t
  , optionShortName varchar2
  , prodValueList varchar2
  , testValueList varchar2
  , instanceName varchar2 := null
  , listSeparator varchar2 := null
  , valueFormat varchar2 := null
  , decimalChar varchar2 := null
  , operatorId integer := null
),

/* pproc: setValueList( USED)
  ������������� ������������ � ������� �� ������ �������� ������������
  ���������.

  ���������:
  optionShortName             - ������� ������������ ���������
  valueList                   - ������ �� ������� �������� ���������
                                ( �� ��������� null)
  listSeparator               - ������, ������������ � �������� ����������� �
                                ������ �� ������� ��������
                                ( �� ��������� ������������ ";")
  valueFormat                 - ������ ��������� � ������ �� ������� ��������
                                ���� ���� ( �� ��������� ��� ��� ������������
                                "yyyy-mm-dd hh24:mi:ss" � ������������
                                ��������� �������)
  decimalChar                 - ���������� ����������� ��� ������ �� �������
                                �������� ��������
                                ( �� ��������� ������������ �����)
  createForInstanceFlag       - ��� ���������� ������������� �������� ��������
                                ��� ��� ������������� ������ � �������
                                ���������� ��
                                ( 1 ��, 0 ��� ( �� ���������))
  operatorId                  - Id ��������� ( �� ��������� �������)

  ���������:
  - ������ ������ � �������� ������ �������� ��������������� ��� ������ ��
    ������ �������� null;

  ( <body::setValueList( USED)>)
*/
member procedure setValueList(
  self in opt_option_list_t
  , optionShortName varchar2
  , valueList varchar2 := null
  , listSeparator varchar2 := null
  , valueFormat varchar2 := null
  , decimalChar varchar2 := null
  , createForInstanceFlag integer := null
  , operatorId integer := null
),



/* group: �������������� ������� */

/* pproc: createOption
  ������� ����������� �������� ��� ������� ��������.

  ���������:
  optionShortName             - ������� ������������ ���������
  valueTypeCode               - ��� ���� �������� ���������
  optionName                  - ������������ ���������
  valueListFlag               - ���� ������� ��� ��������� ������ ��������
                                ���������� ���� ( 1 ��, 0 ��� ( �� ���������))
  encryptionFlag              - ���� �������� �������� ��������� �
                                ������������� ����
                                ( 1 ��, 0 ��� ( �� ���������))
  testProdSensitiveFlag       - ���� �������� ��� �������� ��������� ���� ����
                                ������ ( �������� ��� ������������), ���
                                �������� ��� �������������
                                ( 1 ��, 0 ��� ( �� ���������))
  accessLevelCode             - ��� ������ ������� � ��������� �����
                                ���������������� ���������
                                ( �� ��������� ������ ��������� �������� �
                                  ������ �������� �������� � �������������
                                  ����, ����� ������ ������)
  optionDescription           - �������� ���������
                                ( �� ��������� �����������)
  operatorId                  - Id ��������� ( �� ��������� �������)

  ( <body::createOption>)
*/
member procedure createOption(
  self in opt_option_list_t
  , optionShortName varchar2
  , valueTypeCode varchar2
  , optionName varchar2
  , valueListFlag integer := null
  , encryptionFlag integer := null
  , testProdSensitiveFlag integer := null
  , accessLevelCode varchar2 := null
  , optionDescription varchar2 := null
  , operatorId integer := null
),

/* pproc: moveAll
  ��������� ��� ����������� ��������� �� �������� � ��������� ����� ����������,
  ����������� ������, ������� ������������ � ��� �������, � �������� ���������
  ���������.

  ���������:
  optionList                  - �����, � ������� ����������� ���������
  operatorId                  - Id ��������� ( �� ��������� �������)

  ( <body::moveAll>)
*/
member procedure moveAll(
  self in opt_option_list_t
  , optionList opt_option_list_t
  , operatorId integer := null
),

/* pproc: moveOption
  ��������� ����������� �������� �� �������� � ��������� ����� ����������,
  ����������� ������, ������� ������������ � ��� �������, � �������� ���������
  ��������.

  ���������:
  optionShortName             - ������� ������������ ���������
  optionList                  - �����, � ������� ����������� ��������
  operatorId                  - Id ��������� ( �� ��������� �������)

  ( <body::moveOption>)
*/
member procedure moveOption(
  self in opt_option_list_t
  , optionShortName varchar2
  , optionList opt_option_list_t
  , operatorId integer := null
),

/* pfunc: updateOption
  �������� ����������� ��������.

  ���������:
  optionShortName             - ������� ������������ ���������
  newOptionShortName          - ����� ������� ������������ ���������
                                ( null �� �������� ( �� ���������))
  valueTypeCode               - ��� ���� �������� ���������
                                ( null �� �������� ( �� ���������))
  valueListFlag               - ���� ������� ��� ��������� ������ ��������
                                ���������� ���� ( 1 ��, 0 ���,
                                null �� �������� ( �� ���������))
  encryptionFlag              - ���� �������� �������� ��������� �
                                ������������� ����
                                ( 1 ��, 0 ���, null �� �������� ( �� ���������))
  testProdSensitiveFlag       - ���� �������� ��� �������� ��������� ���� ����
                                ������ ( �������� ��� ������������), ���
                                �������� ��� �������������
                                ( 1 ��, 0 ���, null �� �������� ( �� ���������))
  accessLevelCode             - ��� ������ ������� � ��������� �����
                                ���������������� ���������
                                ( null �� ��������)
                                ( �� ��������� ������ ��������� �������� �
                                  ������ encryptionFlag = 1, ������ ������
                                  � ������ encryptionFlag = 0, ����� ��
                                  ��������)
  optionName                  - ������������ ���������
                                ( null �� �������� ( �� ���������))
  optionDescription           - �������� ���������
                                ( null �� �������� ( �� ���������))
  forceOptionDescriptionFlag  - �������� �������� ��������� �������� ��������
                                optionDescription ���� ���� ��� null
                                ( 1 ��, 0 ��� ( �� ���������))
  moveProdSensitiveValueFlag  - ��� ��������� �������� �����
                                testProdSensitiveFlag ���������� ������������
                                �������� ��������� ( ����� � ������������ ����
                                ������������ � �����)
                                ( 1 ��, 0 ��� ( ����������� ����������))
                                ( �� ��������� 0)
  deleteBadValueFlag          - ������� ��������, ������� �� �������������
                                ����� ������ ������������ ���������
                                ( 1 ��, 0 ��� ( ����������� ����������))
                                ( �� ��������� 0)
  skipIfNoChangeFlag          - �� ��������� ���������, ���� ��� �����������
                                ��������� � ������ ���������
                                ( 1 ��, 0 ��� ( �� ���������))
  operatorId                  - Id ��������� ( �� ��������� �������)

  �������:
  1 � ������ ��������� ���������, ����� 0.

  ���������:
  - ������������� deleteBadValueFlag ��������� � moveProdSensitiveValueFlag
    ������������ �������� �������� �������� � ������ ���������
    ��� ��������� �������� testProdSensitiveFlag ������ � 0
    ( � ��������� ������ ��� ������� �������� �������� ���� �� ���������
      ����������);

  ( <body::updateOption>)
*/
member function updateOption(
  optionShortName varchar2
  , newOptionShortName varchar2 := null
  , valueTypeCode varchar2 := null
  , valueListFlag integer := null
  , encryptionFlag integer := null
  , testProdSensitiveFlag integer := null
  , accessLevelCode varchar2 := null
  , optionName varchar2 := null
  , optionDescription varchar2 := null
  , forceOptionDescriptionFlag integer := null
  , moveProdSensitiveValueFlag integer := null
  , deleteBadValueFlag integer := null
  , skipIfNoChangeFlag integer := null
  , operatorId integer := null
)
return integer,

/* pproc: updateOption( PROC)
  �������� ����������� ��������.
  ��������� ��������� ������� <updateOption> �� ����������� ����������
  ������������� ��������.

  ( <body::updateOption( PROC)>)
*/
member procedure updateOption(
  self in opt_option_list_t
  , optionShortName varchar2
  , newOptionShortName varchar2 := null
  , valueTypeCode varchar2 := null
  , valueListFlag integer := null
  , encryptionFlag integer := null
  , testProdSensitiveFlag integer := null
  , accessLevelCode varchar2 := null
  , optionName varchar2 := null
  , optionDescription varchar2 := null
  , forceOptionDescriptionFlag integer := null
  , moveProdSensitiveValueFlag integer := null
  , deleteBadValueFlag integer := null
  , skipIfNoChangeFlag integer := null
  , operatorId integer := null
),

/* pfunc: setValue
  ������������� �������� ������������ ���������.

  ���������:
  optionShortName             - ������� ������������ ���������
  prodValueFlag               - ���� ������������� �������� ������ �
                                ������������ ( ���� ��������) ��
                                ( 1 ������ � ������������ ��, 0 ������ �
                                �������� ��, null ��� �����������)
  instanceName                - ��� ���������� ��, � ������� �����
                                �������������� ��������
                                ( null ��� ����������� ( �� ���������))
  valueTypeCode               - ��� ���� �������� ���������
                                ( �� ��������� ������������ �� ������ ���������)
  dateValue                   - �������� ���� ����
                                ( �� ��������� �����������)
  numberValue                 - �������� ��������
                                ( �� ��������� �����������)
  stringValue                 - ��������� �������� ��� ������ �� �������
                                ��������
                                ( �� ��������� �����������)
  setValueListFlag            - ���������� �������� �������� ������ �� �������
                                ��������, ���������� � ��������� stringValue
                                ( 1 ��, 0 ��� ( �� ���������))
  listSeparator               - ������, ������������ � �������� ����������� �
                                ������ �� ������� ��������
                                ( �� ��������� ������������ ";")
  valueFormat                 - ������ ��������� � ������ �� ������� ��������
                                ���� ���� ( �� ��������� ��� ��� ������������
                                "yyyy-mm-dd hh24:mi:ss" � ������������
                                ��������� �������)
  decimalChar                 - ���������� ����������� ��� ������ �� �������
                                �������� ��������
                                ( �� ��������� ������������ �����)
  skipIfNoChangeFlag          - �� ��������� ���������, ���� ��� �����������
                                ��������� � ������ ��������
                                ( 1 ��, 0 ��� ( �� ���������))
  operatorId                  - Id ��������� ( �� ��������� �������)

  �������:
  1 � ������ ��������� ��������, ����� 0.

  ( <body::setValue>)
*/
member function setValue(
  optionShortName varchar2
  , prodValueFlag integer
  , instanceName varchar2 := null
  , valueTypeCode varchar2 := null
  , dateValue date := null
  , numberValue number := null
  , stringValue varchar2 := null
  , setValueListFlag integer := null
  , listSeparator varchar2 := null
  , valueFormat varchar2 := null
  , decimalChar varchar2 := null
  , skipIfNoChangeFlag integer := null
  , operatorId integer := null
)
return integer,

/* pproc: setValue( PROC)
  ������������� �������� ������������ ���������.
  ��������� ��������� ������� <setValue> �� ����������� ����������
  ������������� ��������.

  ( <body::setValue( PROC)>)
*/
member procedure setValue(
  self in opt_option_list_t
  , optionShortName varchar2
  , prodValueFlag integer
  , instanceName varchar2 := null
  , valueTypeCode varchar2 := null
  , dateValue date := null
  , numberValue number := null
  , stringValue varchar2 := null
  , setValueListFlag integer := null
  , listSeparator varchar2 := null
  , valueFormat varchar2 := null
  , decimalChar varchar2 := null
  , skipIfNoChangeFlag integer := null
  , operatorId integer := null
),

/* pproc: deleteAll
  ������� ��� ����������� ���������, ����������� � ������ ����������.

  ���������:
  operatorId                  - Id ��������� ( �� ��������� �������)

  ( <body::deleteAll>)
*/
member procedure deleteAll(
  self in opt_option_list_t
  , operatorId integer := null
),

/* pproc: deleteOption
  ������� ����������� ��������.

  ���������:
  optionShortName             - ������� ������������ ���������
  operatorId                  - Id ��������� ( �� ��������� �������)

  ���������:
  - ��� �������� ��������� ������������� ��������� ����������� � ���� ��������;

  ( <body::deleteOption>)
*/
member procedure deleteOption(
  self in opt_option_list_t
  , optionShortName varchar2
  , operatorId integer := null
),

/* pproc: deleteValue
  ������� ��������� �������� ������������ ���������.

  ���������:
  optionShortName             - ������� ������������ ���������
  prodValueFlag               - ���� ������������� �������� ������ �
                                ������������ ( ���� ��������) ��
                                ( 1 ������ � ������������ ��, 0 ������ �
                                �������� ��, null ��� �����������)
  instanceName                - ��� ���������� ��, � ������� �����
                                �������������� ��������
                                ( null ��� ����������� ( �� ���������))
  operatorId                  - Id ��������� ( �� ��������� �������)

  ( <body::deleteValue>)
*/
member procedure deleteValue(
  self in opt_option_list_t
  , optionShortName varchar2
  , prodValueFlag integer
  , instanceName varchar2 := null
  , operatorId integer := null
),

/* pproc: deleteValue( USED)
  ������� ������������ � ������� �� �������� ������������ ���������.

  ���������:
  optionShortName             - ������� ������������ ���������
  operatorId                  - Id ��������� ( �� ��������� �������)

  ( <body::deleteValue( USED)>)
*/
member procedure deleteValue(
  self in opt_option_list_t
  , optionShortName varchar2
  , operatorId integer := null
),



/* group: ������� ��� ������������� � SQL */

/* pfunc: getOptionValue
  ���������� ������� ���������� � �������� ������������� ����������.

  �������:
  ������� � ������� �����, ������� ���������� �� ����� �������������
  <v_opt_option_value> ����������� ���� encrypted_string_value ( ��� ����
  �������� � ���� string_value ������ ����������� � ��������������� ����)
  ( ���� ����������� � ���� <opt_option_value_t>).

  ������ �������������:

(code)

SQL> select * from table( opt_option_list_t( 'Option').getOptionValue());

(end)

  ( ������� ���������� ������ Option)

  ( <body::getOptionValue>)
*/
member function getOptionValue
return opt_option_value_table_t
pipelined,

/* pfunc: getValue
  ���������� ������� � ��������� ���������� ���������.

  ���������:
  optionShortName             - ������� ������������ ���������

  �������:
  ������� � ������� �����, ������� ���������� �� ����� �������������
  <v_opt_value> ����������� ���� encrypted_string_value ( ��� ���� ��������
  � ���� string_value ������ ����������� � ��������������� ����) ( ����
  ����������� � ���� <opt_value_t>).

  ������ �������������:

(code)

SQL> select * from table( opt_option_list_t( 'Option').getValue('Test1'));

(end)

  ( ������� �������� ��������� Test1 ������ Option)

  ( <body::getValue>)
*/
member function getValue(
  optionShortName varchar2
)
return opt_value_table_t
pipelined,



/* group: ���� �������� */

/* pfunc: mergeObjectType
  ������� ��� ��������� ��� �������.

  ���������:
  objectTypeShortName         - ������� ������������ ���� �������
  objectTypeName              - ������������ ���� �������
  operatorId                  - Id ��������� ( �� ��������� �������)

  �������:
  - ���� �������� ��������� ( 0 ��� ���������, 1 ���� ��������� �������)

  ���������:
  - ���������, ��� ��� ������� ��������� � ������, ��� �������� ��� ������
    ������� ��������� ������� opt_option_list_t;

  ( <body::mergeObjectType>)
*/
member function mergeObjectType(
  objectTypeShortName varchar2
  , objectTypeName varchar2
  , operatorId integer := null
)
return integer,

/* pproc: deleteObjectType
  ������� ��� �������.

  ���������:
  objectTypeShortName         - ������� ������������ ���� �������
  operatorId                  - Id ���������, ������������ �������� ( ��
                                ��������� �������)

  ���������:
  - ���������, ��� ��� ������� ��������� � ������, ��� �������� ��� ������
    ������� ��������� ������� opt_option_list_t;
  - � ������ ������������� ���� � ���������� ������ ������������� ����������;
  - ��� ���������� ������������� ������ ��������� ���������, ����� ��������
    ���� ����������� ��������;

  ( <body::deleteObjectType>)
*/
member procedure deleteObjectType(
  self in opt_option_list_t
  , objectTypeShortName varchar2
  , operatorId integer := null
)

)
not final
/
