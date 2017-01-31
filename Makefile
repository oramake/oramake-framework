#
# Настройки выполнения операций уровня проекта, включая выполнение типовых
# операций для нескольких модулей ( установка в БД, удаление из БД и т.д.)
#

# Абстрактные цели
.PHONY:  \
  grant \
  dist \
  install \
  load-clean \
  uninstall \



# Список всех обрабатываемых модулей согласно порядку их установки
# ( с учетом зависимостей между модулями)
allModuleList = \
	ModuleInfo \
	Common \
	Logging \
	AccessOperator \
	DynamicSql \
	Option \
	Scheduler \
	TaskHandler \
	File \
	Mail \
	DataSync \
	Calendar \
	TestUtility \



#
# group: Константы
#

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



#
# group: Функции сборки
#


# build func: reverse
# Возвращает список слов в обратном порядке.
#
# Параметры:
# (1)     - список слов
#
reverse = $(strip \
  $(if $(firstword $(1)), \
		$(call reverse,$(wordlist 2,$(words $(1)),$(1))) $(firstword $(1)) \
  ))


# build func: getUserName
# Возвращает имя пользователя.
#
# Параметры:
# (1)     - строка подключения к БД в формате [userName[/password]][@dbName]
#
getUserName = $(strip \
  $(if $(patsubst @%,,$(1)), \
    $(firstword $(subst /, ,$(firstword $(subst @, ,$(1))))) \
    , \
  ))



#
# group: Параметры
#


# build var: ADMIN_USERID
# Привилегированный пользователь БД, под которым выдаются дополнительные
# права для установки модулей
# ( формат: userName[/password]]@dbName).
#
ADMIN_USERID =


# build var: MAIN_USERID
# Основной пользователь для установки модулей
# ( формат: userName[/password]]@dbName).
#
MAIN_USERID =

# build var: INSTALL_OPERATORID
# Логин и пароль оператора модуля AccessOperator, который используется при
# установке
# ( формат: login/password).
#
INSTALL_OPERATORID = Guest/Guest

# build var: GRANT_USERNAME
# Пользователь БД, которому выдаются права на использование модулей.
#
GRANT_USERNAME =


# build var: MODULE_LIST
# Список обрабатываемых модулей ( по умолчанию без ограничений).
#
# Представляет собой список ( через запятую) имен модулей.
MODULE_LIST :=


# build var: SKIP_MODULE_LIST
# Список исключаемых из обработки модулей ( по умолчанию модули не исключаются).
#
# Представляет собой список ( через запятую) имен модулей.
SKIP_MODULE_LIST :=


# build var: JUST_PRINT_FLAG
# Флаг вывода команд без их фактического выполнения
# ( 1 да, 0 нет ( по умолчанию))
#
# Представляет собой список ( через запятую) имен модулей.
JUST_PRINT_FLAG := 0

ifeq ($(JUST_PRINT_FLAG),1)
runCmd = echo
else
runCmd =
endif


# Список всех обрабатываемых модулей согласно порядку их установки
# ( с учетом параметров MODULE_LIST и SKIP_MODULE_LIST).
#
processModuleList = $(strip \
		$(filter-out \
			$(subst $(comma),$(space),$(SKIP_MODULE_LIST)), \
			$(if $(MODULE_LIST), \
				$(filter $(subst $(comma),$(space),$(MODULE_LIST)),$(allModuleList)), \
				$(allModuleList) \
			) \
		) \
	)


