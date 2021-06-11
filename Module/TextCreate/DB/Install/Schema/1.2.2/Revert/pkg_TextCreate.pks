create or replace package pkg_TextCreate is
/* package: pkg_TextCreate
  ����� ������ ��� ������ � clob

  SVN root: Oracle/Module/TextCreate
*/

/* const: Module_Name
  �������� ������, � �������� ��������� �����.
*/
Module_Name constant varchar2(30) := 'TextCreate';

/* pproc: NewText
  �������������� ����� ����� ��� ������������
  ( <body::NewText>)
*/
procedure NewText;

/* pproc: Append
  ���������� ������ � �����
  ( <body::Append>)
*/  
procedure Append( 
  str varchar2
);  

/* pfunc: GetClob
  �������� �������������� clob
  ( <body::GetClob>).
*/
function GetClob
return clob;

/* pproc: Append(destClob)
  ���������� ������ � ����� 
  c �������������� ����������� ���������� ��������
  ( <body::Append(destClob)>)
*/  
procedure Append(
  destClob in out nocopy clob
  , clobLength in out nocopy integer
  , stringBuffer in out nocopy varchar2
  , maxBufferSize integer
  , str varchar2
);

/* pfunc: GetZip
  �������� �������������� zip-�����
  ( <body::GetZip>).
*/
function GetZip(filename varchar2)
return blob;

end pkg_TextCreate;
/
