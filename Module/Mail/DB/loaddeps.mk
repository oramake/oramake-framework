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
  $(JAVAMAIL_LIB).$(lu)

Data/ml_message_state.sql.$(lu):          \
  pkg_Mail.pks.$(lu)



ifeq ($(INSTALL_VERSION),2.7.0)

# ������� ������ ������ ���������� ����� ������� �������� JAVA RESOURCE
Java/UsedLib/JavaMail/jakarta.mail-1.6.4/jakarta.mail-1.6.4.jar.$(lu): \
  Install/Schema/2.7.0/Revert/mail.jar.revert.$(ru)

Install/Schema/2.7.0/Revert/mail.jar.$(ru): \
  Java/UsedLib/JavaMail/jakarta.mail-1.6.4/jakarta.mail-1.6.4.jar.revert.$(ru)

endif

