# makefile: Настройки OMS



#
# group: Разбор строки подключения
#


# build var: getProductionDbName_TestDbList
# Список тестовых БД для функции <getProductionDbName>.
# Имена должны указываться в нижнем регистре, при этом в том же по порядку
# слове переменной <getProductionDbName_ProdDbList> должно быть указано
# имя промышленной БД для данной тестовой БД.
#
getProductionDbName_TestDbList = \
  TestDb

# build var: getProductionDbName_ProdDbList
# Промышленные БД для тестовых БД, указанных в списке
# <getProductionDbName_TestDbList>.
# Имена БД должны быть указаны с учетом регистра символов в соответствии
# с общепринятым написанием имени конкретной БД ( например, первая буква
# имени в верхнем регистре и т.д.).
#
getProductionDbName_ProdDbList = \
  ProdDb

# build var: getProductionDbName_ExtraDbList
# Промышленные БД, отсутствующие в списке <getProductionDbName_ProdDbList>
# ( для которых нет тестовых БД).
# Имена БД указываются с учетом регистра ( аналогично
# <getProductionDbName_ProdDbList>).
#
getProductionDbName_ExtraDbList = \

