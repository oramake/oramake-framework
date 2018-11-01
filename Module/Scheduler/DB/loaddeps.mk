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


sch_log_table_t.typ.$(lu): \
  sch_log_t.typ.$(lu) \


sch_batch_log_info_t.tyb.$(lu): \
  sch_batch_log_info_t.typ.$(lu) \


pkg_Scheduler.pks.$(lu): \
  sch_log_table_t.typ.$(lu) \


pkg_Scheduler.pkb.$(lu): \
  pkg_Scheduler.pks.$(lu) \
  pkg_SchedulerMain.pks.$(lu) \
  Install/Schema/Last/v_sch_role_privilege.vw.$(lu) \


pkg_SchedulerMain.pks.$(lu): \
  sch_batch_log_info_t.typ.$(lu) \


pkg_SchedulerMain.pkb.$(lu): \
  pkg_SchedulerMain.pks.$(lu) \


pkg_SchedulerLoad.pkb.$(lu): \
  pkg_SchedulerLoad.pks.$(lu) \
  pkg_Scheduler.pks.$(lu) \
  sch_batch_option_t.typ.$(lu) \


sch_batch_option_t.tyb.$(lu): \
  sch_batch_option_t.typ.$(lu) \
  pkg_SchedulerMain.pks.$(lu) \


Install/Schema/Last/v_sch_batch_result.vw.$(lu): \
  Install/Schema/Last/v_sch_batch_root_log_old.vw.$(lu) \


Install/Schema/Last/v_sch_batch_root_log.vw.$(lu): \
  Install/Schema/Last/v_sch_batch_root_log_old.vw.$(lu) \


Install/Schema/Last/v_sch_batch.vw.$(lu): \
  Install/Schema/Last/v_sch_batch_root_log.vw.$(lu) \
  pkg_SchedulerMain.pks.$(lu) \


Install/Schema/Last/v_sch_operator_batch.vw.$(lu): \
  Install/Schema/Last/v_sch_batch.vw.$(lu) \
  Install/Schema/Last/v_sch_role_privilege.vw.$(lu) \


