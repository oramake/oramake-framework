create or replace package pkg_TextCreateJava as
/* package: pkg_TextCreateJava
  ��������� � Java ���������� ��� ������ ��������� ������ ��� ���������� �� � ���� Blob

  SVN root: Oracle/Module/TextCreate
*/

/* const: Module_Name
  �������� ������, � �������� ��������� �����.
*/
Module_Name constant varchar2(30) := 'TextCreate';
/* pfunc: blobCompress

  ������ ��������� blob

  ���������:

   sourceBlob   - ������ ��� ������
   sourceFileName - �������� ����� ������ ������

  ������������ ��������:  
  
  blob (zip �����)

*/
 function blobCompress(
     sourceBlob blob
   , sourceFileName varchar2
 ) return blob as language java name
   'pkg_TextCreate.compress(oracle.sql.BLOB, java.lang.String) return oracle.sql.BLOB';
end;
/