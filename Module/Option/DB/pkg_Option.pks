create or replace package pkg_Option is
/* package: pkg_Option
  ������� �� ������ � ������������ ����������� ��� ������������� ��
  web-����������.

  SVN root: Oracle/Module/Option
*/



/* group: ��������� */

/* const: Module_Name
  �������� ������, � �������� ��������� �����.
*/
Module_Name constant varchar2(30) := pkg_OptionMain.Module_Name;



/* group: ���������� ��������� */

/* const: StorageRuleInteger
  ������� �������� �������� ��������.
*/
StorageRuleInteger constant integer := 1;

/* const: StorageRuleString
  ������� �������� ��������� ��������.
*/
StorageRuleString constant integer := 2;

/* const: StorageRuleDate
  ������� �������� �������� ���� ����.
*/
StorageRuleDate constant integer := 3;

/* const: Test_Option_Postfix
  �������� ����� �����, ���������� �������� ��� ������ � �������� ��.
*/
Test_Option_Postfix constant varchar2(30) := 'Test';

/* const: Role_Global_Option_Admin
  Id ���� �������������� ���������� ����������.
*/
Role_Global_Option_Admin constant integer := 2;



/* group: ������� */



/* group: ����������� ��������� */

/* pfunc: createOption
  ������� ����������� �������� � ������ ��� ���� ������������ � ������� ��
  ��������.

  ���������:
  moduleId                    - Id ������, � �������� ��������� ��������
  objectShortName             - �������� �������� ������� ������
                                ( �� ��������� �����������)
  objectTypeId                - Id ���� �������
                                ( �� ��������� �����������)
  optionShortName             - �������� �������� ���������
  valueTypeCode               - ��� ���� �������� ���������
  valueListFlag               - ���� ������� ��� ��������� ������ ��������
                                ���������� ���� ( 1 ��, 0 ��� ( �� ���������))
  encryptionFlag              - ���� �������� �������� ��������� �
                                ������������� ����
                                ( 1 ��, 0 ��� ( �� ���������))
  testProdSensitiveFlag       - ���� �������� ��� �������� ��������� ���� ����
                                ������ ( �������� ��� ������������), ���
                                �������� ��� �������������
                                ( 1 ��, 0 ��� ( �� ���������))
  optionName                  - �������� ���������
  optionDescription           - �������� ���������
                                ( �� ��������� �����������)
  dateValue                   - �������� ���� ����
                                ( �� ��������� �����������)
  numberValue                 - �������� ��������
                                ( �� ��������� �����������)
  stringValue                 - ��������� ��������
                                ( �� ��������� �����������)
  stringListSeparator         - ������, ������������ � �������� ����������� �
                                ������ �� ������� ��������� ��������
                                ( �� ��������� ������������ ";")
  checkRoleFlag               - ��������� ������� � ��������� ���� ���
                                ���������� ��������
                                ( 1 �� ( �� ���������), 0 ���)
  operatorId                  - Id ��������� ( �� ��������� �������)

  �������:
  Id ���������.

  ���������:
  - � ������, ���� ������������ ������ ��������, ��������� � ����������
    ������� �������� ����������� ��� ������ �������� ������;
  - �������� checkRoleFlag ������������ ��� ������ ������� �� ������������
    ������� ������ ������� ( � ������� ����������� ����������� ������� ����
    �������) � �� ������ �������������� �� ���������� ������;

  ( <body::createOption>)
*/
function createOption(
  moduleId integer
  , objectShortName varchar2 := null
  , objectTypeId varchar2 := null
  , optionShortName varchar2
  , valueTypeCode varchar2
  , valueListFlag integer := null
  , encryptionFlag integer := null
  , testProdSensitiveFlag integer := null
  , optionName varchar2
  , optionDescription varchar2 := null
  , dateValue date := null
  , numberValue number := null
  , stringValue varchar2 := null
  , stringListSeparator varchar2 := null
  , checkRoleFlag integer := null
  , operatorId integer := null
)
return integer;

