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

pkg_AccessOperator.pkb.$(lu): \
  pkg_AccessOperator.pks.$(lu) \
	pkg_Operator.pks.$(lu)


pkg_Operator.pkb.$(lu): \
  pkg_Operator.pks.$(lu) \
  Install/Schema/Last/v_op_operator_role.vw.$(lu)


Install/Schema/Last/op_group_bi_define.trg.$(lu): \
  pkg_Operator.pks.$(lu)


Install/Schema/Last/op_group_role_bi_define.trg.$(lu): \
  pkg_Operator.pks.$(lu)


Install/Schema/Last/op_operator_bi_define.trg.$(lu): \
  pkg_Operator.pks.$(lu)


Install/Schema/Last/op_operator_group_bi_define.trg.$(lu): \
  pkg_Operator.pks.$(lu)


Install/Schema/Last/op_operator_role_bi_define.trg.$(lu): \
  pkg_Operator.pks.$(lu)


Install/Schema/Last/op_role_bi_define.trg.$(lu): \
  pkg_Operator.pks.$(lu)


Install/Data/1.0.0/op_group.sql.$(lu): \
  Install/Data/1.0.0/op_operator.sql.$(lu)


