create or replace package pkg_TestUtility
authid current_user
as
/* package: pkg_TestUtility
  ������������ ����� ������ TestUtility.

  SVN root: Oracle/Module/TestUtility
*/


/* group: ��������� */


/* const: Module_Name
  �������� ������, � �������� ��������� �����.
*/
Module_Name constant varchar2(30) := 'TestUtility';



/* group: ������� */

/* pfunc: isTestFailed
  ���������� ������, ���� �� ���������� �������������� ����� ( �������� ����
  ������������) ������������� ������.

  �������:
  ������ ���� ������������� ������, ����� ����.

  ( <body::isTestFailed>)
*/
function isTestFailed
return boolean;

/* pproc: beginTest
   ������ �����.

   ���������:
     messageText                    - ����� ���������

  ( <body::beginTest>)
*/
procedure beginTest(
  messageText varchar2
);

/* pproc: endTest
  ���������� �����.

  ( <body::endTest>)
*/
procedure endTest;

/* pproc: failTest
  ���������� ���������� �����.

  ���������:
  failMessageText                 - ��������� � ���������� ����������

  ( <body::failTest>)
*/
procedure failTest(
  failMessageText varchar2
);

/* pproc: addTestInfo
  �������� ���������� � ���������� �� �����.

  ( <body::addTestInfo>)
*/
procedure addTestInfo(
  addonMessage varchar2
  , position integer := null
);

/* pfunc: getTestTimeSecond
  ��������� ��������� ������� ���������� ����� ( � ��������).

  ( <body::getTestTimeSecond>)
*/
function getTestTimeSecond
return number;

/* pfunc: compareChar ( func )
   ��������� ��������� ������.

   ���������:
     actualString                   - ������� ������
     expectedString                 - ��������� ������
     failMessageText                - ��������� ��� ������������ �����
     considerWhitespace             - ���� ��������� �������� ��� ���������
                                      ( ��-��������� ��� )

   �������:
     - true � ������ ���������� ����� ��� false � ��������� ������

  ( <body::compareChar ( func )>)
*/
function compareChar (
    actualString        in varchar2
  , expectedString      in varchar2
  , failMessageText     in varchar2
  , considerWhitespace in boolean := null
  )
return boolean;

/* pproc: compareChar ( proc )
   ��������� ��������� ������.

   ���������:
     actualString                   - ������� ������
     expectedString                 - ��������� ������
     failMessageText                - ��������� ��� ������������ �����
     considerWhitespace             - ���� ��������� �������� ��� ���������
                                      ( ��-��������� ��� )

  ( <body::compareChar ( proc )>)
*/
procedure compareChar (
    actualString        in varchar2
  , expectedString      in varchar2
  , failMessageText     in varchar2
  , considerWhitespace  in boolean := null
  );

/* pfunc: compareRowCount ( func, table )
   ��������� �������� ���-�� ����� � ������� � ��������� ���-���.

   ���������:
     tableName                      - ��� �������
     filterCondition                - ������� ���������� ����� � �������
     expectedRowCount               - ��������� ���-�� �����
     failMessageText                - ��������� ��� ������������ ���-�� �����

   �������:
     - true � ������ ���������� ���-�� ����� ��� false � ��������� ������

   ����������: �������� filterCondition ���������� � ������ where ������� ���
   ���������

  ( <body::compareRowCount ( func, table )>)
*/
function compareRowCount (
    tableName            in varchar2
  , filterCondition      in varchar2 := null
  , expectedRowCount     in pls_integer
  , failMessageText      in varchar2 := null
  )
return boolean;

/* pproc: compareRowCount ( proc, table )
   ��������� �������� ���-�� ����� � ������� � ��������� ���-���.

   ���������:
     tableName                      - ��� �������
     filterCondition                - ������� ���������� ����� � �������
     expectedRowCount               - ��������� ���-�� �����
     failMessageText                - ��������� ��� ������������ ���-�� �����

   ����������: �������� filterCondition ���������� � ������ where ������� ���
   ���������

  ( <body::compareRowCount ( proc, table )>)
*/
procedure compareRowCount (
    tableName            in varchar2
  , filterCondition      in varchar2 := null
  , expectedRowCount     in pls_integer
  , failMessageText      in varchar2 := null
  );

/* pfunc: compareRowCount ( func, cursor )
   ��������� �������� ���-�� ����� � sys_refcursor � ��������� ���-���.

   ���������:
     rc                             - sys_refcursor
     filterCondition                - ������� ���������� ����� � �������
     expectedRowCount               - ��������� ���-�� �����
     failMessageText                - ��������� ��� ������������ ���-�� �����

   �������:
     - true � ������ ���������� ���-�� ����� ��� false � ��������� ������

  ( <body::compareRowCount ( func, cursor )>)
*/
function compareRowCount (
    rc                   in sys_refcursor
  , filterCondition      in varchar2 := null
  , expectedRowCount     in pls_integer
  , failMessageText      in varchar2 := null
  )
