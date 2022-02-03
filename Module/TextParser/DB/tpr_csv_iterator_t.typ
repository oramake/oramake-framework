create or replace type tpr_csv_iterator_t
as object
(
/* db object type: tpr_csv_iterator_t
  �������� ��� ��������� ������ � ������� CSV.

  SVN root: Oracle/Module/TextParser
*/



/* group: �������� ���������� */



/* group: ���������� */

/* ivar: logger
  ����� ������.
*/
logger lg_logger_t,

/* ivar: textData
  �������� ��������� ������.
*/
textData clob,

/* ivar: headerRecordNumber
  ����� ������ � ���������� �����.
*/
headerRecordNumber integer,

/* ivar: skipRecordCount
  ����� ������������ ������� �� ������ ��������� ������.
*/
skipRecordCount integer,

/* iver: fieldSeparator
  ������-����������� ����� ������.
*/
fieldSeparator varchar2(1),

/* ivar: noEnclosedCharFlag
  ���� ���������� � ����� ������������ ������� ������������ ����� ( '"',
  ��-��������� ���������, ��� ������ ����� ����).
*/
noEnclosedCharFlag integer,


/* ivar: parsedRecordCount
  ����� ����������� ������� ( ������� �������).
*/
parsedRecordCount integer,

/* ivar: recordNumber
  ����� ������� ������.
  ��������� � 1, � ������ ���������� ������ recordNumber > <parsedRecordCount>.
*/
recordNumber integer,

/* ivar: dataLength
  ����� ��������� ������.
*/
dataLength integer,

/* ivar: dataOffset
  �������� � ��������� ������, ������� � �������� ����� ���������� ������.
*/
dataOffset integer,

/* ivar: buffer
  ����� ��� ������ ������ �� LOB.
*/
buffer varchar2(32767),

/* ivar: bufferReadSize
  ����� ������, ����������� � ����� �� ���� ���.
*/
bufferReadSize integer,

/* ivar: bufferLength
  ����� ������, ��������� � �����.
*/
bufferLength integer,

/* ivar: bufferOffset
  �������� � ������, ������� � �������� ����� ���������� ������.
*/
bufferOffset integer,

/* ivar: colValue
  �������� ����� ������� ������ � ���� ������.
*/
colValue tpr_string_table_t,

/* ivar: colValue
  �������� ����� ������� ������ � ���� CLOB.
*/
colValueClob tpr_clob_table_t,

/* ivar: fieldNameCount
  ����� ���� �����.
*/
fieldNameCount integer,

/* ivar: fieldNameList
  ������ ���� ����� ��� ������� ������ �� �����.
*/
fieldNameList varchar2(3100),



/* group: ������� */



/* group: �������� ���������� */

/* pproc: getFieldValue
  ���������� �������� ���� � ��������� �������.
  � ������ ������������� ������ ������������� ���������� � ����������� ��
  ������.

  ���������:
  fieldValue                  - �������� ���� � ���� ������
  fieldValueClob              - �������� ���� � ���� CLOB (���� �������� ��
                                ������� � ������)
  fieldNumber                 - ����� ���� ( ������� � 1)

  �������:
  - �������� ����

  ( <body::getFieldValue>)
*/
member procedure getFieldValue(
  fieldValue out varchar2
, fieldValueClob out clob
, fieldNumber integer
),



/* group: �������� ���������� */

/* pfunc: tpr_csv_iterator_t
  ������� ��������.

  ���������:
  textData                    - ��������� ������
  headerRecordNumber          - ����� ������, ���������� �������� ����� ( 0
                                �����������, �� ��������� 0)
  skipRecordCount             - ����� ������������ ������� �� ������ ���������
                                ������ ( �� ��������� headerRecordNumber)
  fieldSeparator              - ������-����������� ����� ������
                                ( �� ��������� ";")
  noEnclosedCharFlag          - ���� ���������� � ����� ������������ �������
                                ������������ ����� ( ��������, '"', ��-���������
                                ���������, ��� ������ ����� ����)

  ���������:
  - ����� �������� ��������� ����� ������� ��������� ������� ( �� �����������
    <getDataLength>) ������ ���� ������� ������� <next> ����� ������ ���������
    ������ ( ������ ��� ���������� � ������� ����� while ... loop);

  ( <body::tpr_csv_iterator_t>)
*/
constructor function tpr_csv_iterator_t(
  textData clob
  , headerRecordNumber integer := null
  , skipRecordCount integer := null
  , fieldSeparator varchar2 := null
  , noEnclosedCharFlag number := null
)
return self as result,

/* pfunc: getDataLength
  ���������� ����� �������� ��������� ������.

  �������:
  - ����� �������� ��������� ������ ( � ������ �� ���������� ���������� 0)

  ( <body::getDataLength>)
*/
member function getDataLength
return integer,

/* pfunc: next
  ��������� �� ��������� ������ � �������.

  �������:
  - true � ������ ��������� ��������, false ��� ���������� ��������� ������

  ( <body::next>)
*/
member function next(
  self in out tpr_csv_iterator_t
)
return boolean,

/* pfunc: getRecordNumber
  ���������� ����� ������� ������.
  ������ ���������� � 1, ��� ���� � ��������� ���������� ����������� �� ������
  ������ ������ ( ���� ����� �������).

  �������:
  - ����� ������� ������ ( ������� � 1) ��� null ��� ���������� ������� ������

  ( <body::getRecordNumber>)
*/
member function getRecordNumber
return integer,

/* pfunc: getFieldCount
  ���������� ����� ����� � ������� ������.

  �������:
  - ����� ����� � ������� ������ ��� null ��� ���������� ������� ������

  ( <body::getFieldCount>)
*/
member function getFieldCount
return integer,

/* pfunc: getFieldNumber
  ���������� ���������� ����� ���� �� �����.

  ���������:
  fieldName                   - ��� ����
  isNotFoundRaised            - ������������ �� ���������� � ������
                                ���������� ���� � ��������� ������
                                ( 1 �� ( �� ���������), 0 ���)

  �������:
  ���������� ����� ���� ( ������� � 1) ���� null, ���� ���� ����������� �
  �������� ��������� isNotFoundRaised ����� 0.

  ���������:
  - � �������� ����� ������������ ������ 30 �������� ( ��������� � ��������
    ������� ������������) �� �������� ���� � ������ ��������� ��� �����
    ��������;

  ( <body::getFieldNumber>)
*/
member function getFieldNumber(
  fieldName varchar2
  , isNotFoundRaised integer := null
)
return integer,

/* pfunc: isFieldExists
  ��������� ������� ���� � ��������� ������.

  ���������:
  fieldName                   - ��� ����

  �������:
  1 � ������ ������� ����, ����� 0.

  ���������:
  - ��� �������� ������� ���� ������������ ������� <getFieldNumber>;

  ( <body::isFieldExists>)
*/
member function isFieldExists(
  fieldName varchar2
)
return integer,

/* pfunc: getProcessedCount
  ���������� ����� ������������ ������� � �������. ����������� ������� ������
  � �� ����������� ����������� ������ �� ��������� ������������ skipRecordCount.

  �������:
  - ����� ������������ ������� ( >= 0)

  ( <body::getProcessedCount>)
*/
member function getProcessedCount
return integer,

/* pfunc: getString
  ���������� �������� ���� � ��������� ������� � ���� ������.

  ���������:
  fieldNumber                 - ����� ���� ( ������� � 1)

  �������:
  - �������� ���� � ���� ������

  ( <body::getString>)
*/
member function getString(
  self in out tpr_csv_iterator_t
, fieldNumber integer
)
return varchar2,

/* pfunc: getString( NAME)
  ���������� �������� ���� � ��������� ������ � ���� ������.

  ���������:
  fieldName                   - �������� ����
  isNotFoundRaised            - ������������ �� ���������� � ������
                                ���������� ���� � ��������� ������
                                ( 1 �� ( �� ���������), 0 ���)

  �������:
  - �������� ���� � ���� ������

  ( <body::getString( NAME)>)
*/
member function getString(
  self in out tpr_csv_iterator_t
, fieldName varchar2
, isNotFoundRaised integer := null
)
return varchar2,

/* pfunc: getNumber
  ���������� �������� ���� � ��������� ������� � ���� �����.

  ���������:
  fieldNumber                 - ����� ���� ( ������� � 1)
  decimalCharacter            - ������ ����������� �����������
  isValueErrorRaised          - ������������ �� ���������� ( 1,0 )
                                � ������ ������������� ��������������.
                                ��-��������� ( null ) ������������.
  isTrimPercent               - ����� ��������������� � ����� ������� ��
                                �������� ���� ����������� ������� ��������
                                ( "%") � �������
                                ( 1 ��, 0 ��� ( �� ���������))

  �������:
  - �������� ���� � ���� �����

  ( <body::getNumber>)
*/
member function getNumber(
  self in out tpr_csv_iterator_t
, fieldNumber integer
, decimalCharacter varchar2 := null
, isValueErrorRaised integer := null
, isTrimPercent integer := null
)
return number,

/* pfunc: getNumber( NAME)
  ���������� �������� ���� � ��������� ������ � ���� �����.

  ���������:
  fieldName                   - �������� ����
  decimalCharacter            - ������ ����������� �����������
  isValueErrorRaised          - ������������ �� ���������� ( 1,0 )
                                � ������ ������������� ��������������.
                                ��-��������� ( null ) ������������.
  isNotFoundRaised            - ������������ �� ���������� � ������
                                ���������� ���� � ��������� ������
                                ( 1 �� ( �� ���������), 0 ���)
  isTrimPercent               - ����� ��������������� � ����� ������� ��
                                �������� ���� ����������� ������� ��������
                                ( "%") � �������
                                ( 1 ��, 0 ��� ( �� ���������))

  �������:
  - �������� ���� � ���� �����

  ( <body::getNumber( NAME)>)
*/
member function getNumber(
  self in out tpr_csv_iterator_t
, fieldName varchar2
, decimalCharacter varchar2 := null
, isValueErrorRaised integer := null
, isNotFoundRaised integer := null
, isTrimPercent integer := null
)
return number,

/* pfunc: getDate
  ���������� �������� ���� � ��������� ������� � ���� ����.

  ���������:
  fieldNumber                 - ����� ���� ( ������� � 1)
  format                      - ������ ���� ( ��� to_date())
  isValueErrorRaised           - ������������ �� ���������� ( 1,0 )
                                � ������ ������������� ��������������.
                                ��-��������� ( null ) ������������.

  �������:
  - �������� ���� � ���� ����

  ( <body::getDate>)
*/
member function getDate(
  self in out tpr_csv_iterator_t
, fieldNumber integer
, format varchar2
, isValueErrorRaised integer := null
)
return date,

/* pfunc: getDate( NAME)
  ���������� �������� ���� � ��������� ������ � ���� ����.

  ���������:
  fieldName                   - �������� ����
  format                      - ������ ���� ( ��� to_date())
  isValueErrorRaised           - ������������ �� ���������� ( 1,0 )
                                � ������ ������������� ��������������.
                                ��-��������� ( null ) ������������.
  isNotFoundRaised            - ������������ �� ���������� � ������
                                ���������� ���� � ��������� ������
                                ( 1 �� ( �� ���������), 0 ���)

  �������:
  - �������� ���� � ���� ����

  ( <body::getDate( NAME)>)
*/
member function getDate(
  self in out tpr_csv_iterator_t
, fieldName varchar2
, format varchar2
, isValueErrorRaised integer := null
, isNotFoundRaised integer := null
)
return date,

/* pfunc: getClob
  ���������� �������� ���� � ��������� ������� � ���� CLOB.

  ���������:
  fieldNumber                 - ����� ���� ( ������� � 1)

  �������:
  - �������� ���� � ���� CLOB

  ( <body::getClob>)
*/
member function getClob(
  self in out tpr_csv_iterator_t
, fieldNumber integer
)
return clob,

/* pfunc: getClob( NAME)
  ���������� �������� ���� � ��������� ������ � ���� ������.

  ���������:
  fieldName                   - �������� ����
  isNotFoundRaised            - ������������ �� ���������� � ������
                                ���������� ���� � ��������� ������
                                ( 1 �� ( �� ���������), 0 ���)

  �������:
  - �������� ���� � ���� ������

  ( <body::getClob( NAME)>)
*/
member function getClob(
  self in out tpr_csv_iterator_t
, fieldName varchar2
, isNotFoundRaised integer := null
)
return clob

)
/