/* pproc: updateOption
  �������� ����������� ��������.

  ���������:
  optionId                    - Id ���������
  valueTypeCode               - ��� ���� �������� ���������
  valueListFlag               - ���� ������� ��� ��������� ������ ��������
                                ���������� ���� ( 1 ��, 0 ���)
  encryptionFlag              - ���� �������� �������� ��������� �
                                ������������� ���� ( 1 ��, 0 ���)
  testProdSensitiveFlag       - ���� �������� ��� �������� ��������� ���� ����
                                ������ ( �������� ��� ������������), ���
                                �������� ��� �������������
                                ( 1 ��, 0 ���)
  optionName                  - �������� ���������
  optionDescription           - �������� ���������
  checkRoleFlag               - ��������� ������� � ��������� ���� ���
                                ���������� ��������
                                ( 1 �� ( �� ���������), 0 ���)
  operatorId                  - Id ��������� ( �� ��������� �������)

  ���������:
  - ��������, ������� �� ������������� ����� ������ ������������ ���������,
    ���������;
  - � ������������ �� ��� ��������� �������� testProdSensitiveFlag �������
    �������� ��������� ����������� ( ��� ���� ������ ������ �������� ���������
    �������� ��� ������������ �� ��� ��������);
  - �������� checkRoleFlag ������������ ��� ������ ������� �� ������������
    ������� ������ ������� ( � ������� ����������� ����������� ������� ����
    �������) � �� ������ �������������� �� ���������� ������;

  ( <body::updateOption>)
*/
procedure updateOption(
  optionId integer
  , valueTypeCode varchar2
  , valueListFlag integer
  , encryptionFlag integer
  , testProdSensitiveFlag integer
  , optionName varchar2
  , optionDescription varchar2
  , checkRoleFlag integer := null
  , operatorId integer := null
);

/* pproc: setOptionValue
  ������ ������������ � ������� �� �������� ������������ ���������.

  ���������:
  optionId                    - Id ���������
  dateValue                   - �������� ���� ����
                                ( �� ��������� �����������)
  numberValue                 - �������� ��������
                                ( �� ��������� �����������)
  stringValue                 - ��������� ��������
                                ( �� ��������� �����������)
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
  checkRoleFlag               - ��������� ������� � ��������� ���� ���
                                ���������� ��������
                                ( 1 �� ( �� ���������), 0 ���)
  operatorId                  - Id ��������� ( �� ��������� �������)

  ���������:
  - �������� checkRoleFlag ������������ ��� ������ ������� �� ������������
    ������� ������ ������� ( � ������� ����������� ����������� ������� ����
    �������) � �� ������ �������������� �� ���������� ������;

  ( <body::setOptionValue>)
*/
procedure setOptionValue(
  optionId integer
  , dateValue date := null
  , numberValue number := null
  , stringValue varchar2 := null
  , valueIndex integer := null
  , checkRoleFlag integer := null
  , operatorId integer := null
);

/* pproc: deleteOption
  ������� ����������� ��������.

  ���������:
  optionId                    - Id ���������
  checkRoleFlag               - ��������� ������� � ��������� ���� ���
                                ���������� ��������
                                ( 1 �� ( �� ���������), 0 ���)
  operatorId                  - Id ��������� ( �� ��������� �������)

  ���������:
  - ��� ����������� ��������� ������������� � ������ �������� option_id ��
    ������� opt_option, �������������� � ������� opt_option_new, ���������
    ��������� �������� ������� �� ���������� ������;
  - �������� checkRoleFlag ������������ ��� ������ ������� �� ������������
    ������� ������ ������� ( � ������� ����������� ����������� ������� ����
    �������) � �� ������ �������������� �� ���������� ������;

  ( <body::deleteOption>)
*/
procedure deleteOption(
  optionId integer
  , checkRoleFlag integer := null
  , operatorId integer := null
);

