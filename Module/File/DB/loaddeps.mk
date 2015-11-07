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

pkg_FileBase.pkb.$(lu): \
  pkg_FileBase.pks.$(lu) \
  pkg_FileOrigin.pks.$(lu) \


pkg_FileOrigin.pkb.$(lu): \
  pkg_FileOrigin.pks.$(lu) \
  pkg_File.jav.$(lu) \


pkg_FileUtility.pkb.$(lu): \
  pkg_FileUtility.pks.$(lu) \
  pkg_FileOrigin.pks.$(lu) \


pkg_File.jav.$(lu): \
  Java/Lib/NetFile.jav.$(lu) \


Java/Lib/NetFile.jav.$(lu): \
  pkg_FileBase.pks.$(lu) \
  $(addsuffix .$(lu),$(loadJavaUsedLibJar)) \


$(HTTPCLIENT_DIR)/lib/httpclient-4.3.6.jar.$(lu): \
  $(HTTPCLIENT_DIR)/lib/commons-codec-1.6.jar.$(lu) \
  $(addsuffix .ignore.$(lu),$(HTTPCLIENT_DIR)/lib/commons-logging-1.1.3.jar) \
  $(HTTPCLIENT_DIR)/lib/httpcore-4.3.3.jar.$(lu) \


$(HTTPCLIENT_DIR)/lib/fluent-hc-4.3.6.jar.$(lu): \
  $(HTTPCLIENT_DIR)/lib/commons-codec-1.6.jar.$(lu) \
  $(addsuffix .ignore.$(lu),$(HTTPCLIENT_DIR)/lib/commons-logging-1.1.3.jar) \
  $(HTTPCLIENT_DIR)/lib/httpcore-4.3.3.jar.$(lu) \
  $(HTTPCLIENT_DIR)/lib/httpclient-4.3.6.jar.$(lu) \


