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

pkg_AccessOperator.pkb.$(lu): \
  pkg_AccessOperator.pks.$(lu) \
	pkg_Operator.pks.$(lu)


pkg_Operator.pkb.$(lu): \
  pkg_Operator.pks.$(lu) \
  Install/Schema/Last/v_op_operator_role.vw.$(lu)


Install/Schema/Last/op_group_bi_define.trg.$(lu): \
  pkg_Operator.pks.$(lu)


Install/Schema/Last/op_group_role_bi_define.trg.$(lu): \
  pkg_Operator.pks.$(lu)


Install/Schema/Last/op_operator_bi_define.trg.$(lu): \
  pkg_Operator.pks.$(lu)


Install/Schema/Last/op_operator_group_bi_define.trg.$(lu): \
  pkg_Operator.pks.$(lu)


Install/Schema/Last/op_operator_role_bi_define.trg.$(lu): \
  pkg_Operator.pks.$(lu)


Install/Schema/Last/op_role_bi_define.trg.$(lu): \
  pkg_Operator.pks.$(lu)


Install/Data/1.0.0/op_group.sql.$(lu): \
  Install/Data/1.0.0/op_operator.sql.$(lu)


