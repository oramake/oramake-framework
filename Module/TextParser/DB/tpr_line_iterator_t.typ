@oms-drop-type tpr_line_iterator_t
create or replace type tpr_line_iterator_t
as object
(
/* db object type: tpr_line_iterator_t
  �������� ��� ����������� ���������� ��������� ������

  SVN root: Oracle/Module/TextParser
*/


/* group: �������� ���������� */


/* group: ���������� */


/* ivar: textData
  �������� ��������� ������.
*/
textData clob,

/* ivar: dataLength
  ����� ��������� ������.
*/
dataLength integer,

/* ivar: dataOffset
  �������� � ��������� ������, ������� � �������� ����� ���������� ������.
*/
dataOffset integer,

/* ivar: lineClobFlag
   �������, ��� ������ ������������ � ���� clob
*/
lineClobFlag number(1),

/* ivar: lineText
   ������ ������ � ���� varchar2 (����������� ������ ��� lineClobFlag = 0)
*/
lineText varchar2(32767),

/* ivar: lineData
   ������ ������ � ���� clob (����������� ������ ��� lineClobFlag = 1)
*/
lineData clob,

/* ivar: lineNumber
  ����� ������� ������
*/
lineNumber integer,

/* ivar: logger
  ������������ ������ ��� ������������
*/
logger lg_logger_t,


/* group: �������� ���������� */


/* group: ������� */


/* pfunc: tpr_line_iterator_t
  ������� ��������.

  ���������:
  textData                    - ��������� ������

  ( <body::tpr_line_iterator_t>)
*/
constructor function tpr_line_iterator_t(
  textData clob
)
return self as result,


/* pfunc: next
  ��������� �� ��������� ������.

  �������:
  - true � ������ ��������� ��������, false ��� ���������� ��������� ������

  ( <body::next>)
*/
member function next(
  self in out nocopy tpr_line_iterator_t
)
return boolean,


/* pfunc: getLine
  ���������� ������� ������

  �������:
  - ��������� ��������� ������; null, ���� ������ �� �����������
    ��� � ������ ���������� ����� �����

  (<body::getLine>)
*/
member function getLine
return varchar2,


/* pfunc: getLineClob
   ���������� ������� ������ � ���� clob

   �������:
     - ��������� ��������� ������; null, ���� ������ �� ����������� ��� �
       ������ ���������� ����� �����

   (<body::getLineClob>)
*/
member function getLineClob
return clob,


/* pfunc: getLineNumber
  ���������� ����� ������� ������

  �������:
  - ����� ��������� ������; 0, ���� ������ �� �����������;
    null, ���� ��������� ����� �����

  (<body::getLineNumber>)
*/
member function getLineNumber
return integer
)
/