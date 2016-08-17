create or replace package pkg_OptionMain is
/* package: pkg_OptionMain
  �������� ����� ������ Option.

  SVN root: Oracle/Module/Option
*/



/* group: ��������� */

/* const: Module_Name
  ������������ ������, � �������� ��������� �����.
*/
Module_Name constant varchar2(30) := 'Option';

/* const: Module_SvnRoot
  ���� � ��������� �������� ������ � Subversion.
*/
Module_SvnRoot constant varchar2(30) := 'Oracle/Module/Option';



/* group: ����������� ��������� */

/* const: LocalRoleSuffix_OptionSName
  ������� ������������ ���������
  "������� ��� �����, � ������� ������� �������� ����� �� ��� ���������,
  ��������� � �������� ������������� ������ Option".

  ��� �������� ���� ������� �����������
  ����:

  OptAdminAllOption<LocalRoleSuffix>    - ������ �����
  OptShowAllOption<LocalRoleSuffix>     - �������� ������

  ��� <LocalRoleSuffix> ��� �������� ������� ���������.

  ����� ������ �� ��� ���������, ����������� � ������ Option, � ������� �����
  ������ ��������. ��� ���� ���������������, ��� ��� ��������� ���������
  ������ �������� ����� ����� ��������� ��������, ������� �������� ���
  ��������� ������ Option.

  ������:
  ��� ��������� �  �� ProdDb �������� ����� �������� "Prod", � ����������
  ����� �� ��� ���������, ��������� � �� ProdDb, ����� ������ � ������� �����
  "OptAdminAllOptionProd" � "OptShowAllOptionProd".

  ���������:
  - ���������, ������������ ��, ��� ������� ��������� ���� ��������� ����,
    � ������������ �������� �����, �������� � �������
    <Install/Data/Last/Custom/set-optDbRoleSuffixList.sql>;
*/
LocalRoleSuffix_OptionSName constant varchar2(50) := 'LocalRoleSuffix';



/* group: ���� ������ AccessOperator */

/* const: Admin_RoleSName
  ������� ������������ ����
  "����������������� ���� ����������"
*/
Admin_RoleSName constant varchar2(50) := 'GlobalOptionAdmin';

/* const: Show_RoleSName
  ������� ������������ ����
  "�������� ���� ����������"
*/
Show_RoleSName constant varchar2(50) := 'OptShowAllOption';



/* group: ������ ������� ����� ��������� */

/* const: Full_AccessLevelCode
  ��� ������ ������� "������ ������".
*/
Full_AccessLevelCode constant varchar2(10) := 'FULL';

/* const: Read_AccessLevelCode
  ��� ������ ������� "������ ��� ������".
*/
Read_AccessLevelCode constant varchar2(10) := 'READ';

/* const: Value_AccessLevelCode
  ��� ������ ������� "��������� ��������".
*/
Value_AccessLevelCode constant varchar2(10) := 'VALUE';



/* group: ���� �������� ���������� */

/* const: Date_ValueTypeCode
  ��� ���� �������� "���� ( �� ��������)".
*/
Date_ValueTypeCode constant varchar2(10) := 'DATE';

/* const: Number_ValueTypeCode
  ��� ���� �������� "�����".
*/
Number_ValueTypeCode constant varchar2(10) := 'NUM';

/* const: String_ValueTypeCode
  ��� ���� �������� "������".
*/
String_ValueTypeCode constant varchar2(10) := 'STR';



/* group: ���� �������� */

/* const: PlsqlObject_ObjTypeSName
  ������� ������������ ���� ������� "PL/SQL ������".
*/
PlsqlObject_ObjTypeSName constant varchar2(50) := 'plsql_object';



/* group: ������� */

/* pfunc: getCurrentUsedOperatorId
  ���������� ������� ������������� Id ���������, ��� �������� �����
  �������������� ��������, ��� ������������� � �������������
  <v_opt_option_value>.

  ( <body::getCurrentUsedOperatorId>)
*/
function getCurrentUsedOperatorId
return integer;



/* group: ���� �������� */

