create or replace package pkg_FormatBase is
/* package: pkg_FormatBase
  ������� ��������� � ������� ������.

  SVN root: Oracle/Module/FormatData
*/

/* group: ��������� */

/* const: Module_Name
  �������� ������, � �������� ��������� �����.
*/
Module_Name constant varchar2(30) := 'FormatData';

/* const: Zero_Value
  ������ ��� �������� ���������� ��������.
*/
Zero_Value constant varchar2(10) := '-';

/* group: ��� �������� */

/* const: FirstName_AliasTypeCode
  ��� ���� ��������� "���"
*/
FirstName_AliasTypeCode constant varchar2(10) := 'FN';

/* const: MiddleName_AliasTypeCode
  ��� ���� ��������� "��������"
*/
MiddleName_AliasTypeCode constant varchar2(10) := 'MN';

/* const: NoValue_AliasTypeCode
  ��� ���� ��������� ��� �������� ���������� ��������.
*/
NoValue_AliasTypeCode constant varchar2(10) := 'NV';

end pkg_FormatBase;
/
