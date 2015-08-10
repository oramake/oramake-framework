create or replace package body pkg_ExcelCreateUtility as

/* package body: pkg_ExcelCreateUtility::body */



/* group: Переменные */



/* ivar: logger
   Объект для логгирования
*/
logger lg_logger_t := lg_logger_t.getLogger(
    moduleName  => pkg_ExcelCreate.Module_Name
  , packageName => 'pkg_ExcelCreateUtility'
  );



/* group: Функции */



/* func: getExcelDate
   Возвращает дату в формате Excel.

   Параметры:
     dt - дата

   Возврат:
     - строка с датой в формате Excel
*/
function getExcelDate (
  dt in date
  )
return varchar2
is
-- getExcelDate
begin

  return to_char( dt, 'yyyy-mm-dd"T"' );

exception
  when others then
    raise_application_error(
        pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при формировании даты в формате Excel ( ' ||
            'dt="' || to_char( dt, 'dd.mm.yyyy' ) || '"' ||
            ' )'
          )
      , true
      );

end getExcelDate;



/* func: getExcelDateTime
   Возвращает дату+время в формате Excel.

   Параметры:
     dt - дата+время

   Возврат:
     - строка с датой+временем в формате Excel
*/
function getExcelDateTime (
  dt in date
  )
return varchar2
is
-- getExcelDateTime
begin

  return to_char( dt, 'yyyy-mm-dd"T"hh24:mi:ss."000"' );

exception
  when others then
    raise_application_error(
        pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при формировании даты-времени в формате Excel ( ' ||
            'dt="' || to_char( dt, 'dd.mm.yyyy hh24:mi:ss' ) || '"' ||
            ' )'
          )
      , true
      );

end getExcelDateTime;



/* func: encodeXmlValue
   Экранирует все спецсимволы XML (<, >, ', ", &) в переданной строке для генерации
   well-formed XML

   Параметры:
     xmlValue - текстовое значение xml-тэга

   Возврат:
     - экранированное текстовое значение xml-тэга
*/
function encodeXmlValue (
  xmlValue in varchar2
  )
return varchar2
is
-- encodeXmlValue
begin

  return dbms_xmlgen.convert( xmlValue, dbms_xmlgen.ENTITY_ENCODE );

exception
  when others then
    raise_application_error(
        pkg_Error.ErrorStackInfo
      , logger.errorStack(
          'Ошибка при экранировании спецсимволов XML ( ' ||
            'xmlValue="' || xmlValue || '"' ||
            ' )'
          )
      , true
      );

end encodeXmlValue;



end pkg_ExcelCreateUtility;
/