/* pfunc: findOption
  ����� ����������� ����������.

  ���������:
  optionId                    - Id ���������
  moduleId                    - Id ������, � �������� ��������� ��������
  objectShortName             - �������� �������� ������� ������
                                ( ����� �� like ��� ����� ��������)
  objectTypeId                - Id ���� �������
  optionShortName             - �������� �������� ���������
                                ( ����� �� like ��� ����� ��������)
  optionName                  - �������� ���������
                                ( ����� �� like ��� ����� ��������)
  optionDescription           - �������� ���������
                                ( ����� �� like ��� ����� ��������)
  stringValue                 - ��������� ��������
                                ( ����� �� like ��� ����� ��������)
  maxRowCount                 - ������������ ����� ������������ ������� �������
  checkRoleFlag               - ��������� ������� � ��������� ���� ���
                                ���������� ��������
                                ( 1 �� ( �� ���������), 0 ���)
  operatorId                  - Id ���������, ������������ ��������
                                ( �� ��������� �������)

  ������� ( ������):
  option_id                   - Id ���������
  value_id                    - Id ������������� ��������
  module_id                   - Id ������, � �������� ��������� ��������
  module_name                 - �������� ������, � �������� ��������� ��������
  module_svn_root             - ���� � Subversion � ��������� �������� ������,
                                � ��������� ��������� ��������
  object_short_name           - �������� �������� ������� ������
  object_type_id              - Id ���� �������
  object_type_short_name      - �������� �������� ���� �������
  object_type_name            - �������� ���� �������
  option_short_name           - �������� �������� ���������
  value_type_code             - ��� ���� �������� ���������
  value_type_name             - �������� ���� �������� ���������
  date_value                  - �������� ��������� ���� ����
  number_value                - �������� �������� ���������
  string_value                - ��������� �������� ��������� ���� ������
                                �������� � ������������, ��������� � ����
                                list_separator ( ���� ��� ������)
  list_separator              - ������, ������������ � �������� ����������� �
                                ������ ��������
  value_list_flag             - ���� ������� ��� ��������� ������ ��������
  encryption_flag             - ���� �������� �������� ��������� �
                                ������������� ����
  test_prod_sensitive_flag    - ���� �������� ��� �������� ��������� ���� ����
                                ������ ( �������� ��� ������������), ���
                                �������� ��� �������������
  access_level_code           - ��� ������ ������� ����� ���������
  access_level_name           - �������� ������ ������� ����� ���������
  option_name                 - �������� ���������
  option_description          - �������� ���������

  ���������:
  - �������� checkRoleFlag ������������ ��� ������ ������� �� ������������
    ������� ������ ������� ( � ������� ����������� ����������� ������� ����
    �������) � �� ������ �������������� �� ���������� ������;

  ( <body::findOption>)
*/
function findOption(
  optionId integer := null
  , moduleId integer := null
  , objectShortName varchar2 := null
  , objectTypeId integer := null
  , optionShortName varchar2 := null
  , optionName varchar2 := null
  , optionDescription varchar2 := null
  , stringValue varchar2 := null
  , maxRowCount integer := null
  , checkRoleFlag integer := null
  , operatorId integer := null
)
return sys_refcursor;



/* group: �������� ���������� */