# target: install
# Выполняет первоначальную установку модулей.
#
# Пример:
#
# - создание основного пользователя для установки модулей ( om_main)
#
# (code)
#
# SQL> @Module/UserCreate/create-user-main.sql om_main
#
# (end)
#
# ( выполняется под пользователем, имеющим достаточно прав для успешного
# 	выполнения скрипта Module/UserCreate/create-user-main.sql, например
# 	под пользователем om_admin, созданным предварительно скриптом
# 	Module/UserCreate/create-user-admin.sql)
#
# - установка модулей
#
# (code)
#
# $ make install MAIN_USERID=om_main@TestDb ADMIN_USERID=om_admin@TestDb SQL_DEFINE=indexTablespace=USERS
#
# (end)
#
# ( предполагается, что пользователь om_admin имеет достаточно прав для
# 	выдачи дополнительных привилегий, для индексов используется явно заданное
# 	табличное пространство USERS)
#
# Замечания:
# - в случае, если в другой схеме БД уже установлен модуль AccessOperator,
#   права на его выданы всем пользователям ( public) и он не должен
#   использоваться под пользователем om_main, то нужно перед установкой модулей
#   под пользователем om_main создать пакет-заглушку, исключающую использование
#   пакета pkg_Operator модуля AccessOperator из другой схемы ( и позволяющий
#   выполнить безошибочную установку):
# - перед повторной первоначальной установкой модулей ( если из данного
#   каталога уже выполнялась установка, а затем модули были удалены из БД)
#   нужно удалить созданные при предыдущей установкой временные файлы
#   ( см. цель load-clean ниже);
#
#   были удалены из БД
#
# (code)
#
# SQL> create package pkg_Operator is end;
# /
#
# (end)
#
#
install:
	@for module in $(processModuleList); do \
		$(runCmd) cd Module/$${module}/DB \
		&& grantSysPrivsFlag=0 \
		&& addonLoadUser="" \
		&& isUseOperator=1 \
		&& addonOpt="" \
		&& case "$${module}" in \
			AccessOperator) \
				isUseOperator=""; \
				addonOpt=" SKIP_FILE_MASK=*/oms-save-install-info.sql"; \
				;; \
			Calendar) \
				addonLoadUser=4; \
				;; \
			Common) \
				grantSysPrivsFlag=1; \
				isUseOperator=""; \
				;; \
			File) \
				grantSysPrivsFlag=1; \
				;; \
			Logging) \
				isUseOperator=""; \
				addonOpt=" NO_ACCESSOPERATOR=1"; \
				;; \
			Mail) \
				grantSysPrivsFlag=1; \
				addonOpt=" SKIP_FILE_MASK=*/oms-activate-batch.sql"; \
				;; \
			ModuleInfo) \
				isUseOperator=""; \
				addonOpt=" NO_ACCESSOPERATOR=1"; \
				;; \
			Option) \
				addonLoadUser=2; \
				addonOpt=" PRODUCTION_DB_NAME=ProdDb"; \
				;; \
			Scheduler) \
				grantSysPrivsFlag=1; \
				addonLoadUser=2; \
				addonOpt=" PRODUCTION_DB_NAME=ProdDb"; \
				;; \
			TaskHandler) \
				grantSysPrivsFlag=1; \
				;; \
		esac \
		&& if (( $$grantSysPrivsFlag )); then \
			case "$${module}" in \
				*) \
					$(runCmd) make grant \
						LOAD_USERID="$(ADMIN_USERID)" \
						GRANT_SCRIPT=sys-privs \
						TO_USERNAME="$(call getUserName,$(MAIN_USERID))" \
						OMS_SAVE_FILE_INSTALL_INFO=0 \
						SKIP_FILE_MASK=*/oms-save-grant-info.sql \
					;; \
			esac \
		fi \
		&& case "$${module}" in \
			*) \
				$(runCmd) make install INSTALL_VERSION=Last \
					LOAD_USERID="$(MAIN_USERID)" \
					$${addonLoadUser:+ LOAD_USERID$${addonLoadUser}="$(MAIN_USERID)"} \
					$${isUseOperator:+ LOAD_OPERATORID="$(INSTALL_OPERATORID)"} \
					$${addonOpt}; \
				;; \
		esac \
		&& case "$${module}" in \
			AccessOperator) \
				$(runCmd) make install-save-info INSTALL_VERSION=Last \
					LOAD_USERID="$(MAIN_USERID)" \
					LOAD_OPERATORID="$(INSTALL_OPERATORID)" \
				;; \
		esac \
		&& $(runCmd) cd ../../.. \
		|| { echo "Error on processing \"$@\" for \"$${module}\", stop"; exit 15; }; \
	done; \



# target: grant
# Выдает права на использование модулей указанному пользователю БД.
#
# Пример:
#
# (code)
#
# $ make grant MAIN_USERID=om_main@TestDb GRANT_USERNAME=om_user
#
# (end)
#
# ( пользователю om_user выдаются права на модули, ранее установленные в
# 	схему om_main с помощью цели <install>)
#
grant:
	@for module in $(processModuleList); do \
		$(runCmd) cd Module/$${module}/DB \
		&& grantScript="" \
		&& case "$${module}" in \
			ModuleInfo) \
				grantScript="save-install-info.sql"; \
				;; \
		esac \
		&& case "$${module}" in \
			*) \
				$(runCmd) make grant \
					LOAD_USERID="$(MAIN_USERID)" \
					LOAD_OPERATORID="$(INSTALL_OPERATORID)" \
					$${grantScript:+ GRANT_SCRIPT="$${grantScript}"} \
					TO_USERNAME="$(GRANT_USERNAME)"; \
				;; \
		esac \
		&& $(runCmd) cd ../../.. \
		|| { echo "Error on processing \"$@\" for \"$${module}\", stop"; exit 15; }; \
	done; \



