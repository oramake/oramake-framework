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