/* pfunc: getObjectTypeId
  ���������� Id ���� �������.

  ���������:
  moduleId                    - Id ������, � �������� ��������� ��� �������
  objectTypeShortName         - ������� ������������ ���� �������
  raiseNotFoundFlag           - ����������� �� ���������� � ������ ����������
                                ������ ( 1 �� ( �� ���������), 0 ���)

  �������:
  Id ���� ������� ( �� ������� <opt_object_type>) ���� null, ���� ������ ��
  ������� � �������� raiseNotFoundFlag ����� 0.

  ( <body::getObjectTypeId>)
*/
function getObjectTypeId(
  moduleId integer
  , objectTypeShortName varchar2
  , raiseNotFoundFlag integer := null
)
return integer;

/* pfunc: createObjectType
  ������� ��� �������.

  ���������:
  moduleId                    - Id ������, � �������� ��������� ��� �������
  objectTypeShortName         - ������� ������������ ���� �������
  objectTypeName              - ������������ ���� �������
  operatorId                  - Id ��������� ( �� ��������� �������)

  �������:
  Id ���� �������.

  ( <body::createObjectType>)
*/
function createObjectType(
  moduleId integer
  , objectTypeShortName varchar2
  , objectTypeName varchar2
  , operatorId integer := null
)
return integer;

/* pfunc: mergeObjectType
  ������� ��� ��������� ��� �������.

  ���������:
  moduleId                    - Id ������, � �������� ��������� ��� �������
  objectTypeShortName         - ������� ������������ ���� �������
  objectTypeName              - ������������ ���� �������
  operatorId                  - Id ��������� ( �� ��������� �������)

  �������:
  - ���� �������� ��������� ( 0 ��� ���������, 1 ���� ��������� �������)

  ( <body::mergeObjectType>)
*/
function mergeObjectType(
  moduleId integer
  , objectTypeShortName varchar2
  , objectTypeName varchar2
  , operatorId integer := null
)
return integer;

/* pproc: deleteObjectType
  ������� ��� �������.

  ���������:
  moduleId                    - Id ������, � �������� ��������� ��� �������
  objectTypeShortName         - ������� ������������ ���� �������
  operatorId                  - Id ���������, ������������ �������� ( ��
                                ��������� �������)

  ���������:
  - � ������ ������������� ���� � ���������� ������ ������������� ����������;
  - ��� ���������� ������������� ������ ��������� ���������, ����� ��������
    ���� ����������� ��������;

  ( <body::deleteObjectType>)
*/
procedure deleteObjectType(
  moduleId integer
  , objectTypeShortName varchar2
  , operatorId integer := null
);



/* group: ����������� ��������� */

/* pfunc: getDecryptValue
  ���������� �������� ��� ������ �������� � �������������� ����.

  ���������:
  stringValue                 - ������ � ������������� ��������� ���� ��
                                ������� ������������� ��������
  listSeparator               - ������, ������������ � �������� ����������� �
                                ������ ��������
                                ( null ���� ������ �� ������������)

  �������:
  ������ � �������������� ��������� ���� ������� �������������� ��������
  ( � ������������ listSeparator)

  ( <body::getDecryptValue>)
*/
function getDecryptValue(
  stringValue varchar2
  , listSeparator varchar2
)
return varchar2;

/* pfunc: getOptionId
  ���������� Id ������������ ���������.

  ���������:
  moduleId                    - Id ������, � �������� ��������� ��������
  objectShortName             - ������� ������������ ������� ������
  objectTypeId                - Id ���� �������
  optionShortName             - ������� ������������ ���������
  raiseNotFoundFlag           - ����������� �� ���������� � ������ ����������
                                ��������� ( 1 �� ( �� ���������), 0 ���)

  �������:
  Id ��������� ���� null, ���� �������� �� ������ � �������� raiseNotFoundFlag
  ����� 0.

  ( <body::getOptionId>)
*/
function getOptionId(
  moduleId integer
  , objectShortName varchar2
  , objectTypeId integer
  , optionShortName varchar2
  , raiseNotFoundFlag integer := null
)
return integer;

