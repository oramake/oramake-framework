/*
 * pfunc: str_concat
 * ������� �������������.
 * ������������ �������� ���������� ������������� �������� ������� value.
 * ������� ���������� ��������� ��� 'str_concat_t', ����������� ��������� ODCIAggregate
 * ������ ������ ������� ���������� � �������� ���� 'str_concat_t'.
 * � ��������� ��� ����������:
 *          - ����������� ��-��������� - '|'
 *          - ������������ ����� ������������ ������ - 4000
 *          - ����� �� �������� '...' � ����� ������, ���� � ����� ��������� ������������ ����� - �� (1)
 *          - ����� �� ������������ ����������, ���� ����� �������������� ������ ��������� ������������ ����� - ��� (0)
 *
 * ��������� - value - ���� ������� ���������� ����
 *
 * ���������� - ������ ���������� ������������� �������� ���� value ����������� �������� �������� ����� str_concat_t (��-��������� '|') �� ������ ��������.
 *
 * ��. ����� - �������� ���� str_concat_t
 */

CREATE OR REPLACE FUNCTION str_concat ( value  VARCHAR2 )
 RETURN VARCHAR2
 DETERMINISTIC
  AGGREGATE USING
  str_concat_t;
/