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
  testdb

# build var: cspGetProductionDbName_ProdDbList
# ������������ �� ��� �������� ��, ��������� � ������
# <cspGetProductionDbName_TestDbList>.
# ����� �� ������ ���� ������� � ������ �������� �������� � ������������
# � ������������ ���������� ����� ���������� �� ( ��������, ������ �����
# ����� � ������� �������� � �.�.).
#
cspGetProductionDbName_ProdDbList = \
  ProdDb

# build var: cspGetProductionDbName_ExtraDbList
# ������������ ��, ������������� � ������ <cspGetProductionDbName_ProdDbList>
# ( ��� ������� ��� �������� ��).
# ����� �� ����������� � ������ �������� ( ����������
# <cspGetProductionDbName_ProdDbList>).
#
cspGetProductionDbName_ExtraDbList = \

