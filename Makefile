#
# ��������� ���������� �������� ������ �������, ������� ���������� �������
# �������� ��� ���������� ������� ( ��������� � ��, �������� �� �� � �.�.)
#

# ����������� ����
.PHONY:  \
  grant \
  dist \
  install \
  load-clean \
  uninstall \



# ������ ���� �������������� ������� �������� ������� �� ���������
# ( � ������ ������������ ����� ��������)
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
# group: ���������
#

#
# group: �����������
#

# build var: empty
# ������ ��������.
empty :=

# build var: comma
# �������.
comma := ,

# build var: space
# ������.
space := $(empty) $(empty)



#
# group: ������� ������
#


# build func: reverse
# ���������� ������ ���� � �������� �������.
#
# ���������:
# (1)     - ������ ����
#
reverse = $(strip \
  $(if $(firstword $(1)), \
		$(call reverse,$(wordlist 2,$(words $(1)),$(1))) $(firstword $(1)) \
  ))


# build func: getUserName
# ���������� ��� ������������.
#
# ���������:
# (1)     - ������ ����������� � �� � ������� [userName[/password]][@dbName]
#
getUserName = $(strip \
  $(if $(patsubst @%,,$(1)), \
    $(firstword $(subst /, ,$(firstword $(subst @, ,$(1))))) \
    , \
  ))



#
# group: ���������
#


# build var: ADMIN_USERID
# ����������������� ������������ ��, ��� ������� �������� ��������������
# ����� ��� ��������� �������
# ( ������: userName[/password]]@dbName).
#
ADMIN_USERID =


# build var: MAIN_USERID
# �������� ������������ ��� ��������� �������
# ( ������: userName[/password]]@dbName).
#
MAIN_USERID =

# build var: INSTALL_OPERATORID
# ����� � ������ ��������� ������ AccessOperator, ������� ������������ ���
# ���������
# ( ������: login/password).
#
INSTALL_OPERATORID = Guest/Guest

# build var: GRANT_USERNAME
# ������������ ��, �������� �������� ����� �� ������������� �������.
#
GRANT_USERNAME =


# build var: MODULE_LIST
# ������ �������������� ������� ( �� ��������� ��� �����������).
#
# ������������ ����� ������ ( ����� �������) ���� �������.
MODULE_LIST :=


# build var: SKIP_MODULE_LIST
# ������ ����������� �� ��������� ������� ( �� ��������� ������ �� �����������).
#
# ������������ ����� ������ ( ����� �������) ���� �������.
SKIP_MODULE_LIST :=


# build var: JUST_PRINT_FLAG
# ���� ������ ������ ��� �� ������������ ����������
# ( 1 ��, 0 ��� ( �� ���������))
#
# ������������ ����� ������ ( ����� �������) ���� �������.
JUST_PRINT_FLAG := 0

ifeq ($(JUST_PRINT_FLAG),1)
runCmd = echo
else
runCmd =
endif


# ������ ���� �������������� ������� �������� ������� �� ���������
# ( � ������ ���������� MODULE_LIST � SKIP_MODULE_LIST).
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
# ��������� �������������� ��������� �������.
#
# ������:
#
# - �������� ��������� ������������ ��� ��������� ������� ( om_main)
#
# (code)
#
# SQL> @Module/UserCreate/create-user-main.sql om_main
#
# (end)
#
# ( ����������� ��� �������������, ������� ���������� ���� ��� ���������
# 	���������� ������� Module/UserCreate/create-user-main.sql, ��������
# 	��� ������������� om_admin, ��������� �������������� ��������
# 	Module/UserCreate/create-user-admin.sql)
#
# - ��������� �������
#
# (code)
#
# $ make install MAIN_USERID=om_main@TestDb ADMIN_USERID=om_admin@TestDb SQL_DEFINE=indexTablespace=USERS
#
# (end)
#
# ( ��������������, ��� ������������ om_admin ����� ���������� ���� ���
# 	������ �������������� ����������, ��� �������� ������������ ���� ��������
# 	��������� ������������ USERS)
#
# ���������:
# - � ������, ���� � ������ ����� �� ��� ���������� ������ AccessOperator,
#   ����� �� ��� ������ ���� ������������� ( public) � �� �� ������
#   �������������� ��� ������������� om_main, �� ����� ����� ���������� �������
#   ��� ������������� om_main ������� �����-��������, ����������� �������������
#   ������ pkg_Operator ������ AccessOperator �� ������ ����� ( � �����������
#   ��������� ������������ ���������):
# - ����� ��������� �������������� ���������� ������� ( ���� �� �������
#   �������� ��� ����������� ���������, � ����� ������ ���� ������� �� ��)
#   ����� ������� ��������� ��� ���������� ���������� ��������� �����
#   ( ��. ���� load-clean ����);
#
#   ���� ������� �� ��
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
# ������ ����� �� ������������� ������� ���������� ������������ ��.
#
# ������:
#
# (code)
#
# $ make grant MAIN_USERID=om_main@TestDb GRANT_USERNAME=om_user
#
# (end)
#
# ( ������������ om_user �������� ����� �� ������, ����� ������������� �
# 	����� om_main � ������� ���� <install>)
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
# ��������� �������� ����� ������������� ������� �� ��.
#
# ������:
#
# (code)
#
# $ make uninstall MAIN_USERID=om_main@TestDb
#
# (end)
#
# ( ��������� ������, ����� ������������� � ����� om_main � ������� ����
# 	<install>)
#
# ���������:
# - � ������, ���� � ������ ����� �� ��� ���������� ������ AccessOperator,
#   ����� �� ��� ������ ���� ������������� ( public), �� ����� ��������
#   ���������� ������ AccessOperator ��� ������� �������� ���������� �������
#   ��������� ������ ��-�� ���������� ����������� ���������. ��� �������
#   �������� ��� ������������� om_main ����� ������� �����-��������,
#   ����������� ������������� ������ pkg_Operator ������ AccessOperator ��
#   ������ �����:
#
# (code)
#
# SQL> create package pkg_Operator is end;
# /
#
# (end)
#
# 	� ����� ����� ��������� ��������, ���������� ���������� ������ � ���������
# 	<MODULE_LIST>, ��������:
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
# ������� ��������� �����, ��������� ��� ����� ������������� ���������� � ��.
#
# ������:
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



# group: �������� ������������

# build var: TAG_NAME
# ��� ����, �� �������� ����������� �����������.
TAG_NAME=

# build var: DIST_DIR
# ������� ��� ������������, ������������ ��� ���������� <dist>.
DIST_DIR =


# target: dist
# ������� ����������� ���������� ������ �� ������������� ����.
# ��� ���� ����������� � ��������� <TAG_NAME>, ����������� ��������� � ��������
# <DIST_DIR> � ���� ����� � ������ "<TAG_NAME>.zip".
#
# ������:
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

