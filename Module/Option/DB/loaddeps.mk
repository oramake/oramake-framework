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


pkg_Option.pks.$(lu): \
  pkg_OptionMain.pks.$(lu) \


pkg_Option.pkb.$(lu): \
  pkg_Option.pks.$(lu) \
  pkg_OptionMain.pks.$(lu) \
  Install/Schema/Last/v_opt_object_type.vw.$(lu) \
  Install/Schema/Last/v_opt_option_value.vw.$(lu) \
  Install/Schema/Last/v_opt_value.vw.$(lu) \


pkg_OptionCrypto.pkb.$(lu): \
  pkg_OptionCrypto.pks.$(lu) \


pkg_OptionMain.pkb.$(lu): \
  pkg_OptionMain.pks.$(lu) \
  pkg_OptionCrypto.pks.$(lu) \
  Install/Schema/Last/v_opt_option_value.vw.$(lu) \


pkg_OptionTest.pkb.$(lu): \
  pkg_OptionTest.pks.$(lu) \


opt_option_list_t.tyb.$(lu): \
  opt_option_list_t.typ.$(lu) \
  pkg_OptionMain.pks.$(lu) \
  Install/Schema/Last/v_opt_option.vw.$(lu) \
  Install/Schema/Last/v_opt_value.vw.$(lu) \


opt_plsql_object_option_t.typ.$(lu): \
  opt_option_list_t.typ.$(lu) \


opt_plsql_object_option_t.tyb.$(lu): \
  opt_plsql_object_option_t.typ.$(lu) \
  pkg_OptionMain.pks.$(lu) \


Install/Schema/Last/v_opt_option_value.vw.$(lu): \
  Install/Schema/Last/v_opt_option.vw.$(lu) \
  Install/Schema/Last/v_opt_value.vw.$(lu) \
  Install/Schema/Last/v_opt_object_type.vw.$(lu) \
  pkg_OptionMain.pks.$(lu) \


Install/Data/Last/opt_option.sql.$(lu): \
  Install/Data/Last/opt_access_level.sql.$(lu) \
  Install/Data/Last/opt_value_type.sql.$(lu) \


