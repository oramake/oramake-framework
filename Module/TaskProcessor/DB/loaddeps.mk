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

pkg_TaskProcessor.pks.$(lu): \
  pkg_TaskProcessorBase.pks.$(lu) \


pkg_TaskProcessor.pkb.$(lu): \
  pkg_TaskProcessor.pks.$(lu) \
  pkg_TaskProcessorBase.pks.$(lu) \
  pkg_TaskProcessorHandler.pks.$(lu) \


pkg_TaskProcessorBase.pkb.$(lu): \
  pkg_TaskProcessorBase.pks.$(lu) \


pkg_TaskProcessorHandler.pkb.$(lu): \
  pkg_TaskProcessorHandler.pks.$(lu) \
  pkg_TaskProcessorBase.pks.$(lu) \
  Install/Schema/Last/v_tp_active_task.vw.$(lu) \


pkg_TaskProcessorUtility.pkb.$(lu): \
  pkg_TaskProcessorUtility.pks.$(lu) \
  pkg_TaskProcessorBase.pks.$(lu) \