/* pfunc: createValue
  ������� �������� ���������.

  ���������:
  optionId                    - Id ���������
  prodValueFlag               - ���� ������������� �������� ������ �
                                ������������ ( ���� ��������) ��
                                ( 1 ������ � ������������ ��, 0 ������ �
                                  �������� ��, null ��� �����������)
  instanceName                - ��� ���������� ��, � ������� �����
                                �������������� ��������
                                ( null ��� ����������� ( �� ���������))
  usedOperatorId              - Id ���������, ��� �������� �����
                                �������������� ��������
                                ( null ��� ����������� ( �� ���������))
  dateValue                   - �������� ���� ����
                                ( �� ��������� �����������)
  numberValue                 - �������� ��������
                                ( �� ��������� �����������)
  stringValue                 - ��������� ��������
                                ( �� ��������� �����������)
  stringListSeparator         - ������, ������������ � �������� ����������� �
                                ������ �� ������� ��������� ��������
                                ( �� ��������� ������������ ";")
  checkRoleFlag               - ��������� ������� � ��������� ���� ���
                                ���������� ��������
                                ( 1 �� ( �� ���������), 0 ���)
  operatorId                  - Id ��������� ( �� ��������� �������)

  �������:
  Id �������� ���������.

  ���������:
  - � ������, ���� ������������ ������ ��������, ��������� � ����������
    ������� �������� ����������� ��� ������ �������� ������;
  - �������� checkRoleFlag ������������ ��� ������ ������� �� ������������
    ������� ������ ������� ( � ������� ����������� ����������� ������� ����
    �������) � �� ������ �������������� �� ���������� ������;

  ( <body::createValue>)
*/
function createValue(
  optionId integer
  , prodValueFlag integer
  , instanceName varchar2 := null
  , usedOperatorId integer := null
  , dateValue date := null
  , numberValue number := null
  , stringValue varchar2 := null
  , stringListSeparator varchar2 := null
  , checkRoleFlag integer := null
  , operatorId integer := null
)
return integer;

/* pproc: updateValue
  �������� �������� ���������.

  ���������:
  valueId                     - Id ��������
  dateValue                   - �������� ���� ����
                                ( �� ��������� �����������)
  numberValue                 - �������� ��������
                                ( �� ��������� �����������)
  stringValue                 - ��������� ��������
                                ( �� ��������� �����������)
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
  checkRoleFlag               - ��������� ������� � ��������� ���� ���
                                ���������� ��������
                                ( 1 �� ( �� ���������), 0 ���)
  operatorId                  - Id ��������� ( �� ��������� �������)

  ���������:
  - �������� checkRoleFlag ������������ ��� ������ ������� �� ������������
    ������� ������ ������� ( � ������� ����������� ����������� ������� ����
    �������) � �� ������ �������������� �� ���������� ������;

  ( <body::updateValue>)
*/
procedure updateValue(
  valueId integer
  , dateValue date := null
  , numberValue number := null
  , stringValue varchar2 := null
  , valueIndex integer := null
  , checkRoleFlag integer := null
  , operatorId integer := null
);

/* pproc: deleteValue
  ������� �������� ���������.

  ���������:
  valueId                     - Id �������� ���������
  checkRoleFlag               - ��������� ������� � ��������� ���� ���
                                ���������� ��������
                                ( 1 �� ( �� ���������), 0 ���)
  operatorId                  - Id ��������� ( �� ��������� �������)

  ���������:
  - �������� checkRoleFlag ������������ ��� ������ ������� �� ������������
    ������� ������ ������� ( � ������� ����������� ����������� ������� ����
    �������) � �� ������ �������������� �� ���������� ������;

  ( <body::deleteValue>)
*/
procedure deleteValue(
  valueId integer
  , checkRoleFlag integer := null
  , operatorId integer := null
);

