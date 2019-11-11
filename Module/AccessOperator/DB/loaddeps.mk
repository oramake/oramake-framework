#
# ����������� ��� �������� ������ � ��.
#
# ����� � ������������ ������ ����������� � �������������� ���������:
# .$(lu)      - �������� ��� ������ �������������
# .$(lu2)     - �������� ��� ������ �������������
# .$(lu3)     - �������� ��� ������� �������������
# ...         - ...
#
# ������ ( ����������� ���� ������ pkg_TestModule �� ����������� ������������
# � ������������ ������ pkg_TestModule2 ��� �������� ��� ������ �������������):
#
# pkg_TestModule.pkb.$(lu): \
#   pkg_TestModule.pks.$(lu) \
#   pkg_TestModule2.pks.$(lu)
#
#
# ���������:
# - � ������ ����� �� ������ �������������� ������ ��������� ( ������ ���� ���
#   �������������� ����� ������������ �������), �.�. ������ ��������� �����
#   ����������� �������� ��� make � ��� ��������� ��������� ����� �������� �
#   �������������������� �������;
# - � ������, ���� ��������� ������ ����������� ����� ����������� ��������
#   ������������� ( �������� ����� ������), �� ����� �����������
#   ������ ���� ��� ������� ���� ������ ������, ����� ��� �������� �����
#   ��������� ������ "*** No rule to make target ` ', needed by ...";
# - ����� � ����������� ������ ����������� � ����� ������������ �������� DB
#   � ������ ��������, �������� "Install/Schema/Last/test_view.vw.$(lu): ...";
#

pkg_Operator.pkb.$(lu):                 \
  pkg_Operator.pks.$(lu)


pkg_OperatorInternal.pkb.$(lu):         \
  pkg_OperatorInternal.pks.$(lu)


pkg_Operator.pkb.$(lu4):                 \
  pkg_Operator.pks.$(lu4)


pkg_OperatorInternal.pkb.$(lu4):         \
  pkg_OperatorInternal.pks.$(lu4)


Install/Data/1.0.0/op_group.sql.$(lu):         \
  Install/Data/1.0.0/op_operator.sql.$(lu)


Install/Data/1.0.0/op_role.sql.$(lu):         \
  Install/Data/1.0.0/op_operator.sql.$(lu)


Install/Data/1.0.0/Local/Private/op_group_role.sql.$(lu2):     \
  Install/Data/1.0.0/Local/Private/op_role.sql.$(lu2)


Local/Private/Main/pkg_AccessOperator.pkb.$(lu4):     \
  Local/Private/Main/pkg_AccessOperator.pks.$(lu4)


