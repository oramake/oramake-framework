create or replace package pkg_TextCreateTest is
/* package: pkg_TextCreateTest
  ����� ��� ������������ ������.

  SVN root: Oracle/Module/TextCreate
*/



/* group: ������� */

/* pproc: testConversion
  ������������ �������������� �������� ������ � ��������� � �������.  (
  ������� <pkg_TextCreate.convertToClob>, <pkg_TextCreate.convertToBlob>).

  ���������:
  testString                  - ������ ��� �������� ������

  ( <body::testConversion>)
*/
procedure testConversion(
  testString varchar2
);

/* pproc: testBase64Conversion
  ������������ �������������� ������ � Base64 � �������� ������ � �������.  (
  ������� <pkg_TextCreate.base64Decode>, <pkg_TextCreate.base64Encode>).

  ���������:
  testString                  - ������ ��� �������� ������

  ( <body::testBase64Conversion>)
*/
procedure testBase64Conversion(
  testString varchar2
);

end pkg_TextCreateTest;
/
