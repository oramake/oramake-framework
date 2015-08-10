create or replace package pkg_ExcelCreateUtility as
  
/* package: pkg_ExcelCreateUtility
   ����� �������� ��������������� ������� ��� ������ ExcelCreate
   
   SVN root: Oracle/Module/ExcelCreate
*/



/* group: ��������� */



/* const: Module_Name
   ������, � �������� ��������� �����
*/
Module_Name constant varchar2(30) := 'ExcelCreate';



/* group: ������� */



/* func: getExcelDate
   ���������� ���� � ������� Excel.

   ���������:
     dt - ����

   �������:
     - ������ � ����� � ������� Excel
   
   (<body::getExcelDate>)
*/
function getExcelDate (
  dt in date
  )
return varchar2;



/* func: getExcelDateTime
   ���������� ����+����� � ������� Excel.

   ���������:
     dt - ����+�����

   �������:
     - ������ � �����+�������� � ������� Excel
   
   (<body::getExcelDateTime>)
*/
function getExcelDateTime (
  dt in date
  )
return varchar2;



/* func: encodeXmlValue
   ���������� ��� ����������� XML (<, >, ', ", &) � ���������� ������ ��� ���������
   well-formed XML

   ���������:
     xmlValue - ��������� �������� xml-����

   �������:
     - �������������� ��������� �������� xml-����
   
   (<body::encodeXmlValue>)
*/
function encodeXmlValue (
  xmlValue in varchar2
  )
return varchar2;



end pkg_ExcelCreateUtility;
/