/* pfunc: findValue
  ����� �������� ����������� ����������.

  ���������:
  valueId                     - Id ��������
  optionId                    - Id ���������
  maxRowCount                 - ������������ ����� ������������ ������� �������
  checkRoleFlag               - ��������� ������� � ��������� ���� ���
                                ���������� ��������
                                ( 1 �� ( �� ���������), 0 ���)
  operatorId                  - Id ���������, ������������ ��������
                                ( �� ��������� �������)

  ������� ( ������):
  value_id                    - Id ��������
  option_id                   - Id ���������
  used_value_flag             - ���� �������� ������������� � �� ��������
                                ( 1 ��, ����� null)
  prod_value_flag             - ���� ������������� �������� ������ �
                                ������������ ( ���� ��������) �� ( 1 ������ �
                                ������������ ��, 0 ������ � �������� ��, null
                                ��� �����������)
  instance_name               - ��� ���������� ��, � ������� �����
                                �������������� �������� ( � ������� ��������,
                                null ��� �����������)
  used_operator_id            - Id ���������, ��� �������� �����
                                �������������� ��������
  used_operator_name          - ��� ���������, ��� �������� �����
                                �������������� ��������
  value_type_code             - ��� ���� �������� ���������
  value_type_name             - �������� ���� �������� ���������
  list_separator              - ������, ������������ � �������� ����������� �
                                ������ ��������
  encryption_flag             - ���� �������� �������� ��������� �
                                ������������� ����
  date_value                  - �������� ��������� ���� ����
  number_value                - �������� �������� ���������
  string_value                - ��������� �������� ��������� ���� ������
                                �������� � ������������, ��������� � ����
                                list_separator ( ���� ��� ������)

  ���������:
  - ����������� ������ ���� ������� �������� valueId ��� optionId;
  - �������� checkRoleFlag ������������ ��� ������ ������� �� ������������
    ������� ������ ������� ( � ������� ����������� ����������� ������� ����
    �������) � �� ������ �������������� �� ���������� ������;

  ( <body::findValue>)
*/
function findValue(
  valueId integer := null
  , optionId integer := null
  , maxRowCount integer := null
  , checkRoleFlag integer := null
  , operatorId integer := null
)
return sys_refcursor;



/* group: ����������� */

/* pfunc: getObjectType
  ���������� ���� ��������.

  ������� ( ������):
  object_type_id              - Id ���� �������
  object_type_short_name      - �������� �������� ���� �������
  object_type_name            - �������� ���� �������
  module_name                 - �������� ������, � �������� ��������� ���
                                �������
  module_svn_root             - ���� � Subversion � ��������� �������� ������,
                                � ��������� ��������� ��� �������
  ( ���������� �� object_type_name, object_type_id)

  ( <body::getObjectType>)
*/
function getObjectType
return sys_refcursor;

/* pfunc: getValueType
  ���������� ���� �������� ����������.

  ������� ( ������):
  value_type_code             - ��� ���� �������� ���������
  value_type_name             - �������� ���� �������� ���������

  ( ���������� �� value_type_name)

  ( <body::getValueType>)
*/
function getValueType
return sys_refcursor;



/* group: ����������� ������ ������� */

/* pfunc: findModule
  ����� ����������� �������.

  ���������:
  moduleId                    - Id ������
  moduleName                  - �������� ������
                                ( ����� �� like ��� ����� ��������)
  maxRowCount                 - ������������ ����� ������������ ������� �������

  ������� ( ������):
  module_id                   - Id ������
  module_name                 - �������� ������
  svn_root                    - ���� � Subversion � ��������� �������� ������,

  ( <body::findModule>)
*/
function findModule(
  moduleId integer := null
  , moduleName varchar2 := null
  , maxRowCount integer := null
)
return sys_refcursor;

/* pfunc: getOperator
  ��������� ������ �� ����������.

  ���������:
  operatorName                - ��� ���������
                                ( ����� �� like ��� ����� ��������)
                                ( �� ��������� ��� �����������)
  maxRowCount                 - ������������ ����� ������������ ������� �������
                                ( �� ��������� ��� �����������)

  ������� ( ������):
  operator_id                 - Id ���������
  operator_name               - ��� ���������

  ( <body::getOperator>)
*/
function getOperator(
  operatorName varchar2 := null
  , maxRowCount integer := null
)
return sys_refcursor;



/* group: ���������� ������� */

/* pfunc: getOptionDate(optionShortName)
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.

  ( <body::getOptionDate(optionShortName)>)
*/
function getOptionDate(
  optionShortName varchar2
)
return date;

