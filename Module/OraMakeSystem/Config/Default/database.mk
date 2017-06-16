# makefile: Настройки сборки
#
# Настроечные функции и константы для make, которые могут модифицироваться в
# пользовательской версии.
#
# Соглашения по именованию:
# - используемые из других скриптов имена ( функций, переменных) должны
#   начинаться с префикса "csp" ( "custom public");
# - остальные имена должны начинаться с префикса "csl" ( "custom local");
#



#
# group: Определение имени промышленной БД
#


# build var: cspGetProductionDbName_TestDbList
# Список тестовых БД для функции <getProductionDbName>.
# Имена должны указываться в нижнем регистре, при этом в том же по порядку
# слове переменной <cspGetProductionDbName_ProdDbList> должно быть указано
# имя промышленной БД для данной тестовой БД.
#
cspGetProductionDbName_TestDbList = \
  testdb testdb2 testdb3

# build var: cspGetProductionDbName_ProdDbList
# Промышленные БД для тестовых БД, указанных в списке
# <cspGetProductionDbName_TestDbList>.
# Имена БД должны быть указаны с учетом регистра символов в соответствии
# с общепринятым написанием имени конкретной БД ( например, первая буква
# имени в верхнем регистре и т.д.).
#
cspGetProductionDbName_ProdDbList = \
  ProdDb ProdDb  ProdDb2

# build var: cspGetProductionDbName_ExtraDbList
# Промышленные БД, отсутствующие в списке <cspGetProductionDbName_ProdDbList>
# ( для которых нет тестовых БД).
# Имена БД указываются с учетом регистра ( аналогично
# <cspGetProductionDbName_ProdDbList>).
#
cspGetProductionDbName_ExtraDbList = \
  ProdDb3 \
  ProdDb4

