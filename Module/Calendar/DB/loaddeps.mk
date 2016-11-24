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

Common/pkg_Calendar.pkb.$(lu): \
  Common/pkg_Calendar.pks.$(lu) \
  Install/Schema/Last/v_cdr_day.vw.$(lu) \
  Install/Schema/Last/v_cdr_day_type.vw.$(lu) \


pkg_CalendarEdit.pkb.$(lu): \
  pkg_CalendarEdit.pks.$(lu) \


# зависимость от вызываемого скрипта
Install/Schema/Last/v_cdr_day.vw.$(lu): \
  Install/Schema/Last/Common/v_cdr_day.sql \


# зависимость от вызываемого скрипта
Install/Schema/Last/v_cdr_day_type.vw.$(lu): \
  Install/Schema/Last/Common/v_cdr_day_type.sql \



#
# Зависимости для UserDb
#

Common/pkg_Calendar.pkb.$(lu3): \
  Common/pkg_Calendar.pks.$(lu3) \
  Install/Schema/Last/UserDb/v_cdr_day.vw.$(lu3) \
  Install/Schema/Last/UserDb/v_cdr_day_type.vw.$(lu3) \


# зависимость от вызываемого скрипта
Install/Schema/Last/UserDb/v_cdr_day.vw.$(lu3): \
  Install/Schema/Last/Common/v_cdr_day.sql \


# зависимость от вызываемого скрипта
Install/Schema/Last/UserDb/v_cdr_day_type.vw.$(lu3): \
  Install/Schema/Last/Common/v_cdr_day_type.sql \