/* pfunc: getOptionString(optionShortName)
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.

  ( <body::getOptionString(optionShortName)>)
*/
function getOptionString(
  optionShortName varchar2
)
return varchar2;

/* pfunc: getOptionNumber(optionShortName)
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.

  ( <body::getOptionNumber(optionShortName)>)
*/
function getOptionNumber(
  optionShortName varchar2
)
return number;

/* pproc: addOptionDate(optionShortName)
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.

  ( <body::addOptionDate(optionShortName)>)
*/
procedure addOptionDate(
  optionShortName varchar2
  , optionName varchar2
  , defaultDateValue varchar2 := null
);

/* pproc: addOptionNumber(optionShortName)
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.

  ( <body::addOptionNumber(optionShortName)>)
*/
procedure addOptionNumber(
  optionShortName varchar2
  , optionName varchar2
  , defaultNumberValue varchar2 := null
);

/* pproc: addOptionString(optionShortName)
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.

  ( <body::addOptionString(optionShortName)>)
*/
procedure addOptionString(
  optionShortName varchar2
  , optionName varchar2
  , defaultStringValue varchar2 := null
);

/* pfunc: getOptionDate(optionId)
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.

  ( <body::getOptionDate(optionId)>)
*/
function getOptionDate(
  optionId in opt_option_value.option_id%type
)
return opt_option_value.datetime_value%type;

/* pfunc: getOptionInteger(optionId)
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.

  ( <body::getOptionInteger(optionId)>)
*/
function getOptionInteger(
  optionId in opt_option_value.option_id%type
)
return opt_option_value.integer_value%type;

/* pfunc: getOptionString(optionId)
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.

  ( <body::getOptionString(optionId)>)
*/
function getOptionString(
  optionId in opt_option_value.option_id%type
)
return opt_option_value.string_value%type;

/* pfunc: getOptionDate
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.

  ( <body::getOptionDate>)
*/
function getOptionDate(
  moduleName varchar2
  , moduleOptionName varchar2
)
return date;

/* pfunc: getOptionString
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.

  ( <body::getOptionString>)
*/
function getOptionString(
  moduleName varchar2
  , moduleOptionName varchar2
)
return varchar2;

/* pfunc: getOptionNumber
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.

  ( <body::getOptionNumber>)
*/
function getOptionNumber(
  moduleName varchar2
  , moduleOptionName varchar2
)
return number;

/* pproc: setDateTime(optionId)
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.

  ( <body::setDateTime(optionId)>)
*/
procedure setDateTime(
  optionid in opt_option_value.option_id%type
  , value in opt_option_value.datetime_value%type
);

/* pproc: setString(optionId)
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.

  ( <body::setString(optionId)>)
*/
procedure setString(
  optionid in opt_option_value.option_id%type
  , value in opt_option_value.string_value%type
);

/* pproc: setInteger(optionId)
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.

  ( <body::setInteger(optionId)>)
*/
procedure setInteger(
  optionId in opt_option_value.option_id%type
  , value in opt_option_value.integer_value%type
);

/* pproc: setDate
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.

  ( <body::setDate>)
*/
procedure setDate(
  moduleName varchar2
  , moduleOptionName varchar2
  , dateValue date
);

/* pproc: setString
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.

  ( <body::setString>)
*/
procedure setString(
  moduleName varchar2
  , moduleOptionName varchar2
  , stringValue varchar2
);

/* pproc: setNumber
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.

  ( <body::setNumber>)
*/
procedure setNumber(
  moduleName varchar2
  , moduleOptionName varchar2
  , numberValue number
);

/* pfunc: createOption
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.

  ( <body::createOption>)
*/
function createOption(
  optionName opt_option.option_name%type
  , optionShortName opt_option.option_short_name%type
  , isGlobal opt_option.is_global%type
  , maskId opt_option.mask_id%type
  , dateTimeValue opt_option_value.datetime_value%type
  , integerValue opt_option_value.integer_value%type
  , stringValue opt_option_value.string_value%type
  , operatorId in op_operator.operator_id%type
)
return opt_option.option_id%type;

