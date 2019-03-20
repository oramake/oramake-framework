# makefile: Инициализация OMS



#
# group: Константы
#

# build var: OMS_VERSION
# Версия OMS-файлов, входящих в состав модуля.
OMS_VERSION=2.2.0



#
# group: Спецсимволы
#

# build var: empty
# Пустое значение.
empty :=

# build var: comma
# Запятая.
comma := ,

# build var: space
# Пробел.
space := $(empty) $(empty)

# build var: rrb
# Правая круглая скобка.
rrb   := )

# build var: tab
# Табуляция.
tab := $(empty)	$(empty)



#
# group: Общие параметры
#

# build var: OMS_INSTALL_SHARE_DIR
# Путь к каталогу с установленными файлами OMS.
export OMS_INSTALL_SHARE_DIR = /usr/local/share/oms

# build var: OMS_INSTALL_CONFIG_DIR
# Путь к каталогу с настройками OMS.
export OMS_INSTALL_CONFIG_DIR = /usr/local/etc/oms




# Выделяет из номер ревизии из ключевой строки.
#
# Параметры:
# (1)     - строка с номером ревизии вида "$Revision:: N $", где N номер
#           ревизии
#
# Возврат:
# строка с номером ревизии.
#
getRevisionFromKeyword = $(strip $(shell \
    keyString='$(1)'; \
    echo "$${keyString:12:$${\#keyString}-13}" \
  ))



# Выделяет дату из ключевой строки.
#
# Параметры:
# (1)     - строка с датой вида
#           "$Date:: yyyy-mm-dd hh24:mi:ss tzhtzm $"
#
# Возврат:
# строка с датой вида "yyyy-mm-dd hh24:mi:ss tzhtzm"
#
getDateFromKeyword = $(strip $(shell \
    keyString='$(1)'; \
    echo "$${keyString:9:25}" \
  ))


# Включаем пользовательские настройки БД
include $(OMS_INSTALL_CONFIG_DIR)/database.mk



#
# group: Функции
#

#
# group: Общие
#



