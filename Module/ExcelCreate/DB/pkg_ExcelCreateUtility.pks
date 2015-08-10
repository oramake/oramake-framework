create or replace package pkg_ExcelCreateUtility as
  
/* package: pkg_ExcelCreateUtility
   Пакет содержит вспомогательные функции для модуля ExcelCreate
   
   SVN root: Oracle/Module/ExcelCreate
*/



/* group: Константы */



/* const: Module_Name
   Модуль, к которому относится пакет
*/
Module_Name constant varchar2(30) := 'ExcelCreate';



/* group: Функции */



/* func: getExcelDate
   Возвращает дату в формате Excel.

   Параметры:
     dt - дата

   Возврат:
     - строка с датой в формате Excel
   
   (<body::getExcelDate>)
*/
function getExcelDate (
  dt in date
  )
return varchar2;



/* func: getExcelDateTime
   Возвращает дату+время в формате Excel.

   Параметры:
     dt - дата+время

   Возврат:
     - строка с датой+временем в формате Excel
   
   (<body::getExcelDateTime>)
*/
function getExcelDateTime (
  dt in date
  )
return varchar2;



/* func: encodeXmlValue
   Экранирует все спецсимволы XML (<, >, ', ", &) в переданной строке для генерации
   well-formed XML

   Параметры:
     xmlValue - текстовое значение xml-тэга

   Возврат:
     - экранированное текстовое значение xml-тэга
   
   (<body::encodeXmlValue>)
*/
function encodeXmlValue (
  xmlValue in varchar2
  )
return varchar2;



end pkg_ExcelCreateUtility;
/