/* pfunc: createOption
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.

  ( <body::createOption>)
*/
function createOption(
  optionName opt_option.option_name%type
  , optionShortName opt_option.option_short_name%type
  , isGlobal opt_option.is_global%type
  , maskId opt_option.mask_id%type
  , stringValue varchar2
  , operatorId op_operator.operator_id%type
)
return integer;

/* pproc: updateOption
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.

  ( <body::updateOption>)
*/
procedure updateOption(
  optionId in opt_option.option_id%type
  , dateTimeValue in opt_option_value.datetime_value%type
  , integerValue in opt_option_value.integer_value%type
  , stringValue in opt_option_value.string_value%type
  , operatorId in op_operator.operator_id%type
);

/* pproc: updateOption
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.

  ( <body::updateOption>)
*/
procedure updateOption(
  optionId in opt_option.option_id%type
  , optionName in opt_option.option_name%type
  , optionShortName in opt_option.option_short_name%type
  , isGlobal in opt_option.is_global%type
  , maskId in opt_option.mask_id%type
  , dateTimeValue in opt_option_value.datetime_value%type
  , integerValue in opt_option_value.integer_value%type
  , stringValue in opt_option_value.string_value%type
  , operatorId in op_operator.operator_id%type
);

/* pproc: updateOption
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.

  ( <body::updateOption>)
*/
procedure updateOption(
  optionId in opt_option.option_id%type
  , maskId in opt_option.mask_id%type
  , stringValue in varchar2
  , operatorId in op_operator.operator_id%type
);

/* pproc: updateOption
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.

  ( <body::updateOption>)
*/
procedure updateOption(
  optionId opt_option.option_id%type
  , optionName opt_option.option_name%type
  , optionShortName opt_option.option_short_name%type
  , isGlobal opt_option.is_global%type
  , maskId opt_option.mask_id%type
  , stringValue varchar2
  , operatorId op_operator.operator_id%type
);

/* pproc: addOptionDate
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.

  ( <body::addOptionDate>)
*/
procedure addOptionDate(
  moduleName varchar2
  , moduleOptionName varchar2
  , optionName varchar2
  , defaultDateValue varchar2 := null
);

/* pproc: addOptionNumber
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.

  ( <body::addOptionNumber>)
*/
procedure addOptionNumber(
  moduleName varchar2
  , moduleOptionName varchar2
  , optionName varchar2
  , defaultNumberValue varchar2 := null
);

/* pproc: addOptionString
  ���������� �������, � ������ ������� ������� ������������ ������� �� ����
  <opt_option_list_t>.

  ( <body::addOptionString>)
*/
procedure addOptionString(
  moduleName varchar2
  , moduleOptionName varchar2
  , optionName varchar2
  , defaultStringValue varchar2 := null
);



/* group:	���������� ������������ ������� */

/* pfunc: getMask
  ���������� �������.

  ( <body::getMask>)
*/
function getMask return sys_refcursor;

/* pfunc: findOption( DEPRECATED)
  ���������� �������.

  ( <body::findOption( DEPRECATED)>)
*/
function findOption
(
    optionId        integer  := null
  , optionName	    varchar2 := null
  , optionShortName	varchar2 := null
  , batchShortName	varchar2 := null
  , isGlobal	      number   := null
  , maskId	        integer  := null
  , optionValue	    varchar2 := null
  , maxRowCount	    integer  := null
  , operatorId	    integer  := null
) return sys_refcursor;

/* pfunc: getStorageRule
  ���������� �������.

  ( <body::getStorageRule>)
*/
function getStorageRule (maskId integer) return sys_refcursor;

end pkg_Option;
/
