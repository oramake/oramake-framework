create or replace package pkg_ConvertNameInCase is
/* package: pkg_ConvertNameInCase
  ������������ ����� ������ ConvertNameInCase.
  ������� ��� ������ �� ���������� ��� �� �������.
*/



/* group: ��������� */

/* const: Module_Name
  �������� ������, � �������� ��������� �����.
*/
Module_Name constant varchar2(30) := 'ConvertNameInCase';

/* const: LastName_TypeExceptionCode
  ��� ���� ���������� "�������".
*/
LastName_TypeExceptionCode constant varchar2(1) := 'L';

/* const: FirstName_TypeExceptionCode
  ��� ���� ���������� "���".
*/
FirstName_TypeExceptionCode constant varchar2(1) := 'F';

/* const: MiddleName_TypeExceptionCode
  ��� ���� ���������� "��������".
*/
MiddleName_TypeExceptionCode constant varchar2(1) := 'M';

/* const: Native_CaseCode
  ��� ������������� ������.
*/
Native_CaseCode constant varchar2(10) := 'NAT';

/* const: Genetive_CaseCode
  ��� ������������ ������.
*/
Genetive_CaseCode constant varchar2(10) := 'GEN';

/* const: Dative_CaseCode
  ��� ���������� ������.
*/
Dative_CaseCode constant varchar2(10) := 'DAT';

/* const: Accusative_CaseCode
  ��� ������������ ������.
*/
Accusative_CaseCode constant varchar2(10) := 'ACC';

/* const: Ablative_CaseCode
  ��� ������������� ������.
*/
Ablative_CaseCode constant varchar2(10) := 'ABL';

/* const: Preposition_CaseCode
  ��� ����������� ������.
*/
Preposition_CaseCode constant varchar2(10) := 'PREP';

/* const: Men_Code
  ��� �������� ����.
*/
Men_SexCode constant varchar2(10) := 'M';

/* const: Women_Code
  ��� �������� ����.
*/
Women_SexCode constant varchar2(10) := 'W';



/* group: ������� */

/* pproc: updateExceptionCase
  ��������� ����������/���������� ������ � ����������� ����������.

  ������� ���������:
    exceptionCaseId             - �� ������ ����������
    stringException             - ������ ����������
    stringNativeCase            - ������ ���������� � ������������ ������
    strConvertInCase            - ������, ���������� ���������� ��������
                                  convertNameInCase
    formatString                - ������ ������ ��� �������������� (
                                  "L"- ������ �������� �������
                                  , "F"- ������ �������� ���
                                  , "M" - ������ �������� ��������)
                                  , ���� �������� null, �� �������,
                                  ��� ������ ������ "LFM"
    sexCode                     - ��� (M � �������, W - �������)
    caseCode                    - ��� ������ (NAT � ������������
                                  , GEN - �����������
                                  , DAT - ���������, ACC � �����������
                                  , ABL - ������������, PREP - ����������)
    operatorId                  - �� ���������

  �������� ��������� �����������.

  ( <body::updateExceptionCase>)
*/
procedure updateExceptionCase(
  exceptionCaseId integer default null
  , stringException varchar2
  , stringNativeCase varchar2
  , stringConvertInCase varchar2
  , formatString varchar2
  , sexCode varchar2 default null
  , caseCode varchar2
  , operatorId integer
);

/* pfunc: convertNameInCase
  ������� �������������� ��� � ���������� ������. ������� ����
  � ������� � � ���������� ������ ������ ���������. ������� �������
  ������ ���������� ���� �� ����� ������ "-", ��� ���� ���������� �������� ��
  � ����� ����� �� �����.

  ������� ���������:
    nameText                    - ������ ��� ��������������
    formatString                - ������ ������ ��� ��������������
    caseCode                    - ��� ������ ��������������
    sexCode                     - ���

  �������:
    ������ � ��������� ������.

  ( <body::convertNameInCase>)
*/
function convertNameInCase(
  nameText varchar2
  , formatString varchar2
  , caseCode varchar2
  , sexCode varchar2 default null
)
return varchar2;

end pkg_ConvertNameInCase;
/
