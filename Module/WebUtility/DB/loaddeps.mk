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

wbu_header_list_t.typ.$(lu): \
  wbu_header_t.typ.$(lu) \


wbu_parameter_list_t.typ.$(lu): \
  wbu_parameter_t.typ.$(lu) \


wbu_part_list_t.typ.$(lu): \
  wbu_part_t.typ.$(lu) \


pkg_WebUtility.pkb.$(lu): \
  pkg_WebUtility.pks.$(lu) \
  pkg_WebUtilityBase.pks.$(lu) \
  pkg_WebUtilityNtlm.pks.$(lu) \
  wbu_header_list_t.typ.$(lu) \
  wbu_parameter_list_t.typ.$(lu) \
  wbu_part_t.typ.$(lu) \


pkg_WebUtilityBase.pkb.$(lu): \
  pkg_WebUtilityBase.pks.$(lu) \
  pkg_WebUtility.pks.$(lu) \


pkg_WebUtilityNtlm.pkb.$(lu): \
  pkg_WebUtilityNtlm.pks.$(lu) \


