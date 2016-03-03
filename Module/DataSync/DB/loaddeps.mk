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

pkg_DataSync.pkb.$(lu): \
  pkg_DataSync.pks.$(lu) \


dsn_data_sync_t.tyb.$(lu): \
  dsn_data_sync_t.typ.$(lu) \
  pkg_DataSync.pks.$(lu) \


dsn_data_sync_source_t.tyb.$(lu): \
  dsn_data_sync_source_t.typ.$(lu) \
  pkg_DataSync.pks.$(lu) \


Test/dsn_test_t.tyb.$(lu): \
  Test/dsn_test_t.typ.$(lu) \


Test/dsn_test_source_t.tyb.$(lu): \
  Test/dsn_test_source_t.typ.$(lu) \


Test/dsn_test_t_refresh.prc.$(lu): \
  Test/dsn_test_t.typ.$(lu) \


Test/pkg_DataSyncTest.pkb.$(lu): \
  Test/pkg_DataSyncTest.pks.$(lu) \
  Test/dsn_test_t.typ.$(lu) \
  Test/dsn_test_source_t.typ.$(lu) \
  Test/dsn_test_t_refresh.prc.$(lu) \


