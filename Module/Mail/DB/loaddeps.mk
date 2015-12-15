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

pkg_Mail.pkb.$(lu):                 \
  pkg_Mail.pks.$(lu)                \
  pkg_MailUtility.pks.$(lu) \
  pkg_MailInternal.pks.$(lu)

pkg_MailHandler.pkb.$(lu):           \
  pkg_MailHandler.pks.$(lu)          \
  pkg_Mail.pks.$(lu)	\
  pkg_MailInternal.pks.$(lu) \
  Install/Schema/Last/v_ml_fetch_request_wait.vw.$(lu)

pkg_MailUtility.pkb.$(lu):           \
  pkg_MailUtility.pks.$(lu)

pkg_MailInternal.pkb.$(lu):           \
  pkg_MailInternal.pks.$(lu)

Mail.jav.$(lu):                     \
  OraUtil.jav.$(lu)                  \
  $(JAVAMAIL_DIR)/mail.jar.$(lu)

$(JAVAMAIL_DIR)/mail.jar.$(lu):      \
  $(JAF_DIR)/activation.jar.$(lu)

Data/ml_message_state.sql.$(lu):          \
  pkg_Mail.pks.$(lu)

