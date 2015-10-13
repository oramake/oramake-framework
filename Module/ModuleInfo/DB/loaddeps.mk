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

pkg_ModuleInfo.pkb.$(lu): \
  pkg_ModuleInfo.pks.$(lu) \
  pkg_ModuleInfoInternal.pks.$(lu) \
  Install/Schema/Last/v_mod_app_install_version.vw.$(lu) \
  Install/Schema/Last/v_mod_install_module.vw.$(lu) \


pkg_ModuleInfoInternal.pkb.$(lu): \
  pkg_ModuleInfoInternal.pks.$(lu) \


pkg_ModuleInstall.pkb.$(lu): \
  pkg_ModuleInstall.pks.$(lu) \
  pkg_ModuleInfoInternal.pks.$(lu) \


Install/Schema/Last/v_mod_app_install_version.vw.$(lu): \
  Install/Schema/Last/v_mod_app_install_result.vw.$(lu) \


Install/Schema/Last/v_mod_app_install_result.vw.$(lu): \
  Install/Schema/Last/v_mod_module.vw.$(lu) \


Install/Schema/Last/v_mod_install_action.vw.$(lu): \
  Install/Schema/Last/v_mod_module.vw.$(lu) \


Install/Schema/Last/v_mod_install_file.vw.$(lu): \
  Install/Schema/Last/v_mod_source_file.vw.$(lu) \


Install/Schema/Last/v_mod_install_module.vw.$(lu): \
  Install/Schema/Last/v_mod_install_version.vw.$(lu) \


Install/Schema/Last/v_mod_install_object.vw.$(lu): \
  Install/Schema/Last/v_mod_module.vw.$(lu) \


Install/Schema/Last/v_mod_install_result.vw.$(lu): \
  Install/Schema/Last/v_mod_module.vw.$(lu) \


Install/Schema/Last/v_mod_install_version.vw.$(lu): \
  Install/Schema/Last/v_mod_install_result.vw.$(lu)


Install/Schema/Last/v_mod_source_file.vw.$(lu): \
  Install/Schema/Last/v_mod_module.vw.$(lu) \


$(addsuffix .$(lu),$(wildcard Install/Schema/Last/*.trg)): \
  pkg_ModuleInfoInternal.pks.$(lu) \


