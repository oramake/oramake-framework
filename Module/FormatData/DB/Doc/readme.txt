title: ��������

������ ����������� ��� �������������� � ��������� ������.

�������� ���� �������� ������: ������� � ����� ����� �������������� �������
��������� ���������� ������, ������� ���������� ������������ � ���������
�������, ��������� � ������� � ������������� ��������.

������: ������������� �������� ����� ������� "�" � "�" ��� ��������� ( � �����
� ����� ������������� ������� � ���� ������ ��� ����� ������), �������������
�������������� �������� � ��������� ���� � ������� � ������� �������������
��������� ( "�������" � "�������").

��������������� ������� ������� ( <pkg_FormatData>):
- format* ( ��������������);

  ������� ��������� ������������ �������������� ������� ������, ������� ���
  ������������ ��������� � ������, ��� ������������� ��������� ����� ������.

- getBase* ( ������� �����);

  ���������� ������� ����� ��� �������� ������ ( � �.�. � ��������������
  ����������� ���������), ��������������� ��� ������, �������� �����������
  ������������ �� �������� ������.

- check* ( �������� ������������)

  ��������� ������������ ���������� �������� ( ��������, ��� ������ ���
  ����������� ����������� �����).


��� ���� ������� ��������������� ������ ������� *Expr, ������� ����������
SQL-���������, ����������� �������� ��� �� ����� ���������, ��� �������������
� ������������ SQL. ������������� ���� ������� � ������������ SQL ������ ������
PL/SQL ��������� ��������� �������� ������������ ������� � ������������������
�� ������� ������� ������ ( ������: ����������� SQL-��������� �� �������
getBaseCodeExpr ��� ���� ����� �� 260 ���. ������� � ������������ SQL ��������
����� ��� � 3 ���� ������� ��� ����� �� SQL ������� getBaseCode �� 260 ���.
�������).

��������� ����� ������������� ������� ��������:
- ��� ���������� ���������� �������� ������ ����������� �������������� ������
  � ������� ������� Format* � ���������� �� � �������;

  ��� ������������� ������� getBase* ������������� ��������� � ���� �� �������
  �������� ��������.

(code)
  ...
                                        --�������� ������
  execute immediate '
insert into
  tmp_table
(
  id
  , last_name
  , first_name
  , middle_name
  , birth_year
  , birth_month
  , birth_day
  , passport_serie
  , passport_number
  , base_last_name
  , base_first_name
  , base_middle_name
  , base_passport_serie
  , base_passport_number
)
select
  a.id
  , a.last_name
  , a.first_name
  , a.middle_name
  , ' || pkg_FormatData.formatCodeExpr( 'to_char( a.birth_year)', 4) || '
    as birth_year
  , ' || pkg_FormatData.formatCodeExpr( 'to_char( a.birth_month)', 2) || '
    as birth_month
  , ' || pkg_FormatData.formatCodeExpr( 'to_char( a.birth_day)', 2) || '
    as birth_day
  , a.passport_serie
  , a.passport_number
  , ' || pkg_FormatData.getBaseLastNameExpr( 'a.last_name') || '
    as base_last_name
  , ' || pkg_FormatData.getBaseFirstNameExpr( 'a.first_name') || '
    as base_first_name
  , ' || pkg_FormatData.getBaseMiddleNameExpr( 'a.middle_name') || '
    as base_middle_name
  , ' || pkg_FormatData.getBaseCodeExpr( 'a.passport_serie') || '
    as base_passport_serie
  , ' || pkg_FormatData.getBaseCodeExpr( 'a.passport_number') || '
    as base_passport_number
from
  tmp_table@' || sourceDbLink || ' a
'
  ;
  ...
(end)

- ��� ���������� ������ �������� �������� ������������� �� ��� �� �����
  ��������, ��� � ��� ���������� ������, ����� ���� ����������� ����� ��
  ����������� � ������� ��������������� �����;

(code)
  ...
                                        --��������� �����
  DoFind(
    lastName          => pkg_FormatData.getBaseLastName( lastName)
    , firstName       => pkg_FormatData.getBaseFirstName( firstName)
    , middleName      => pkg_FormatData.getBaseMiddleName( middleName)
    , lastNameOld     => pkg_FormatData.getBaseLastName( lastNameOld)
    , birthYear       => pkg_FormatData.formatCode( birthYear, 4)
    , birthMonth      => pkg_FormatData.formatCode( birthMonth, 2)
    , birthDay        => pkg_FormatData.formatCode( birthDay, 2)
    , passportSerie   => pkg_FormatData.getBaseCode( passportSerie)
    , passportNumber  => pkg_FormatData.getBaseCode( passportNumber)
  );
  ...
(end)
