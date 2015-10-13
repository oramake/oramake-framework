create or replace package pkg_FormatData is
/* package: pkg_FormatData
  ������������ ����� ������ FormatData.

  SVN root: Oracle/Module/FormatData
*/



/* group: ������� */

/* pfunc: getZeroValue
  ���������� ������, ������������ ���������� ��������.

  �������: �������� ��������� <pkg_FormatBase.Zero_Value>.

  ( <body::getZeroValue>)
*/
function getZeroValue
return varchar2;



/* group: �������������� */

/* pfunc: formatCode
  ���������� ��������������� ���.

  ������������:
  - ��������� ������� �������, ��������� � ����;
  - ���������� ��� �������/����������� ������� �����, �������, �������������;
  - ���� ������� ����� ���� ( newLength), �� �������� ���������� �� ������
    ����� ��� ����������� �������� ������;

  ���������:
  sourceCode                  - �������� ���
  newLength                   - ��������� ����� ����

  �������:
  - ��������������� ���

  ( <body::formatCode>)
*/
function formatCode(
  sourceCode varchar2
  , newLength integer := null
)
return varchar2;

/* pfunc: formatCodeExpr
  ���������� ��������� ��� ������������ ����.
  ������������� ��� ������������� � ������������ SQL ( ��������, �����
  execute immediate), ������������ ��������� ����������� � �������
  <formatCode>.

  ���������:
  varName                     - ��� ���������� � �������� �����
  newLength                   - ��������� ����� ����

  �������:
  - ������ � SQL-���������� ��� ���������� varName ��� ���������� ������������

  ( <body::formatCodeExpr>)
*/
function formatCodeExpr(
  varName varchar2
  , newLength integer := null
)
return varchar2;

/* pfunc: formatString
  ���������� ��������������� ������.

  ������������:
  - ������ ��������� ���������� �� ������;
  - ���������� ��������� � �������� �������;
  - ��������� ������ ������ �������� ( �� 2 �� 4) ������ ������ ���������� ��
    ���� ������;

  ���������:
  sourceString                - �������� ������

  �������:
  - ��������������� ������

  ( <body::formatString>)
*/
function formatString(
  sourceString varchar2
)
return varchar2;

/* pfunc: formatStringExpr
  ���������� ��������� ��� ������������ ������.
  ������������� ��� ������������� � ������������ SQL ( ��������, �����
  execute immediate), ������������ ��������� ����������� � �������
  <formatString>.

  ���������:
  varName                     - ��� ���������� � �������� �������
                                �������������� ����������

  �������:
  - ������ � SQL-���������� ��� ���������� varName ��� ���������� ������������

  ( <body::formatStringExpr>)
*/
function formatStringExpr(
  varName varchar2
)
return varchar2;

/* pfunc: formatCyrillicString
  ���������� ��������������� ������ � ����������.

  ������������� � ������������, ����������� �������� <formatString>,
  ������������:
  - ������� ������� �� ��������� ��������� �������� �� �������������;
  - ������ ����� "�" �� ����� "�";

  ���������:
  sourceString                - �������� ������

  �������:
  - ��������������� ������

  ( <body::formatCyrillicString>)
*/
function formatCyrillicString(
  sourceString varchar2
)
return varchar2;

/* pfunc: formatCyrillicStringExpr
  ���������� ��������� ��� ������������ ������ � ����������.
  ������������� ��� ������������� � ������������ SQL ( ��������, �����
  execute immeaidiate), ������������ ��������� ����������� � �������
  <formatCyrillicString>.

  ���������:
  varName                     - ��� ���������� � �������� �������
                                �������������� ����������

  �������:
  - ������ � SQL-���������� ��� ���������� varName ��� ���������� ������������

  ( <body::formatCyrillicStringExpr>)
*/
function formatCyrillicStringExpr(
  varName varchar2
)
return varchar2;

/* pfunc: formatName
  ���������� ��������������� ��������.

  ������������� � ������������, ����������� �������� <formatCyrillicString>,
  ������������:
  - ��������� �������� �������� ( ������ ����� ����� ���������, ���������
    ��������);

  ���������:
  sourceString                - �������� ������ � ���������

  �������:
  - ��������������� ���

  ( <body::formatName>)
*/
function formatName(
  sourceString varchar2
)
return varchar2;

/* pfunc: formatNameExpr
  ���������� ��������� ��� ������������ ��������.
  ������������� ��� ������������� � ������������ SQL ( ��������, �����
  execute immeaidiate), ������������ ��������� ����������� � �������
  <formatName>.

  ���������:
  varName                     - ��� ���������� � �������� �������

  �������:
  - ������ � SQL-���������� ��� ���������� varName ��� ���������� ������������

  ( <body::formatNameExpr>)
*/
function formatNameExpr(
  varName varchar2
)
return varchar2;