/* pproc: lockOption
  ��������� � ���������� ������ ���������.

  ���������:
  rowData                     - ������ ������ ( �������)
  optionId                    - Id ���������

  ���������:
  - � ������, ���� ������ ���� ��������� �������, ������������� ����������;

  ( <body::lockOption>)
*/
procedure lockOption(
  rowData out nocopy opt_option%rowtype
  , optionId integer
);

/* pfunc: createOption
  ������� ����������� ��������.

  ���������:
  moduleId                    - Id ������, � �������� ��������� ��������
  optionShortName             - ������� ������������ ���������
  valueTypeCode               - ��� ���� �������� ���������
  optionName                  - ������������ ���������
  objectShortName             - ������� ������������ ������� ������
                                ( �� ��������� �����������)
  objectTypeId                - Id ���� �������
                                ( �� ��������� �����������)
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
  optionId                    - Id ������������ ���������
                                ( �� ��������� ����������� �������������)
  operatorId                  - Id ��������� ( �� ��������� �������)

  �������:
  Id ���������.

  ( <body::createOption>)
*/
function createOption(
  moduleId integer
  , optionShortName varchar2
  , valueTypeCode varchar2
  , optionName varchar2
  , objectShortName varchar2 := null
  , objectTypeId integer := null
  , valueListFlag integer := null
  , encryptionFlag integer := null
  , testProdSensitiveFlag integer := null
  , accessLevelCode varchar2 := null
  , optionDescription varchar2 := null
  , optionId integer := null
  , operatorId integer := null
)
return integer;

/* pproc: updateOption
  �������� ����������� ��������.

  ���������:
  optionId                    - Id ���������
  moduleId                    - Id ������, � �������� ��������� ��������
  objectShortName             - ������� ������������ ������� ������
  objectTypeId                - Id ���� �������
  optionShortName             - ������� ������������ ���������
  valueTypeCode               - ��� ���� �������� ���������
  valueListFlag               - ���� ������� ��� ��������� ������ ��������
                                ���������� ���� ( 1 ��, 0 ���)
  encryptionFlag              - ���� �������� �������� ��������� �
                                ������������� ���� ( 1 ��, 0 ���)
  testProdSensitiveFlag       - ���� �������� ��� �������� ��������� ���� ����
                                ������ ( �������� ��� ������������), ���
                                �������� ��� �������������
                                ( 1 ��, 0 ���)
  accessLevelCode             - ��� ������ ������� � ��������� �����
                                ���������������� ���������
  optionName                  - ������������ ���������
  optionDescription           - �������� ���������
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
  operatorId                  - Id ��������� ( �� ��������� �������)

  ���������:
  - ������������� deleteBadValueFlag ��������� � moveProdSensitiveValueFlag
    ������������ �������� �������� �������� � ������ ���������
    ��� ��������� �������� testProdSensitiveFlag ������ � 0
    ( � ��������� ������ ��� ������� �������� �������� ���� �� ���������
      ����������);

  ( <body::updateOption>)
*/
procedure updateOption(
  optionId integer
  , moduleId integer
  , objectShortName varchar2
  , objectTypeId integer
  , optionShortName varchar2
  , valueTypeCode varchar2
  , valueListFlag integer
  , encryptionFlag integer
  , testProdSensitiveFlag integer
  , accessLevelCode varchar2
  , optionName varchar2
  , optionDescription varchar2
  , moveProdSensitiveValueFlag integer := null
  , deleteBadValueFlag integer := null
  , operatorId integer := null
);

/* pproc: deleteOption
  ������� ����������� ��������.

  ���������:
  optionId                    - Id ���������
  operatorId                  - Id ��������� ( �� ��������� �������)

  ���������:
  - ��� �������� ��������� ������������� ��������� ����������� � ���� ��������;

  ( <body::deleteOption>)
*/
procedure deleteOption(
  optionId integer
  , operatorId integer := null
);



/* group: �������� ���������� */

