create or replace package body pkg_ExcelCreateUtility as

/* package body: pkg_ExcelCreateUtility::body */



/* group: ���������� */



/* ivar: logger
   ������ ��� ������������
*/
logger lg_logger_t := lg_logger_t.getLogger(
    moduleName  => pkg_ExcelCreate.Module_Name
  , packageName => 'pkg_ExcelCreateUtility'
  );



/* group: ������� */



/* func: getExcelDate
   ���������� ���� � ������� Excel.

   ���������:
     dt - ����

   �������:
     - ������ � ����� � ������� Excel
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
          '������ ��� ������������ ���� � ������� Excel ( ' ||
            'dt="' || to_char( dt, 'dd.mm.yyyy' ) || '"' ||
            ' )'
          )
      , true
      );

end getExcelDate;



/* func: getExcelDateTime
   ���������� ����+����� � ������� Excel.

   ���������:
     dt - ����+�����

   �������:
     - ������ � �����+�������� � ������� Excel
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
          '������ ��� ������������ ����-������� � ������� Excel ( ' ||
            'dt="' || to_char( dt, 'dd.mm.yyyy hh24:mi:ss' ) || '"' ||
            ' )'
          )
      , true
      );

end getExcelDateTime;



/* func: encodeXmlValue
   ���������� ��� ����������� XML (<, >, ', ", &) � ���������� ������ ��� ���������
   well-formed XML

   ���������:
     xmlValue - ��������� �������� xml-����

   �������:
     - �������������� ��������� �������� xml-����
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
          '������ ��� ������������� ������������ XML ( ' ||
            'xmlValue="' || xmlValue || '"' ||
            ' )'
          )
      , true
      );

end encodeXmlValue;



end pkg_ExcelCreateUtility;
/
