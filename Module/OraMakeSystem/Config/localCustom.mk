# makefile: ��������� OMS



#
# group: ������ ������ �����������
#


# build var: getProductionDbName_TestDbList
# ������ �������� �� ��� ������� <getProductionDbName>.
# ����� ������ ����������� � ������ ��������, ��� ���� � ��� �� �� �������
# ����� ���������� <getProductionDbName_ProdDbList> ������ ���� �������
# ��� ������������ �� ��� ������ �������� ��.
#
getProductionDbName_TestDbList = \
  TestDb

# build var: getProductionDbName_ProdDbList
# ������������ �� ��� �������� ��, ��������� � ������
# <getProductionDbName_TestDbList>.
# ����� �� ������ ���� ������� � ������ �������� �������� � ������������
# � ������������ ���������� ����� ���������� �� ( ��������, ������ �����
# ����� � ������� �������� � �.�.).
#
getProductionDbName_ProdDbList = \
  ProdDb

# build var: getProductionDbName_ExtraDbList
# ������������ ��, ������������� � ������ <getProductionDbName_ProdDbList>
# ( ��� ������� ��� �������� ��).
# ����� �� ����������� � ������ �������� ( ����������
# <getProductionDbName_ProdDbList>).
#
getProductionDbName_ExtraDbList = \

