create or replace package pkg_TextCreate is
/* package: pkg_TextCreate
  ����� ������ ��� ������ � clob

  SVN root: Oracle/Module/TextCreate
*/

/* group: ��������� */

/* group: ����� */

/* const: Module_Name
  �������� ������, � �������� ��������� �����.
*/
Module_Name constant varchar2(30) := 'TextCreate';


/* group: ��������� */

/* const: UTF8_CharsetName
  ������������ ��������� UTF-8
*/
UTF8_CharsetName constant varchar2(30) := 'UTF8';

/* const: Windows1251_CharsetName
  ������������ ��������� Windows 1251
*/
Windows1251_CharsetName constant varchar2(30) := 'CL8MSWIN1251';


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
  �������� �������������� zip-�����. � ������������ ������ ���������.

  ���������:
    filename                 - �������� ����� ������ ������
    charsetName              - ������������ ��������� ( ��-��������� ��������� ��)

  �������:
    destinationBlob          - blob � zip-�������

  ���������:
      �������� GetClob, �.�. �������������� ����������� ��� ��������.

  ( <body::getZip>)
*/
function getZip(
  filename      varchar2
  , charsetName varchar2 default null
)
return blob;



/* group: �������������� ��������� ������ */

/* pfunc: convertToClob
  �������������� BLOB ( �������� ������� �������� ������) � CLOB ( ��������
  ������� ��������� ������). � ������������ ������ ���������.

  ���������:
    binaryData               - �������� ������ ��� ��������������
    charsetName              - ������������ ��������� ( ��-��������� ��������� ��)

  �������:
    resultText               - ��������������� ��������� ������

  ( <body::convertToClob>)
*/
function convertToClob(
  binaryData    blob
  , charsetName varchar2 default null
)
return clob;

/* pfunc: convertToBlob
  �������������� �LOB ( �������� ������� ��������� ������) � BLOB ( ��������
  ������� �������� ������). � ������������ ������ ���������.

  ���������:
    textData                 - ��������� ������ ��� ��������������
    charsetName              - ������������ ��������� ( ��-��������� ��������� ��)

  �������:
    resultBlob               - ��������������� �������� ������

  ( <body::convertToBlob>)
*/
function convertToBlob(
  textData      clob
  , charsetName varchar2 default null
)
return blob;

/* pfunc: base64Decode
  �������������� Base64 ( �������� ������� ��������� ������ � ���������
  Base64) � BLOB ( �������� ������� �������� ������).

  ������� ���������:
    textData                                  - ������ � Base64

  �������:
    resultBlob                                - �������������� blob

  ( <body::base64Decode>)
*/
function base64Decode(
  textData      clob
)
return blob;

/* pfunc: base64Encode
  �������������� BLOB ( �������� ������� �������� ������)
  � Base64 ( �������� ������� ��������� ������ � ��������� Base64).

  ������� ���������:
    binaryData                                - �������� ������ ��� ��������������

  �������:
    resultClob                                - �������������� clob

  ( <body::base64Encode>)
*/
function base64Encode(
  binaryData    blob
)
return clob;

end pkg_TextCreate;
/
