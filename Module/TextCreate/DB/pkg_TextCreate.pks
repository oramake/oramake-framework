create or replace package pkg_TextCreate is
/* package: pkg_TextCreate
  ����� ������ ��� ������ � clob

  SVN root: Oracle/Module/TextCreate
*/

/* const: Module_Name
  �������� ������, � �������� ��������� �����.
*/
Module_Name constant varchar2(30) := 'TextCreate';


/* group: ������� */



/* group: ������������ ��������� ������ */

/* pproc: newText
  �������������� ����� ����� ��� ������������

  �����������:
    - ���������� dbms_lob.createtemporary
      ��� ������������� clob
    - ��������� clob �� ������
    - �������������� ���������� <currentClobLength>,
      <maxBufferLength>
    - ������� <buffer>

  ( <body::newText>)
*/
procedure newText;

/* pproc: append ( str )
  ���������� ������ � �����

  ���������:
    str - ������, ��� null ���������� ���������� ������

  ���������:
    - ���� �� ������ ���������� �� ��� ������ <NewText>, �� ����
      ����� �� ��� ������������������ �����, �� ������������
      ����������

  ( <body::append ( str )>)
*/
procedure append(
  str varchar2
);

/* pproc: append ( clob )
   ���������� clob � �����

   ���������:
     �                         - ��������� ���������� � ���� clob

   ���������:
    - ���� �� ������ ���������� �� ��� ������ <newText>, �� ����
      ����� �� ��� ������������������ �����, �� ������������
      ����������

  ( <body::append ( clob )>)
*/
procedure append (
  c in clob
  );

/* pfunc: getClob
  �������� �������������� ����� � ���� clob

  ���������:
    filename                 - �������� ����� ������ ������

  �������:
    - <destinationClob>

  ���������:
    - ���������� ����� � <destinationClob> � ������� append('')
    - ��������� <destinationClob>,
      �������������� ��������, ������ �� ��

  ( <body::getClob>)
*/
function getClob
return clob;

/* pproc: append ( destClob )
  ���������� ������ � �����
  c �������������� ����������� ���������� ��������

  ���������:
    destClob                 - clob ��� ������������
    clobLength               - ������� ������ clob. ��������� ���
                               �����������
    stringBuffer             - ��������� �����
    maxBufferSize            - ������������ ������ ������
    str                      - ������ ��� ����������,
                               ��� null ( '') ���������� ���������� ������
                               � clob

  ���������:
    - destClob, clobLength, maxBufferSize ������ ����
      ����������������

  ( <body::append ( destClob )>)
*/
procedure append(
  destClob in out nocopy clob
  , clobLength in out nocopy integer
  , stringBuffer in out nocopy varchar2
  , maxBufferSize integer
  , str varchar2
);

/* pfunc: getZip
  �������� �������������� zip-�����

  ���������:
    filename                 - �������� ����� ������ ������

  �������:
    - blob � zip-�������

  ���������:
      �������� GetClob, �.�. �������������� ����������� ��� ��������.

  ( <body::getZip>)
*/
function getZip(filename varchar2)
return blob;



/* group: �������������� ��������� ������ */

/* pfunc: convertToClob
  �������������� BLOB ( �������� ������� �������� ������) � CLOB ( ��������
  ������� ��������� ������). ��������������, ��� ������ � ��������� ��.

  ���������:
  binaryData                  - �������� ������ ��� ��������������

  ( <body::convertToClob>)
*/
function convertToClob(
  binaryData blob
)
return clob;

/* pfunc: convertToBlob
  �������������� �LOB ( �������� ������� ��������� ������) � BLOB ( ��������
  ������� �������� ������). ��������������, ��� ������ � ��������� ��.

  ���������:
  textData                    - ��������� ������ ��� ��������������

  ( <body::convertToBlob>)
*/
function convertToBlob(
  textData clob
)
return blob;

end pkg_TextCreate;
/