/* pfunc: formatValueList
  ���������� ������ �������� � ����������� �������.

  ���������:
  valueTypeCode               - ��� ���� �������� ���������
  listSeparator               - ������, ������������ � �������� �����������
                                � ������������ ������
  valueList                   - �������� ������ ��������
  valueListSeparator          - ������, ������������ � �������� �����������
                                � ������ �� ������� ��������
                                ( �� ��������� ������������ ";")
  valueListItemFormat         - ������ ��������� � ������ �� ������� ��������
                                ���� ���� ( �� ��������� ������������
                                "yyyy-mm-dd hh24:mi:ss" � ������������
                                ��������� �������)
  valueListDecimalChar        - ���������� ����������� ��� ������ �� �������
                                �������� ��������
                                ( �� ��������� ������������ �����)
  encryptionFlag              - ���� ���������� ��������� �������� �
                                ������������ ������
                                ( 1 ��, 0 ��� ( �� ���������))

  �������:
  ������ �������� � ����������� �������.

  ( <body::formatValueList>)
*/
function formatValueList(
  valueTypeCode varchar2
  , listSeparator varchar2
  , valueList varchar2
  , valueListSeparator varchar2 := null
  , valueListItemFormat varchar2 := null
  , valueListDecimalChar varchar2 := null
  , encryptionFlag varchar2 := null
)
return varchar2;

/* pfunc: getValueCount
  ���������� ����� �������� ��������.

  ���������:
  valueTypeCode               - ��� ���� �������� ���������
                                ( null ���� �������� �� ������)
  listSeparator               - ������, ������������ � �������� ����������� �
                                ������ �������� ( null ���� ������ ��
                                ������������)
  stringValue                 - ��������� �������� ��� ������ �� �������
                                ��������

  �������:
  0 ���� �������� ( � �.�. null) �� ������, ����� ������������� ����� ��������
  �������� ( 1 ���� ������ �������� ��� ���������, �� ������������� ������
  ��������, ���� ����� �������� � ������ �������� ���������).

  ( <body::getValueCount>)
*/
function getValueCount(
  valueTypeCode varchar2
  , listSeparator varchar2
  , stringValue varchar2
)
return integer;

/* pproc: getValue
  ���������� �������� ���������.

  ���������:
  rowData                     - ������ �������� ( �������)
  optionId                    - Id ���������
  prodValueFlag               - ���� ������������� �������� ������ �
                                ������������ ( ���� ��������) ��
                                ( 1 ������ � ������������ ��, 0 ������ �
                                �������� ��, null ��� �����������
                                ( �� ���������))
  instanceName                - ��� ���������� ��, � ������� �����
                                �������������� ��������
                                ( null ��� ����������� ( �� ���������))
  usedOperatorId              - Id ���������, ��� �������� �����
                                �������������� ��������
                                ( null ��� ����������� ( �� ���������))
  usedValueFlag               - ���� �������� ������������� � ������� ��
                                ��������
                                ( 1 ��, 0 ��� ( �� ���������))
  valueTypeCode               - ��� ���� �������� ���������
                                ( ����������� ���������� ���� ���������� ��
                                  ����������, �� ��������� �� �����������)
  valueListFlag               - ���� ������� ��� ��������� ������ ��������
                                ( 1 ��, 0 ���)
                                ( ����������� ���������� ���� ���������� ��
                                  ����������, �� ��������� �� �����������)
  valueIndex                  - ������ �������� � ������ ��������
                                ( ������� � 1, 1 ����� ����� ��������� ���
                                ��������� �������� ���������, �� �������������
                                ������ ��������, �� ��������� null)
  decryptValueFlag            - ���� �������� ��������������� �������� �
                                ������, ���� ��� �������� � ������������� ����
                                ( 1 �� ( �� ���������), 0 ���)
  raiseNotFoundFlag           - ����������� �� ���������� � ������ ����������
                                �������� ( 1 �� ( �� ���������), 0 ���)

  ���������:
  - � ������, ���� ��� ��� ���� ������������� ������ ��� �������� ����������
    �� ��� �� ������ ��� ���������, �� �������� ������������;
  - � ������, ���� ������������ �������� ( ��� usedValueFlag = 1) �� ������� �
    ������� raiseNotFoundFlag ������ 0, �� � ������ rowData ����
    prod_value_flag � instance_name ����������� ����������, ����������������
    ������� ��, � ��������� ����� ������������ null;
  - � ������, ���� �������� ������������ ��������� �� ������ ( � �.�. �
    ������, ���� ������ �������� � valueIndex ��������� ����� �������� �
    ������ ���� ������ 1 ���� ������ �� ������������) � �������� ���������
    ������� raiseNotFoundFlag ����� 0, ������������ null;
  - � ������, ���� ������������ ������ �������� � ������ valueIndex, �� ����
    string_value ��������� ������ �������� � �������� � ��������� ��������
    ����������� � ���� �� ����� date_value, number_value ��� string_value
    �������� ���� ��������;

  ( <body::getValue>)
*/
procedure getValue(
  rowData out nocopy opt_value%rowtype
  , optionId integer
  , prodValueFlag integer := null
  , instanceName varchar2 := null
  , usedOperatorId integer := null
  , usedValueFlag integer := null
  , valueTypeCode varchar2 := null
  , valueListFlag integer := null
  , valueIndex integer := null
  , decryptValueFlag integer := null
  , raiseNotFoundFlag integer := null
);

