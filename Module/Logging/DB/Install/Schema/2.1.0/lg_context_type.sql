alter table
  lg_context_type
add (
  temporary_use_date            date
)
/

comment on column lg_context_type.temporary_use_date is
  '���� ���������� ������������� ���������� ���� ��������� (null ���� ��� ��������� �� �������� ���������). ��������� ��� ��������� ��������� ������������� �� ��������� ������������� ����� ����� ��� ���������� ������������'
/
