#
# Зависимости при загрузке файлов в БД.
#
# Файлы в зависимостях должны указываться с дополнительным суффиксом:
# .$(lu)      - загрузка под первым пользователем
# .$(lu2)     - загрузка под вторым пользователем
# .$(lu3)     - загрузка под третьим пользователем
# ...         - ...
#
# Пример ( зависимость тела пакета pkg_TestModule от собственной спецификации
# и спецификации пакета pkg_TestModule2 при загрузке под первым пользователем):
#
# pkg_TestModule.pkb.$(lu): \
#   pkg_TestModule.pks.$(lu) \
#   pkg_TestModule2.pks.$(lu)
#
#
# Замечания:
# - в данном файле не должен использоваться символ табуляции ( вместо него для
#   форматирования нужно использовать пробелы), т.к. символ табуляции имеет
#   специальное значение для make и его случайное появление может привести к
#   труднообнаруживаемым ошибкам;
# - в случае, если последняя строка зависимости также завершается символом
#   экранирования ( обратной косой чертой), то после зависимости
#   должна идти как минимум одна пустая строка, иначе при загрузке будет
#   возникать ошибка "*** No rule to make target ` ', needed by ...";
# - файлы в зависимости должны указываться с путем относительно каталога DB
#   с учетом регистра, например "Install/Schema/Last/test_view.vw.$(lu): ...";
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

# удаляем старую версию библиотеки чтобы удалить ненужные JAVA RESOURCE
Java/UsedLib/JavaMail/jakarta.mail-1.6.4/jakarta.mail-1.6.4.jar.$(lu): \
  Install/Schema/2.7.0/Revert/mail.jar.revert.$(ru)

Install/Schema/2.7.0/Revert/mail.jar.$(ru): \
  Java/UsedLib/JavaMail/jakarta.mail-1.6.4/jakarta.mail-1.6.4.jar.revert.$(ru)

endif

