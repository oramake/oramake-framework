create or replace package pkg_TextCreateTest is
/* package: pkg_TextCreateTest
  Пакет для тестирования модуля.

  SVN root: Oracle/Module/TextCreate
*/



/* group: Функции */

/* pproc: testConversion
  Тестирование преобразования двоичных данных в текстовые и обратно.  (
  функции <pkg_TextCreate.convertToClob>, <pkg_TextCreate.convertToBlob>).

  Параметры:
  testString                  - строка для тестовых данных

  ( <body::testConversion>)
*/
procedure testConversion(
  testString varchar2
);

/* pproc: testBase64Conversion
  Тестирование преобразования текста в Base64 в двоичные данные и обратно.  (
  функции <pkg_TextCreate.base64Decode>, <pkg_TextCreate.base64Encode>).

  Параметры:
  testString                  - строка для тестовых данных

  ( <body::testBase64Conversion>)
*/
procedure testBase64Conversion(
  testString varchar2
);

end pkg_TextCreateTest;
/
