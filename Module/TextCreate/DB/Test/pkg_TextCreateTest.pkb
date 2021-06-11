create or replace package body pkg_TextCreateTest is
/* package body: pkg_TextCreateTest::body */



/* group: ���������� */

/* ivar: logger
  ����� ������.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => pkg_TextCreate.Module_Name
  , objectName  => 'pkg_TextCreateTest'
);



/* group: ������� */

/* proc: testConversion
  ������������ �������������� �������� ������ � ��������� � �������.  (
  ������� <pkg_TextCreate.convertToClob>, <pkg_TextCreate.convertToBlob>).

  ���������:
  testString                  - ������ ��� �������� ������
*/
procedure testConversion(
  testString varchar2
)
is
-- testConversion
begin
  pkg_TestUtility.beginTest( 'testConversion');
  pkg_TestUtility.compareChar(
    testString
    , to_char( pkg_TextCreate.convertToClob( pkg_TextCreate.convertToBlob( cast( testString as clob))))
    , 'converted text'
  );
  pkg_TestUtility.endTest();
end testConversion;

/* proc: testBase64Conversion
  ������������ �������������� ������ � Base64 � �������� ������ � �������.  (
  ������� <pkg_TextCreate.base64Decode>, <pkg_TextCreate.base64Encode>).

  ���������:
  testString                  - ������ ��� �������� ������
*/
procedure testBase64Conversion(
  testString varchar2
)
is
-- testBase64Conversion
begin
  pkg_TestUtility.beginTest( 'testBase64Conversion');
  pkg_TestUtility.compareChar(
    testString
    , to_char(
        pkg_TextCreate.base64Encode(
          pkg_TextCreate.base64Decode( testString)
        )
      )
    , 'incorrect decode/encode base64'
  );
  pkg_TestUtility.endTest();
end testBase64Conversion;

end pkg_TextCreateTest;
/