# build func: getXmlElementValue
# Возвращает значение указанного XML-элемента.
#
# Параметры:
# (1)     - имя элемента
# (2)     - текст XML, из которого выделяется значение элемента
#
# Замечания:
# - при наличии в тексте XML нескольких элементов с указанным именем,
#   возвращается значение первого элемента;
# - в возвращаемом значении символ табуляции заменяется на пробел, после чего
#   удаляются начальные и конечные пробелы;
#
getXmlElementValue = $(strip \
  $(subst <$(1)>,,$(subst </$(1)>,,$(subst &\#20;,$(space), \
    $(firstword $(filter <$(1)>%</$(1)>, \
      $(subst <$(1)>,$(space)<$(1)>,$(subst </$(1)>,</$(1)>$(space), \
        $(subst $(space),&\#20;,$(subst $(tab),$(space),$(2))) \
      )) \
    )) \
  ))))



# build func: getMakeFlagList
# Возвращает опции запуска make.
#
# Возврат:
# слово, состоящее из однобуквенных имен использовавшихся опций.
#
# Пример:
# в случае указания при запуске make опций "--ignore-errors -B" функция
# вернет "iB".
#
getMakeFlagList = $(if $(filter --,$(MAKEFLAGS)),$(filter-out --%, \
    $(call wordListTo,--,$(MAKEFLAGS)) \
  ))



# build func: isMakeFlag
# Проверят использование опции в вызове make.
#
# Параметры:
# (1)     - сокращенное ( однобуквенное) имя опции
#
# Возврат:
# однобуквенное имя опции при ее использовании или пустая строка если опция
# не использовалась.
#
isMakeFlag = $(findstring $(strip $(1)),$(call getMakeFlagList))



# build func: nullif
# Возвращает пустую строку, если первый аргумент равен второму, иначе
# возвращает первый аргумент.
#
# (1)     - основная строка
# (2)     - строка для сравнения
#
nullif = $(if $(subst $(1),,$(2))$(subst $(2),,$(1)),$(1),)



# build func: ltrim
# Удаляет начальные символы слова, соответствующие указанному.
#
# Параметры:
# $(1)    - исходное слово
# $(2)    - удаляемый символ ( последовательность символов)
#
# Замечания:
# - также для исходного слова удаляются начальные и конечные пробелы, а также
#   нормализуются пробелы в середине слова ( стандартная функция strip);
#
ltrim = \
  $(strip $(if $(1),$(if $(2),$(if $(patsubst $(2)%,,$(1)),$(1),$(call ltrim,$(patsubst $(2)%,%,$(1)),$(2))),$(1)),))



# build func: compareNumber
# Сравнивает целые неотрицательные числа.
#
# Параметры:
# $(1)    - первое число
# $(2)    - второе число
#
# Возврат:
# 1       - первый число больше второго
# 0       - первый число равен второму
# -1      - первый число меньше второго
#
compareNumber = \
  $(strip \
    $(call compareNumber_Internal, \
      $(call compareNumber_DigitList,$(call ltrim,$(1),0)), \
      $(call compareNumber_DigitList,$(call ltrim,$(2),0))))

# Возвращает список цифр числа $(1).
#
compareNumber_DigitList = \
  $(strip $(call compareNumber_SepDigit,$(1),0 1 2 3 4 5 6 7 8 9))

# Добавляет в строку $(1) пробелы перед цифрами из списка $(2).
compareNumber_SepDigit = \
  $(if $(firstword $(2)), \
    $(call compareNumber_SepDigit, \
      $(subst $(firstword $(2)), $(firstword $(2)),$(1)), \
      $(wordlist 2,10,$(2))), \
    $(1))

# Сравнивает целые неотрицательные числа, переданные в виде списка цифр без
# начальных незначащих нулей.
#
compareNumber_Internal = \
  $(if $(firstword $(1) $(2)), \
    $(if $(firstword $(1)), \
      $(if $(firstword $(2)), \
        $(if $(word $(words $(1)),$(2)), \
          $(if $(word $(words $(2)),$(1)), \
            $(foreach cmp, \
              $(call compareNumber_CompareDigit \
                ,$(firstword $(1)),$(firstword $(2))), \
              $(if $(call nullif,$(strip $(cmp)),0), \
                $(cmp), \
                $(call compareNumber_Internal, \
                  $(wordlist 2,$(words $(1)),$(1)), \
                  $(wordlist 2,$(words $(2)),$(2))))), \
            -1), \
          1), \
        1), \
      -1), \
    0)

# Сравнивает две цифры ( должны быть обязательно указаны).
#
compareNumber_CompareDigit = \
  $(if $(call nullif,$(1),$(2)), \
    $(if $(call nullif,$(1),$(firstword $(sort $(1) $(2)))),1,-1), \
    0)



# build func: translate
# Выполняет трансляцию символов исходной строки.
#
# Параметры:
# (1)     - исходная строка
# (2)     - список исходных слов для трансляции
# (3)     - список результирующих слов для трансляции
#
translate  = \
  $(if $(firstword $(2)),$(call \
    translate,$(subst $(firstword $(2)),$(firstword $(3)),$(1)),$(wordlist \
      2,$(words $(2)),$(2)),$(wordlist \
      2,$(words $(3)),$(3))),$(1))



# build func: translateWord
# Выполняет трансляцию слов исходной строки.
#
# Параметры:
# (1)     - исходная строка
# (2)     - список исходных слов для трансляции
# (3)     - список результирующих слов для трансляции
#
translateWord  = \
  $(if $(firstword $(2)),$(call \
    translateWord,$(patsubst $(firstword $(2)),$(firstword $(3)),$(1)), \
      $(wordlist 2,$(words $(2)),$(2)), \
      $(wordlist 2,$(words $(3)),$(3))),$(1))



# build func: wordListTo
# Возвращает список слов из текста с начала и до указанного слова-маркера
# ( не включая маркер).
#
# Параметры:
# (1)     - слово-маркер ( можно использовать шаблонный символ "%")
# (2)     - исходный текст
#
wordListTo = $(if $(filter-out $(1),$(firstword $(2))),$(strip \
  $(firstword $(2)) $(call wordListTo,$(1),$(wordlist 2,$(words $(2)),$(2))) \
  ))



# build func: wordPosition
# Возвращает порядковые номера слов текста, равных указанному слову.
# Слова в тексте нумеруются начиная с 1.
#
# Параметры:
# (1)                         - слово для поиска в тексте
# (2)                         - текст
#
# Пример:
#
# "$(call wordPosition,aa,aa bb cc aa mm)" возвращает "1 4"
#
wordPosition = \
  $(if $(1),$(strip \
    $(call wordPosition_Internal,$(1),$(2),$(words $(2)),1) \
  ))

# Параметры:
# (1)                         - слово для поиска в тексте
# (2)                         - текущий текст
# (3)                         - число слов в исходном тексте
# (4)                         - произвольный текст с числом слов, равным
#                               номеру первого слова $(2) в исходном тексте
#
wordPosition_Internal = \
  $(if $(2), \
    $(if $(call nullif,$(1),$(firstword $(2))),,$(words $(4))) \
    $(call wordPosition_Internal,$(1),$(wordlist 2,$(3),$(2)),$(3),$(4) 1) \
  )



#
# group: Регистр символов
#

# build func: changeCase
# Переводит символы строки в нужный регистр.
#
# Параметры:
# (1)     - исходная строка
# (2)     - код типа перевода ( U в верхний регистр, L в нижний регистр)
#
changeCase = $(call changeCase_Internal,$(1),$(strip $(subst L,,$(2))), \
  a b c d e f g h i j k l m n o p q r s t u v w x y z , \
  A B C D E F G H I J K L M N O P Q R S T U V W X Y Z \
  )

changeCase_Internal = $(call translate,$(1), \
  $(if $(2),$(3),$(4)), \
  $(if $(2),$(4),$(3)) \
  )



# build func: lower
# Переводит символы строки в нижний регистр.
#
# Параметры:
# (1)     - исходная строка
#
lower  = $(call changeCase,$(1),L)



# build func: upper
# Переводит символы строки в верхний регистр.
#
# Параметры:
# (1)     - исходная строка
#
upper  = $(call changeCase,$(1),U)



#
# group: Номер версии
#



# build func: compareVersion
# Сравнивает номера версий.
# Номер версии представляет собой последовательность целых неотрицательных
# чисел, разделяемых точкой.
#
# Параметры:
# $(1)    - первый номер версии
# $(2)    - второй номер версии
#
# Возврат:
# 1       - первый номер больше второго
# 0       - первый номер равен второму
# -1      - первый номер меньше второго
#
compareVersion = \
  $(strip $(call compareVersion_Internal,$(subst ., ,$(1)),$(subst ., ,$(2))))

# Сравнивает номера версий, заданные списком чисел.
#
compareVersion_Internal = \
  $(if $(firstword $(1)$(2)), \
    $(foreach cmp, \
      $(call compareNumber,$(firstword $(1)),$(firstword $(2))), \
      $(if $(call nullif,$(cmp),0), \
        $(cmp), \
        $(call compareVersion_Internal, \
          $(wordlist 2,$(words $(1)),$(1)), \
          $(wordlist 2,$(words $(2)),$(2))))) \
    ,0)



# build func: getVersionDir
# Возвращает каталоги с номерами версий в соотвествии нумерацией версий.
#
# Параметры:
# $(1)    - путь к каталогу, в котором расположены каталоги с версиями
#
# Замечания:
# - каталоги с номерами версий должны соответствовать маске [0-9.]*
#
getVersionDir = \
  $(shell ls -1d --sort=v $(1)/[0-9.]* 2>/dev/null)



#
# group: Разбор строки подключения
#

# build func: getDbName
# Возвращает имя БД ( в нижнем регистре).
#
# Параметры:
# (1)     - строка подключения к БД в формате [userName[/password]][@dbName]
# (2)     - имя БД по умолчанию ( используется, если в (1) БД не указана)
#
getDbName = $(strip $(call lower, \
  $(if $(findstring @,$(1)), \
    $(word \
      $(words $(subst @, ,$(1)x)) \
      , $(subst @, ,$(1)) $(2) \
    ) \
    , $(2) \
  )))



# build func: getProductionDbName
# Возвращает имя промышленной БД.
#
# Для определения имени промышленной БД, в списке тестовых БД (
# <cspGetProductionDbName_TestDbList>) выполняется поиск по указанному имени БД
# и в случае нахождения совпадения ( без учета регистра) вместо переданного
# имени возвращается имя промышленной БД из
# <cspGetProductionDbName_ProdDbList>, находящееся в той же позиции в списке,
# что и найденное совпадение. Аналогичным образом выполняется замена имени
# согласно спискам <cspGetProductionDbName_AliasDbList> и
# <cspGetProductionDbName_MainDbList>.
# Также в случае, если исходное имя является именем промышленной БД
# ( проверяется совпадение без учета регистра с именами, указанными в
# <cspGetProductionDbName_ProdDbList>, <cspGetProductionDbName_MainDbList> или
# <cspGetProductionDbName_ExtraDbList>), то возвращается точное ( с учетом
# регистра) имя этой промышленной БД. Если не удалось определить имя
# промышленной БД, то возвращается пустая строка.
#
# Параметры:
# (1)     - исходное имя БД
#
# Возврат:
# точное ( с учетом регистра) имя промышленной БД либо пустая строка,
# если не удалось определить.
#
getProductionDbName = $(call \
  getProductionDbNameInternal,$(call lower,$(firstword $(1))))

getProductionDbNameInternal = $(strip $(if $(1), \
  $(call nullif,$(call translateWord,$(1), \
      $(cspGetProductionDbName_TestDbList) \
				$(cspGetProductionDbName_AliasDbList) \
        $(call lower,$(getProductionDbName_AllProdList)), \
      $(cspGetProductionDbName_ProdDbList) \
      	$(cspGetProductionDbName_MainDbList) \
        $(getProductionDbName_AllProdList) \
    ),$(1)) \
  ,))

# Список всех промышленных БД.
getProductionDbName_AllProdList = \
  $(sort $(cspGetProductionDbName_ExtraDbList) $(cspGetProductionDbName_MainDbList) $(cspGetProductionDbName_ExtraDbList) $(cspGetProductionDbName_ProdDbList))

# Проверяем корректность задания списков трансляции имен БД
ifneq ($(words $(cspGetProductionDbName_TestDbList)),$(words $(cspGetProductionDbName_ProdDbList)))

tmpVar := $(error В переменных cspGetProductionDbName_TestDbList и cspGetProductionDbName_ProdDbList указано различное число имен)

endif

ifneq ($(words $(cspGetProductionDbName_AliasDbList)),$(words $(cspGetProductionDbName_MainDbList)))

tmpVar := $(error В переменных cspGetProductionDbName_AliasDbList и cspGetProductionDbName_MainDbList указано различное число имен)

endif

# Проверяем корректность задания имен промышленных БД
ifneq ($(words $(getProductionDbName_AllProdList)),$(words $(sort $(call lower,$(getProductionDbName_AllProdList)))))

tmpVar := $(error Имя одной и той же БД в переменных cspGetProductionDbName_ProdDbList, cspGetProductionDbName_MainDbList и cspGetProductionDbName_ExtraDbList отличается регистром символов)

endif



# build func: getUserName
# Возвращает имя пользователя ( в нижнем регистре).
#
# Параметры:
# (1)     - строка подключения к БД в формате [userName[/password]][@dbName]
#
getUserName = $(strip \
  $(if $(patsubst @%,,$(1)),$(call lower, \
    $(firstword $(subst /, ,$(firstword $(subst @, ,$(1))))) \
    , \
  )))



# build func: getUser
# Возвращает пользователя БД в формате userName@dbName ( в нижнем регистре).
#
# Параметры:
# (1)     - строка подключения к БД в формате [userName[/password]][@dbName]
#
getUser = $(strip \
  $(call getUserName,$(1))$(addprefix @,$(call getDbName,$(1),)) \
  )



# build func: getLocalDbDir
# Возвращает имя локального подкаталога, соответствующего указанной БД.
#
# Параметры:
# $(1)                        - имя БД
#
# Возврат:
# имя локального подкаталога либо "-" если не удалось определить имя
# промышленной БД.
#
getLocalDbDir = $(firstword $(call getProductionDbName,$(firstword $(1))) -)



# build func: getLocalUserDir
# Возвращает путь к локальному подкаталогу, соответствующему указанному
# пользователю.
#
# Параметры:
# $(1)                        - строка с именем БД и именем пользователя в
#                               формате "<dbName>/<userName>"
#
# Возврат:
# путь к локальному подкаталогу ( относительно каталога "Local") либо "-"
# если не было указано имя пользователя или не удалось определить имя
# промышленной БД.
#
getLocalUserDir = $(firstword $(if $(word 2,$(subst /, ,$(1))), \
  $(addsuffix /$(call getUserName,$(word 2,$(subst /, ,$(1)))), \
  $(call getProductionDbName,$(firstword $(subst /, ,$(1))))) \
  ,) -)



#
# group: Аргументы загружаемых файлов
#

# build func: getArgumentDefineFileWord
# Возвращает слово, содержащее маску загружаемого файла и используемое при
# назначении ему аргументов.
#
# Параметры:
# $(1)    - список загружаемых файлов ( путь с добавлением $(lu*) или $(ru*))
#
getArgumentDefineFileWord = $(addsuffix $(rrb),$(1))



# build func: getArgumentDefine
# Возвращает текст для назначения аргументов, передаваемых при загрузке файла.
#
# Параметры:
# $(1)    - список загружаемых файлов ( путь с добавлением $(lu*) или $(ru*))
# $(2)    - список аргументов ( через пробел, каждый аргумент в кавычках)
#
getArgumentDefine = \
  $(addsuffix $(space)echo '$(2)'; ;;,$(call getArgumentDefineFileWord,$(1)))



# build func: getNzArgumentDefine
# Возвращает текст для назначения аргументов, передаваемых при загрузке файла
# в случае, если присутствуют не пустые ( отличные от "") значения аргументов.
#
# Параметры:
# $(1)    - список загружаемых файлов ( путь с добавлением $(lu*) или $(ru*))
# $(2)    - список аргументов ( через пробел, каждый аргумент в кавычках)
#
getNzArgumentDefine = \
  $(if $(strip $(subst "",,$(2))),$(call getArgumentDefine,$(1),$(2)),)



# build func: ifArgumentDefined
# Проверяет назначение аргументов для указанного загружаемого файла ( по точному
# соответствию).
#
# Параметры:
# $(1)    - загружаемый файл ( путь с добавлением $(lu*) или $(ru*))
# $(2)    - список назначенных аргументов ( обычно $(loadArgumentList))
#
# Возврат:
# - если аргументы назначены, то переданное имя файла $(1), иначе ничего
#
ifArgumentDefined = \
  $(if $(filter $(call getArgumentDefineFileWord,$(1)),$(2)),$(1),)

