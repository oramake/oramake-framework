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

Common/pkg_Calendar.pkb.$(lu): \
  Common/pkg_Calendar.pks.$(lu) \
  Install/Schema/Last/v_cdr_day.vw.$(lu) \
  Install/Schema/Last/v_cdr_day_type.vw.$(lu) \


pkg_CalendarEdit.pkb.$(lu): \
  pkg_CalendarEdit.pks.$(lu) \


# ����������� �� ����������� �������
Install/Schema/Last/v_cdr_day.vw.$(lu): \
  Install/Schema/Last/Common/v_cdr_day.sql \


# ����������� �� ����������� �������
Install/Schema/Last/v_cdr_day_type.vw.$(lu): \
  Install/Schema/Last/Common/v_cdr_day_type.sql \



#
# ����������� ��� UserDb
#

Common/pkg_Calendar.pkb.$(lu3): \
  Common/pkg_Calendar.pks.$(lu3) \
  Install/Schema/Last/UserDb/v_cdr_day.vw.$(lu3) \
  Install/Schema/Last/UserDb/v_cdr_day_type.vw.$(lu3) \


# ����������� �� ����������� �������
Install/Schema/Last/UserDb/v_cdr_day.vw.$(lu3): \
  Install/Schema/Last/Common/v_cdr_day.sql \


# ����������� �� ����������� �������
Install/Schema/Last/UserDb/v_cdr_day_type.vw.$(lu3): \
  Install/Schema/Last/Common/v_cdr_day_type.sql \