/* pproc: lockValue
  ��������� � ���������� ������ �������� ���������.

  ���������:
  rowData                     - ������ ������ ( �������)
  valueId                     - Id �������� ���������

  ���������:
  - � ������, ���� ������ ���� ��������� �������, ������������� ����������;

  ( <body::lockValue>)
*/
procedure lockValue(
  rowData out nocopy opt_value%rowtype
  , valueId integer
);

/* pfunc: createValue
  ������� �������� ���������.

  ���������:
  optionId                    - Id ���������
  valueTypeCode               - ��� ���� �������� ���������
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
  stringValue                 - ��������� �������� ��� ������ �� �������
                                ��������
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
  setValueListFlag            - ���������� �������� �������� ������ �� �������
                                ��������, ���������� � ��������� stringValue
                                ( 1 ��, 0 ��� ( �� ���������))
  valueListSeparator          - ������, ������������ � �������� �����������
                                � ������ �� ������� ��������
                                ( �� ��������� ������������ ";")
  valueListItemFormat         - ������ ��������� � ������ �� ������� ��������
                                ���� ���� ( �� ��������� ������������
                                "yyyy-mm-dd hh24:mi:ss" � ������������
                                ��������� �������)
  valueListDecimalChar        - ���������� ����������� ��� ������ �� �������
                                �������� ��������
                                ( �� ��������� ������������ �����)
  ignoreTestProdSensitiveFlag - ��� �������� �������� �� ��������� ���
                                ������������ �������� �������� �����
                                test_prod_sensitive_flag ���������
                                ( 1 ��, 0 ��� ( ����������� ���������� ���
                                  �����������))
                                ( �� ��������� 0)
  operatorId                  - Id ��������� ( �� ��������� �������)

  �������:
  Id �������� ���������.

  ( <body::createValue>)
*/
function createValue(
  optionId integer
  , valueTypeCode varchar2
  , prodValueFlag integer := null
  , instanceName varchar2 := null
  , usedOperatorId integer := null
  , dateValue date := null
  , numberValue number := null
  , stringValue varchar2 := null
  , valueIndex integer := null
  , setValueListFlag integer := null
  , valueListSeparator varchar2 := null
  , valueListItemFormat varchar2 := null
  , valueListDecimalChar varchar2 := null
  , ignoreTestProdSensitiveFlag integer := null
  , operatorId integer := null
)
return integer;