/* group: ������� ����� */

/* pfunc: getBaseCode
  ���������� ������� �������� ����.

  ������������:
  - ��������� ������� �������, ���������, ����, ��������� ( "*");
  - ����������� �������������� ������ �� ��������� �������� ��������� �
    ��������;
  - ����� "�" ���������� �� ����� 3, ����� "��" �� "��";
  - ���������� ��� �������/����������� ������� �����, �������, �������������,
    ���������;
  - ������� ����������� � ������� �������;
  - ����������� ������ �������� "-", � ����� ��������� �������������� ��������
    �� <fd_alias>, �� null;
  - ���� ����� minLength � ����� ���� ������ minLength, �� �� ���������
    ������������ � ��������������� �������� null;

  ���������:
  sourceCode                  - �������� ���
  minLength                   - ����������� ����� ���� ( ���� ����� ���� ������,
                                �� �� ��������� ������������ � ���������� ��
                                null, �� ��������� ��� �����������)

  �������:
  - ������� �������� ����

  ( <body::getBaseCode>)
*/
function getBaseCode(
  sourceCode varchar2
  , minLength integer := null
)
return varchar2;

/* pfunc: getBaseCodeExpr
  ���������� ��������� ��� ��������� �������� �������� ����.
  ������������� ��� ������������� � ������������ SQL ( ��������, �����
  execute immeaidiate), ������������ ���������� ����������� � �������
  <getBaseCode>.

  ���������:
  varName                     - ��� ���������� � �������� �����
  minLength                   - ����������� ����� ���� ( ���� ����� ���� ������,
                                �� �� ��������� ������������ � ���������� ��
                                null, �� ��������� ��� �����������)

  �������:
  - ������ � SQL-���������� ��� ���������� varName ��� ���������� ������������

  ( <body::getBaseCodeExpr>)
*/
function getBaseCodeExpr(
  varName varchar2
  , minLength integer := null
)
return varchar2;

/* pfunc: getBaseName
  ���������� ������� ����� �������� ��� ������������� ��� ���������.

  ������������� � ���������������, ����������� �������� <formatName>,
  ������������:
  - ������ ��������� �������������� �������� �� <fd_alias>, �� null;
  - ������ ����� "�" �� "�";
  - ���������� ��� �������/����������� ������� �����, �������, �������������,
    ���������, ����;

  ���������:
  sourceName                  - �������� ������ � ���������

  �������:
  - ������� ����� ��������

  ( <body::getBaseName>)
*/
function getBaseName(
  sourceName varchar2
)
return varchar2;

/* pfunc: getBaseNameExpr
  ���������� ��������� ��� ��������� �������� �������� ��������.
  ������������� ��� ������������� � ������������ SQL ( ��������, �����
  execute immeaidiate), ������������ ���������� ����������� � �������
  <getBaseName>.

  ���������:
  varName                     - ��� ���������� � �������� ���������

  �������:
  - ������ � SQL-���������� ��� ���������� varName ��� ���������� ������������

  ( <body::getBaseNameExpr>)
*/
function getBaseNameExpr(
  varName varchar2
)
return varchar2;

/* pfunc: getBaseLastName
  ���������� ������� ����� ������� ��� ������������� ��� ���������.

  ������������� � ���������������, ����������� �������� <formatName>,
  ������������ ������ ����� "�" �� "�".

  ���������:
  lastName                    - �������� ������ � ��������

  �������:
  - ������� ����� �������

  ( <body::getBaseLastName>)
*/
function getBaseLastName(
  lastName varchar2
)
return varchar2;

/* pfunc: getBaseLastNameExpr
  ���������� ��������� ��� ��������� �������� �������� �������.
  ������������� ��� ������������� � ������������ SQL ( ��������, �����
  execute immeaidiate), ������������ ���������� ����������� � �������
  <getBaseLastName>.

  ���������:
  varName                     - ��� ���������� � �������� ���������

  �������:
  - ������ � SQL-���������� ��� ���������� varName ��� ���������� ������������

  ( <body::getBaseLastNameExpr>)
*/
function getBaseLastNameExpr(
  varName varchar2
)
return varchar2;

/* pfunc: getBaseFirstName
  ���������� ������� ����� ����� ��� ������������� ��� ���������.

  ���������� ������� <getBaseLastName> � �������������� ������� ��������� �����
  �� ������� �����.

  ���������:
  firstName                - �������� ������ � ������

  �������:
  - ������� ����� �����

  ( <body::getBaseFirstName>)
*/
function getBaseFirstName(
  firstName varchar2
)
return varchar2;