return boolean;

/* pproc: compareRowCount ( proc, cursor )
   ��������� �������� ���-�� ����� � sys_refcursor � ��������� ���-���.

   ���������:
     rc                             - sys_refcursor
     filterCondition                - ������� ���������� ����� � �������
     expectedRowCount               - ��������� ���-�� �����
     failMessageText                - ��������� ��� ������������ ���-�� �����

  ( <body::compareRowCount ( proc, cursor )>)
*/
procedure compareRowCount (
    rc                   in sys_refcursor
  , filterCondition      in varchar2 := null
  , expectedRowCount     in pls_integer
  , failMessageText      in varchar2 := null
  );

/* pfunc: compareQueryResult ( func, cursor )
  ��������� ������ � sys_refcursor � ����������.

  ���������:
  rc                          - ����������� ������ (sys_refcursor)
  expectedCsv                 - ��������� ������ � CSV
  idColumnName                - ��� ������� ������� � Id ������ ��� �������� �
                                ������ ��������� (��� ����� ��������, �������
                                ������������ ��� ���������)
                                (�� ��������� �����������)
  considerWhitespace          - ���� ��������� �������� ��� ��������� ���������
                                ������
                                (�� ��������� ���)
  failMessagePrefix           - ������� ��������� ��� ������������ ������
                                (�� ��������� �����������)

  �������:
  - true � ������ ���������� ������ ��� false � ��������� ������

  ( <body::compareQueryResult ( func, cursor )>)
*/
function compareQueryResult (
  rc in out nocopy sys_refcursor
, expectedCsv clob
, idColumnName varchar2 := null
, considerWhitespace boolean := null
, failMessagePrefix varchar2 := null
)
return boolean;

/* pproc: compareQueryResult ( proc, cursor )
  ��������� ������ � sys_refcursor � ����������.

  ���������:
  rc                          - ����������� ������ (sys_refcursor)
  expectedCsv                 - ��������� ������ � CSV
  idColumnName                - ��� ������� ������� � Id ������ ��� �������� �
                                ������ ��������� (��� ����� ��������, �������
                                ������������ ��� ���������)
                                (�� ��������� �����������)
  considerWhitespace          - ���� ��������� �������� ��� ��������� ���������
                                ������
                                (�� ��������� ���)
  failMessagePrefix           - ������� ��������� ��� ������������ ������
                                (�� ��������� �����������)

  ( <body::compareQueryResult ( proc, cursor )>)
*/
procedure compareQueryResult (
  rc in out nocopy sys_refcursor
, expectedCsv clob
, idColumnName varchar2 := null
, considerWhitespace boolean := null
, failMessagePrefix varchar2 := null
);

/* pfunc: compareQueryResult ( func, table )
  ��������� ������ � ������� � ����������.

  ���������:
  tableName                   - ��� �������
  filterCondition             - ������� ���������� ����� � �������
                                (�� ��������� �����������)
  expectedCsv                 - ��������� ������ � CSV
  orderByExpression           - ��������� ��� ������������ ���������� �����
                                (�� ��������� �����������)
  idColumnName                - ��� ������� � Id ������ ��� �������� � ������
                                ���������
                                (�� ��������� �����������)
  considerWhitespace          - ���� ��������� �������� ��� ��������� ���������
                                ������
                                (�� ��������� ���)
  failMessagePrefix           - ������� ��������� ��� ������������ ������
                                (�� ��������� �����������)

  �������:
  - true � ������ ���������� ������ ��� false � ��������� ������

  ( <body::compareQueryResult ( func, table )>)
*/
function compareQueryResult(
  tableName varchar2
, filterCondition varchar2 := null
, expectedCsv clob
, orderByExpression varchar2 := null
, idColumnName varchar2 := null
, considerWhitespace boolean := null
, failMessagePrefix varchar2 := null
)
return boolean;

/* pproc: compareQueryResult ( proc, table )
  ��������� ������ � ������� � ����������.

  ���������:
  tableName                   - ��� �������
  filterCondition             - ������� ���������� ����� � �������
                                (�� ��������� �����������)
  expectedCsv                 - ��������� ������ � CSV
  orderByExpression           - ��������� ��� ������������ ���������� �����
                                (�� ��������� �����������)
  idColumnName                - ��� ������� � Id ������ ��� �������� � ������
                                ���������
                                (�� ��������� �����������)
  considerWhitespace          - ���� ��������� �������� ��� ��������� ���������
                                ������
                                (�� ��������� ���)
  failMessagePrefix           - ������� ��������� ��� ������������ ������
                                (�� ��������� �����������)

  ( <body::compareQueryResult ( proc, table )>)
*/
procedure compareQueryResult(
  tableName varchar2
, filterCondition varchar2 := null
, expectedCsv clob
, orderByExpression varchar2 := null
, idColumnName varchar2 := null
, considerWhitespace boolean := null
, failMessagePrefix varchar2 := null
);

end pkg_TestUtility;
/
