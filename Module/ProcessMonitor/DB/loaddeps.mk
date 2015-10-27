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

pkg_ProcessMonitor.pkb.$(lu): \
  pkg_ProcessMonitorBase.pks.$(lu) \
  pkg_ProcessMonitor.pks.$(lu) \
  pkg_ProcessMonitorUtility.pks.$(lu) \
  Install/Schema/Last/v_prm_execution_action.vw.$(lu) \
  Install/Schema/Last/v_prm_session_memory.vw.$(lu)


Install/Schema/Last/v_prm_session_existence.vw.$(lu):\
  Install/Schema/Last/v_prm_registered_session.vw.$(lu)


Install/Schema/Last/v_prm_session_action.vw.$(lu):\
  Install/Schema/Last/v_prm_session_existence.vw.$(lu)


Install/Schema/Last/v_prm_execution_action.vw.$(lu):\
  Install/Schema/Last/v_prm_session_action.vw.$(lu)
