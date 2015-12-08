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

pkg_Logging.pkb.$(lu): \
  pkg_Logging.pks.$(lu) \
  pkg_LoggingInternal.pks.$(lu) \
  pkg_LoggingErrorStack.pks.$(lu)

pkg_LoggingInternal.pkb.$(lu): \
  pkg_LoggingInternal.pks.$(lu) \
  lg_logger_t.typ.$(lu)

pkg_LoggingErrorStack.pkb.$(lu): \
  pkg_LoggingErrorStack.pks.$(lu) \
  lg_logger_t.typ.$(lu)

lg_logger_t.tyb.$(lu): \
  lg_logger_t.typ.$(lu) \
  pkg_Logging.pks.$(lu) \
  pkg_LoggingInternal.pks.$(lu) \
  pkg_LoggingErrorStack.pks.$(lu)

lg_after_server_error.trg.$(lu):\
  pkg_Logging.pks.$(lu)

Install/Schema/Last/run.sql.$(lu):\
  lg_logger_t.typ.$(lu) \
  pkg_Logging.pks.$(lu) \
  pkg_LoggingErrorStack.pks.$(lu)
