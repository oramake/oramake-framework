# makefile: ��������� ������
#
# ����������� ������� � ��������� ��� make, ������� ����� ���������������� �
# ���������������� ������.
#
# ���������� �� ����������:
# - ������������ �� ������ �������� ����� ( �������, ����������) ������
#   ���������� � �������� "csp" ( "custom public");
# - ��������� ����� ������ ���������� � �������� "csl" ( "custom local");
#



#
# group: ����������� ����� ������������ ��
#


# build var: cspGetProductionDbName_TestDbList
# ������ �������� �� ��� ������� <getProductionDbName>.
# ����� ������ ����������� � ������ ��������, ��� ���� � ��� �� �� �������
# ����� ���������� <cspGetProductionDbName_ProdDbList> ������ ���� �������
# ��� ������������ �� ��� ������ �������� ��.
#
cspGetProductionDbName_TestDbList = \
  testdb testdb2 testdb3

# build var: cspGetProductionDbName_ProdDbList
# ������������ �� ��� �������� ��, ��������� � ������
# <cspGetProductionDbName_TestDbList>.
# ����� �� ������ ���� ������� � ������ �������� �������� � ������������
# � ������������ ���������� ����� ���������� �� ( ��������, ������ �����
# ����� � ������� �������� � �.�.).
#
cspGetProductionDbName_ProdDbList = \
  ProdDb ProdDb  ProdDb2

# build var: cspGetProductionDbName_ExtraDbList
# ������������ ��, ������������� � ������ <cspGetProductionDbName_ProdDbList>
# ( ��� ������� ��� �������� ��).
# ����� �� ����������� � ������ �������� ( ����������
# <cspGetProductionDbName_ProdDbList>).
#
cspGetProductionDbName_ExtraDbList = \
  ProdDb3 \
  ProdDb4