/* pfunc: getBaseFirstNameExpr
  ���������� ��������� ��� ��������� �������� �������� �����.
  ������������� ��� ������������� � ������������ SQL ( ��������, �����
  execute immeaidiate), ������������ ���������� ����������� � �������
  <getBaseFirstName>.

  ���������:
  varName                     - ��� ���������� � �������� ���������

  �������:
  - ������ � SQL-���������� ��� ���������� varName ��� ���������� ������������

  ( <body::getBaseFirstNameExpr>)
*/
function getBaseFirstNameExpr(
  varName varchar2
)
return varchar2;

/* pfunc: getBaseMiddleName
  ���������� ������� ����� �������� ��� ������������� ��� ���������.

  ���������� ������� <getBaseLastName> � �������������� ������� ���������
  �������� �� ������� ����� � �������� '-' ( <getZeroValue>) ������ null.

  ���������:
  middleName                  - �������� ������ � ���������

  �������:
  - ������� ����� ��������

  ( <body::getBaseMiddleName>)
*/
function getBaseMiddleName(
  middleName varchar2
)
return varchar2;

/* pfunc: getBaseMiddleNameExpr
  ���������� ��������� ��� ��������� �������� �������� ��������.
  ������������� ��� ������������� � ������������ SQL ( ��������, �����
  execute immeaidiate), ������������ ���������� ����������� � �������
  <getBaseMiddleName>.

  ���������:
  varName                     - ��� ���������� � �������� ���������

  �������:
  - ������ � SQL-���������� ��� ���������� varName ��� ���������� ������������

  ( <body::getBaseMiddleNameExpr>)
*/
function getBaseMiddleNameExpr(
  varName varchar2
)
return varchar2;



/* group: �������� ������������ */

/* pfunc: checkDrivingLicense
  ��������� ������������ ������ ������������� �������������.

  ������� ������������: ������������� ������� "99��999999" ( ��� "9" �����
  ����� �� 0 �� 9, "�" ����� ������������� �����).

  ���������:
  sourceCode                  - ����� ��������� ( ��� ���������� ������� ������
                                ���� �������������� �������)

  �������:
  1     - ���������� �����
  0     - ������������ �����
  null  - �������� ����������� ( ���� � �������� ��������� ��� ������� null)

  ( <body::checkDrivingLicense>)
*/
function checkDrivingLicense(
  sourceCode varchar2
)
return integer;

/* pfunc: checkDrivingLicenseExpr
  ���������� ��������� ��� �������� ������������ ������ �������������
  �������������, ��������� ���������� �������� ��������� ������ �������
  <checkDrivingLicense>.

  ���������:
  varName                     - ��� ���������� � ������� ���������

  �������:
  ������ � SQL-���������� ��� ���������� varName ��� ���������� ��������.

  ( <body::checkDrivingLicenseExpr>)
*/
function checkDrivingLicenseExpr(
  varName varchar2
)
return varchar2;

/* pfunc: checkForeignPassport
  ��������� ������������ ������ ������������ ��������.

  ������� ������������: ������������� ������� "999999999" ( ������ ���� ��
  0 �� 9).

  ���������:
  sourceCode                  - ����� ��������� ( ��� ���������� ������� ������
                                ���� �������������� �������)

  �������:
  1     - ���������� �����
  0     - ������������ �����
  null  - �������� ����������� ( ���� � �������� ��������� ��� ������� null)

  ( <body::checkForeignPassport>)
*/
function checkForeignPassport(
  sourceCode varchar2
)
return integer;

/* pfunc: checkForeignPassportExpr
  ���������� ��������� ��� �������� ������������ ������ ������������ ��������,
  ��������� ���������� �������� ��������� ������ �������
  <checkForeignPassport>.

  ���������:
  varName                     - ��� ���������� � ������� ���������

  �������:
  ������ � SQL-���������� ��� ���������� varName ��� ���������� ��������.

  ( <body::checkForeignPassportExpr>)
*/
function checkForeignPassportExpr(
  varName varchar2
)
return varchar2;

/* pfunc: checkInn
  ��������� ������������ ��� ( ������������������ ������ �����������������)
  � ������� �������� ����������� ���� ������.

  ���������:
  sourceCode                  - ��� ( ��� ���������� ������� ������ ����
                                �������������� �������)

  �������:
  1     - ���������� �����
  0     - ������������ �����
  null  - �������� ����������� ( ���� � �������� ��������� ��� ������� null)

  ( <body::checkInn>)
*/
function checkInn(
  sourceCode varchar2
)
return integer;

