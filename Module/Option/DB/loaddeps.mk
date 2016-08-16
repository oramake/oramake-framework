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


pkg_Option.pks.$(lu): \
  pkg_OptionMain.pks.$(lu) \


pkg_Option.pkb.$(lu): \
  pkg_Option.pks.$(lu) \
  pkg_OptionMain.pks.$(lu) \
  Install/Schema/Last/v_opt_object_type.vw.$(lu) \
  Install/Schema/Last/v_opt_option_value.vw.$(lu) \
  Install/Schema/Last/v_opt_value.vw.$(lu) \


pkg_OptionCrypto.pkb.$(lu): \
  pkg_OptionCrypto.pks.$(lu) \


pkg_OptionMain.pkb.$(lu): \
  pkg_OptionMain.pks.$(lu) \
  pkg_OptionCrypto.pks.$(lu) \
  Install/Schema/Last/v_opt_option_value.vw.$(lu) \


pkg_OptionTest.pkb.$(lu): \
  pkg_OptionTest.pks.$(lu) \


opt_option_list_t.tyb.$(lu): \
  opt_option_list_t.typ.$(lu) \
  pkg_OptionMain.pks.$(lu) \
  Install/Schema/Last/v_opt_option.vw.$(lu) \
  Install/Schema/Last/v_opt_value.vw.$(lu) \


opt_plsql_object_option_t.typ.$(lu): \
  opt_option_list_t.typ.$(lu) \


opt_plsql_object_option_t.tyb.$(lu): \
  opt_plsql_object_option_t.typ.$(lu) \
  pkg_OptionMain.pks.$(lu) \


Install/Schema/Last/v_opt_option_value.vw.$(lu): \
  Install/Schema/Last/v_opt_option.vw.$(lu) \
  Install/Schema/Last/v_opt_value.vw.$(lu) \
  Install/Schema/Last/v_opt_object_type.vw.$(lu) \
  pkg_OptionMain.pks.$(lu) \


Install/Data/Last/opt_option.sql.$(lu): \
  Install/Data/Last/opt_access_level.sql.$(lu) \
  Install/Data/Last/opt_value_type.sql.$(lu) \