/* pproc: updateValue
  �������� �������� ���������.

  ���������:
  valueId                     - Id ��������
  valueTypeCode               - ��� ���� �������� ���������
  dateValue                   - �������� ���� ����
                                ( �� ��������� �����������)
  numberValue                 - �������� ��������
                                ( �� ��������� �����������)
  stringValue                 - ��������� �������� ��� ������ �� �������
                                ��������
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
  setValueListFlag            - ���������� �������� �������� ������ �� �������
                                ��������, ���������� � ��������� stringValue
                                ( 1 ��, 0 ��� ( �� ���������))
  valueListSeparator          - ������, ������������ � �������� �����������
                                � ������ �� ������� ��������
                                ( �� ��������� ������������ ";")
  valueListItemFormat         - ������ ��������� � ������ �� ������� ��������
                                ���� ���� ( �� ��������� ������������
                                "yyyy-mm-dd hh24:mi:ss" � ������������
                                ��������� �������)
  valueListDecimalChar        - ���������� ����������� ��� ������ �� �������
                                �������� ��������
                                ( �� ��������� ������������ �����)
  operatorId                  - Id ��������� ( �� ��������� �������)

  ( <body::updateValue>)
*/
procedure updateValue(
  valueId integer
  , valueTypeCode varchar2
  , dateValue date := null
  , numberValue number := null
  , stringValue varchar2 := null
  , valueIndex integer := null
  , setValueListFlag integer := null
  , valueListSeparator varchar2 := null
  , valueListItemFormat varchar2 := null
  , valueListDecimalChar varchar2 := null
  , operatorId integer := null
);

/* pproc: setValue
  ������������� �������� ���������.

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
  valueTypeCode               - ��� ���� �������� ���������
                                ( �� ��������� ������������ �� ������ ���������)
  dateValue                   - �������� ���� ����
                                ( �� ��������� �����������)
  numberValue                 - �������� ��������
                                ( �� ��������� �����������)
  stringValue                 - ��������� �������� ��� ������ �� �������
                                ��������
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
  setValueListFlag            - ���������� �������� �������� ������ �� �������
                                ��������, ���������� � ��������� stringValue
                                ( 1 ��, 0 ��� ( �� ���������))
  valueListSeparator          - ������, ������������ � �������� �����������
                                ��������� � ������ �� ������� ��������
                                ( �� ��������� ������������ ";")
  valueListItemFormat         - ������ ��������� � ������ �� ������� ��������
                                ���� ���� ( �� ��������� ������������
                                "yyyy-mm-dd hh24:mi:ss" � ������������
                                ��������� �������)
  valueListDecimalChar        - ���������� ����������� ��� ������ �� �������
                                �������� ��������
                                ( �� ��������� ������������ �����)
  operatorId                  - Id ��������� ( �� ��������� �������)

  ���������:
  - ��� ��������� �������� � ����������� �� ��� ������� ������������ ����
    ������� <createValue> ���� ��������� <updateValue>;

  ( <body::setValue>)
*/
procedure setValue(
  optionId integer
  , prodValueFlag integer
  , instanceName varchar2 := null
  , usedOperatorId integer := null
  , valueTypeCode varchar2 := null
  , dateValue date := null
  , numberValue number := null
  , stringValue varchar2 := null
  , valueIndex integer := null
  , setValueListFlag integer := null
  , valueListSeparator varchar2 := null
  , valueListItemFormat varchar2 := null
  , valueListDecimalChar varchar2 := null
  , operatorId integer := null
);

/* pproc: deleteValue
  ������� �������� ���������.

  ���������:
  valueId                     - Id �������� ���������
  operatorId                  - Id ��������� ( �� ��������� �������)

  ( <body::deleteValue>)
*/
procedure deleteValue(
  valueId integer
  , operatorId integer := null
);



/* group: �������������� ������� */

