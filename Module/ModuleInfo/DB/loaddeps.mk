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

pkg_ModuleInfo.pkb.$(lu): \
  pkg_ModuleInfo.pks.$(lu) \
  pkg_ModuleInfoInternal.pks.$(lu) \
  Install/Schema/Last/v_mod_app_install_version.vw.$(lu) \
  Install/Schema/Last/v_mod_install_module.vw.$(lu) \


pkg_ModuleInfoInternal.pkb.$(lu): \
  pkg_ModuleInfoInternal.pks.$(lu) \


pkg_ModuleInstall.pkb.$(lu): \
  pkg_ModuleInstall.pks.$(lu) \
  pkg_ModuleInfoInternal.pks.$(lu) \


Install/Schema/Last/v_mod_app_install_version.vw.$(lu): \
  Install/Schema/Last/v_mod_app_install_result.vw.$(lu) \


Install/Schema/Last/v_mod_app_install_result.vw.$(lu): \
  Install/Schema/Last/v_mod_module.vw.$(lu) \


Install/Schema/Last/v_mod_install_action.vw.$(lu): \
  Install/Schema/Last/v_mod_module.vw.$(lu) \


Install/Schema/Last/v_mod_install_file.vw.$(lu): \
  Install/Schema/Last/v_mod_source_file.vw.$(lu) \


Install/Schema/Last/v_mod_install_module.vw.$(lu): \
  Install/Schema/Last/v_mod_install_version.vw.$(lu) \


Install/Schema/Last/v_mod_install_object.vw.$(lu): \
  Install/Schema/Last/v_mod_module.vw.$(lu) \


Install/Schema/Last/v_mod_install_result.vw.$(lu): \
  Install/Schema/Last/v_mod_module.vw.$(lu) \


Install/Schema/Last/v_mod_install_version.vw.$(lu): \
  Install/Schema/Last/v_mod_install_result.vw.$(lu)


Install/Schema/Last/v_mod_source_file.vw.$(lu): \
  Install/Schema/Last/v_mod_module.vw.$(lu) \


$(addsuffix .$(lu),$(wildcard Install/Schema/Last/*.trg)): \
  pkg_ModuleInfoInternal.pks.$(lu) \