/* pfunc: checkInnExpr
  ���������� ��������� ��� �������� ������������ ��� ( ������������������
  ������ �����������������), ��������� ���������� �������� ��������� ������
  ������� <checkInn>.

  ���������:
  varName                     - ��� ���������� �� ��������� ���

  �������:
  ������ � SQL-���������� ��� ���������� varName ��� ���������� ��������

  ( <body::checkInnExpr>)
*/
function checkInnExpr(
  varName varchar2
)
return varchar2;

/* pfunc: checkPensionFundNumber
  ��������� ������������ ������ ����������� ������������� � ������� ��������
  ����������� ���� ������.

  ���������:
  sourceCode                  - ������ ����������� ������������� ( ���
                                ���������� ������� ������ ���� ��������������
                                �������)

  �������:
  1     - ���������� �����
  0     - ������������ �����
  null  - �������� ����������� ( ���� � �������� ��������� ��� ������� null)

  ( <body::checkPensionFundNumber>)
*/
function checkPensionFundNumber(
  sourceCode varchar2
)
return integer;

/* pfunc: checkPensionFundNumberExpr
  ���������� ��������� ��� �������� ������������ ������ �����������
  �������������, ��������� ���������� �������� ��������� ������ �������
  <checkPensionFundNumber>.

  ���������:
  varName                     - ��� ���������� � ������� �����������
                                �������������

  �������:
  ������ � SQL-���������� ��� ���������� varName ��� ���������� ��������

  ( <body::checkPensionFundNumberExpr>)
*/
function checkPensionFundNumberExpr(
  varName varchar2
)
return varchar2;

/* pfunc: checkPts
  ��������� ������������ ����� � ������ ��� ( �������� ������������� ��������).

  ������� ������������: ������������� ������� "99CC999999" ( ��� "9" �����
  ����� �� 0 �� 9, "C" ����� ����� ( �� ��������� ������ ���������, ��.
  ��������� ����)).

  ���������:
  sourceCode                  - ����� � ����� ��������� ( ��� ����������
                                ������� ������ ���� �������������� �������)
  isUseCyrillic               - � ������� � �������� "�" ����� ��������������
                                ���������
                                ( 1 �� ( �� ���������), 0 ���)
  isUseLatin                  - � ������� � �������� "�" ����� ��������������
                                ��������
                                ( 1 ��, 0 ��� ( �� ���������))

  �������:
  1     - ���������� ��������
  0     - ������������ ��������
  null  - �������� ����������� ( ���� � �������� ��������� ��� ������� null)

  ( <body::checkPts>)
*/
function checkPts(
  sourceCode varchar2
  , isUseCyrillic integer := null
  , isUseLatin integer := null
)
return integer;

/* pfunc: checkPtsExpr
  ���������� ��������� ��� �������� ������������ ����� � ������ ���
  ( �������� ������������� ��������), ��������� ���������� �������� ���������
  ������ ������� <checkPts>.

  ���������:
  varName                     - ��� ���������� � ������� ���������
  isUseCyrillic               - � ������� � �������� "�" ����� ��������������
                                ���������
                                ( 1 �� ( �� ���������), 0 ���)
  isUseLatin                  - � ������� � �������� "�" ����� ��������������
                                ��������
                                ( 1 ��, 0 ��� ( �� ���������))

  �������:
  ������ � SQL-���������� ��� ���������� varName ��� ���������� ��������.

  ( <body::checkPtsExpr>)
*/
function checkPtsExpr(
  varName varchar2
  , isUseCyrillic integer := null
  , isUseLatin integer := null
)
return varchar2;

/* pfunc: checkVin
  ��������� ������������ VIN ( ������������������ ������ ����������).

  ������� ������������: ����� ����� 17 � ������������ ������ ���������� �������.

  ���������:
  sourceCode                  - VIN ( ��� ���������� ������� ������
                                ���� �������������� �������)

  �������:
  1     - ���������� �����
  0     - ������������ �����
  null  - �������� ����������� ( ���� � �������� ��������� ��� ������� null)

  ( <body::checkVin>)
*/
function checkVin(
  sourceCode varchar2
)
return integer;

/* pfunc: checkVinExpr
  ���������� ��������� ��� �������� ������������ VIN ( ������������������
  ������ ����������), ��������� ���������� �������� ��������� ������ �������
  <checkVin>.

  ���������:
  varName                     - ��� ���������� �� ��������� VIN

  �������:
  ������ � SQL-���������� ��� ���������� varName ��� ���������� ��������.

  ( <body::checkVinExpr>)
*/
function checkVinExpr(
  varName varchar2
)
return varchar2;

end pkg_FormatData;
/