# target: uninstall
# Выполняет удаление ранее установленных модулей из БД.
#
# Пример:
#
# (code)
#
# $ make uninstall MAIN_USERID=om_main@TestDb
#
# (end)
#
# ( удаляются модули, ранее установленные в схему om_main с помощью цели
# 	<install>)
#
# Замечания:
# - в случае, если в другой схеме БД уже установлен модуль AccessOperator,
#   права на его выданы всем пользователям ( public), то после удаления
#   локального модуля AccessOperator при попытке удаления оставшихся модулей
#   возникнет ошибка из-за отсутствия регистрации оператора. Для решения
#   проблемы под пользователем om_main нужно создать пакет-заглушку,
#   исключающую использование пакета pkg_Operator модуля AccessOperator из
#   другой схемы:
#
# (code)
#
# SQL> create package pkg_Operator is end;
# /
#
# (end)
#
# 	а затем снова запустить удаление, перечислив оставшиеся модули в параметре
# 	<MODULE_LIST>, например:
#
# (code)
#
# $ make uninstall MAIN_USERID=om_main@TestDb MODULE_LIST=ModuleInfo,Common,Logging
#
# (end)
#
uninstall:
	@for module in $(call reverse,$(processModuleList)); do \
		$(runCmd) cd Module/$${module}/DB \
		&& isUseOperator=1 \
		&& case "$${module}" in \
			Common) \
				isUseOperator=""; \
				;; \
			Logging) \
				isUseOperator=""; \
				;; \
			ModuleInfo) \
				isUseOperator=""; \
				;; \
		esac \
		&& case "$${module}" in \
			*) \
				$(runCmd) make uninstall INSTALL_VERSION=Last \
					LOAD_USERID="$(MAIN_USERID)" \
					$${isUseOperator:+ LOAD_OPERATORID="$(INSTALL_OPERATORID)"} \
				;; \
		esac \
		&& $(runCmd) cd ../../.. \
		|| { echo "Error on processing \"$@\" for \"$${module}\", stop"; exit 15; }; \
	done; \



# target: load-clean
# Удаляет временные файлы, созданные при ранее выполнявшихся установках в БД.
#
# Пример:
#
# (code)
#
# $ make load-clean
#
# (end)
#
load-clean:
	@for module in $(processModuleList); do \
		$(runCmd) cd Module/$${module}/DB \
		&& case "$${module}" in \
			*) \
				$(runCmd) make load-clean \
				;; \
		esac \
		&& $(runCmd) cd ../../.. \
		|| { echo "Error on processing \"$@\" for \"$${module}\", stop"; exit 15; }; \
	done; \



# group: Создание дистрибутива

# build var: TAG_NAME
# Имя тэга, по которому формируется дистрибутив.
TAG_NAME=

# build var: DIST_DIR
# Каталог для дистрибутива, создаваемого при выполнении <dist>.
DIST_DIR =


# target: dist
# Создает дистрибутив отдельного модуля по существующему тэгу.
# Имя тэга указывается в параметре <TAG_NAME>, дистрибутив создается в каталоге
# <DIST_DIR> в виде файла с именем "<TAG_NAME>.zip".
#
# Пример:
# $ make dist TAG_NAME=Mail-2.0.2 DIST_DIR=..

dist:
	@showUsage() { \
		echo '( for example usage: "make dist TAG_NAME=Mail-2.0.2 DIST_DIR=..")'; \
	}; \
	if [[ -z "$(TAG_NAME)" ]]; then \
	  echo 'No value for parameter TAG_NAME'; \
		showUsage; \
	  exit 5; \
	elif [[ -z "$(DIST_DIR)" ]]; then \
	  echo "No value for parameter DIST_DIR"; \
		showUsage; \
	  exit 5; \
	elif [[ ! -d "$(DIST_DIR)" ]]; then \
	  echo "Directory \"$(DIST_DIR)\" not exists"; \
	  exit 6; \
	else \
		moduleName="$(TAG_NAME)"; \
		moduleName="$${moduleName%%-*}"; \
		if [[ ! -d "Module/$$moduleName" ]]; then \
			echo "Module \"$$moduleName\" not exists"; \
			exit 6; \
		fi; \
		distFile="$(DIST_DIR)/$(TAG_NAME).zip"; \
		if [[ -f "$$distFile" ]]; then \
			echo "Distributive file \"$$distFile\" already exists"; \
			exit 6; \
		fi; \
		{ cd "Module/$$moduleName" \
			&& git archive \
				--prefix="$(TAG_NAME)/" \
				--format=zip \
				"$(TAG_NAME)" \
			; \
		} >"$$distFile" \
			&& echo "created: $$distFile" \
			|| { echo "Error during creating distributive"; \
					rm -f "$$distFile"; \
					exit 7; \
				}; \
	fi

