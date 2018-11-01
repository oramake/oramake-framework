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


sch_log_table_t.typ.$(lu): \
  sch_log_t.typ.$(lu) \


sch_batch_log_info_t.tyb.$(lu): \
  sch_batch_log_info_t.typ.$(lu) \


pkg_Scheduler.pks.$(lu): \
  sch_log_table_t.typ.$(lu) \


pkg_Scheduler.pkb.$(lu): \
  pkg_Scheduler.pks.$(lu) \
  pkg_SchedulerMain.pks.$(lu) \
  Install/Schema/Last/v_sch_role_privilege.vw.$(lu) \


pkg_SchedulerMain.pks.$(lu): \
  sch_batch_log_info_t.typ.$(lu) \


pkg_SchedulerMain.pkb.$(lu): \
  pkg_SchedulerMain.pks.$(lu) \


pkg_SchedulerLoad.pkb.$(lu): \
  pkg_SchedulerLoad.pks.$(lu) \
  pkg_Scheduler.pks.$(lu) \
  sch_batch_option_t.typ.$(lu) \


sch_batch_option_t.tyb.$(lu): \
  sch_batch_option_t.typ.$(lu) \
  pkg_SchedulerMain.pks.$(lu) \


Install/Schema/Last/v_sch_batch_result.vw.$(lu): \
  Install/Schema/Last/v_sch_batch_root_log_old.vw.$(lu) \


Install/Schema/Last/v_sch_batch_root_log.vw.$(lu): \
  Install/Schema/Last/v_sch_batch_root_log_old.vw.$(lu) \


Install/Schema/Last/v_sch_batch.vw.$(lu): \
  Install/Schema/Last/v_sch_batch_root_log.vw.$(lu) \
  pkg_SchedulerMain.pks.$(lu) \


Install/Schema/Last/v_sch_operator_batch.vw.$(lu): \
  Install/Schema/Last/v_sch_batch.vw.$(lu) \
  Install/Schema/Last/v_sch_role_privilege.vw.$(lu) \