/* pproc: addOptionWithValue
  ��������� ����������� �������� �� ���������, ���� �� �� ��� ������ �����.

  ���������:
  moduleId                    - Id ������, � �������� ��������� ��������
  optionShortName             - ������� ������������ ���������
  valueTypeCode               - ��� ���� �������� ���������
  optionName                  - ������������ ���������
  objectShortName             - ������� ������������ ������� ������
                                ( �� ��������� �����������)
  objectTypeId                - Id ���� �������
                                ( �� ��������� �����������)
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
  instanceName                - ��� ���������� ��, � ������� �����
                                �������������� ��������
                                ( null ��� ����������� ( �� ���������))
  usedOperatorId              - Id ���������, ��� �������� �����
                                �������������� ��������
                                ( null ��� ����������� ( �� ���������))
  dateValue                   - �������� ���� ���� ��� ���� ���� ���
                                ������������ ��
                                ( �� ��������� �����������)
  testDateValue               - �������� ���� ���� ��� �������� ��
                                ( �� ��������� �����������)
  numberValue                 - �������� �������� ��� ���� ���� ���
                                ������������ ��
                                ( �� ��������� �����������)
  testNumberValue             - �������� �������� ��� �������� ��
                                ( �� ��������� �����������)
  stringValue                 - ��������� �������� ��� ������ �� �������
                                �������� ��� ���� ���� ��� ������������ ��
                                ( �� ��������� �����������)
  testStringValue             - ��������� �������� ��� ������ �� �������
                                �������� ��� �������� ��
                                ( �� ��������� �����������)
  setValueListFlag            - ���������� �������� �������� ������ �� �������
                                ��������, ���������� � ��������� stringValue
                                ( 1 ��, 0 ��� ( �� ���������))
  valueListSeparator          - ������, ������������ � �������� �����������
                                ��������� ������� ��������, ��������� �
                                ���������� stringValue � testStringValue
                                ( �� ��������� ������������ ";")
  valueListItemFormat         - ������ ��������� � ������ �� ������� ��������
                                ���� ���� ( �� ��������� ������������
                                "yyyy-mm-dd hh24:mi:ss" � ������������
                                ��������� �������)
  valueListDecimalChar        - ���������� ����������� ��� ������� ��������
                                ��������, ��������� � ���������� stringValue �
                                testStringValue
                                ( �� ��������� ������������ �����)
  changeValueFlag             - ���������� �������� ���������, ���� �� ���
                                ������ �����
                                ( 1 ��, 0 ��� ( �� ���������))
  operatorId                  - Id ��������� ( �� ��������� �������)

  ( <body::addOptionWithValue>)
*/
procedure addOptionWithValue(
  moduleId integer
  , optionShortName varchar2
  , valueTypeCode varchar2
  , optionName varchar2
  , objectShortName varchar2 := null
  , objectTypeId integer := null
  , valueListFlag integer := null
  , encryptionFlag integer := null
  , testProdSensitiveFlag integer := null
  , accessLevelCode varchar2 := null
  , optionDescription varchar2 := null
  , instanceName varchar2 := null
  , usedOperatorId integer := null
  , dateValue date := null
  , testDateValue date := null
  , numberValue number := null
  , testNumberValue number := null
  , stringValue varchar2 := null
  , testStringValue varchar2 := null
  , setValueListFlag integer := null
  , valueListSeparator varchar2 := null
  , valueListItemFormat varchar2 := null
  , valueListDecimalChar varchar2 := null
  , changeValueFlag integer := null
  , operatorId integer := null
);

/* pproc: getOptionValue
  ���������� ������� ���������� � �������� ������������� ����������.

  ���������:
  rowTable                    - ������� � �������
                                ( ��� <opt_option_value_table_t>)
                                ( �������)
  moduleId                    - Id ������, � �������� ��������� ���������
  objectShortName             - ������� ������������ ������� ������, � ��������
                                ��������� ��������� ( �� ��������� �����������
                                �� ����� ������)
  objectTypeId                - Id ���� �������
                                ( null ��� ���������� ������� ( �� ���������))
  usedOperatorId              - Id ���������, ��� �������� �����
                                �������������� ��������
                                ( null ��� ����������� ( �� ���������))

  ���������:
  - ��������� ��������� �������� ������ �� ������������� <v_opt_option_value>
    � ��������� ���������� usedOperatorId;

  ( <body::getOptionValue>)
*/
procedure getOptionValue(
  rowTable out nocopy opt_option_value_table_t
  , moduleId integer
  , objectShortName varchar2 := null
  , objectTypeId integer := null
  , usedOperatorId integer := null
);

end pkg_OptionMain;
/
