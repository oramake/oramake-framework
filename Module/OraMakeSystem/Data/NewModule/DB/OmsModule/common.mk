# makefile: ������ OMS

# ���� ������� ������ OMS-�������, �� ������ �������� ��� ������ ����.
#
# OMS Version Information:
# OMS root: Oracle/Module/OraMakeSystem
# $Revision:: 24409882 $
# $Date:: 2016-05-30 10:22:40 +0300 #$
#



# ������ ��� ���������� ��������� ����� ( ��� ��������� ����� ������ ��� OMS,
# ����������� ��� ����������� ���������� OMS-������ ������� � ������ ����������
# ������, �������� ��� ��������� � ������� ����� DB/Makefile).
# +



# ��������� ����, � �������� ��� ������� make.
#
# ���������:
# (1)     - ������ ����� ��� ����������
filterGoals = $(strip $(filter $(1), $(MAKECMDGOALS)))

# ���� ������� make, ����������� � ���������.
installGoals := $(call filterGoals, \
    install \
    install-after \
    install-batch \
    install-before \
    install-data \
    install-load \
    install-save-info \
    install-schema \
  )

# ���� ������� make, ����������� � ������ ���������.
uninstallGoals := $(call filterGoals, \
    uninstall \
    uninstall-after \
    uninstall-before \
    uninstall-data \
    uninstall-load \
    uninstall-save-info \
    uninstall-schema \
  )

# ���� ������� make, ����������� � ������ ����.
grantGoals := $(call filterGoals, \
    grant \
    grant-exec \
    grant-save-info \
  )



# ��������� �������� make, ����������� ��� ��������� ��� ������ ���������.
ifneq ($(strip $(installGoals) $(uninstallGoals)),)

  -include Install/Config/define.mk

  ifneq ($(INSTALL_VERSION),)

    ifneq ($(installGoals),)

      -include Install/Config/$(INSTALL_VERSION)/define.mk

    endif

    ifneq ($(uninstallGoals),)

      -include Install/Config/$(INSTALL_VERSION)/Revert/define.mk

    endif
  endif
endif



#
# ����������� ����
#
.PHONY:                       \
  all.oms                     \
  clean.oms                   \
  set-version.oms             \
  show-oms-version.oms        \
  update-oms-version.oms      \
  gendoc.oms                  \
  gendoc-clean.oms            \
  gendoc-menu.oms             \
  grant.oms                   \
  grant-exec.oms              \
  grant-save-info.oms         \
  load-start-log.oms          \
  load.oms                    \
  load-clean.oms              \
  install.oms                 \
  install-after.oms           \
  install-batch.oms           \
  install-before.oms          \
  install-data.oms            \
  install-load.oms            \
  install-save-info.oms       \
  install-schema.oms          \
  install-test.oms            \
  test.oms                    \
  uninstall.oms               \
  uninstall-after.oms         \
  uninstall-before.oms        \
  uninstall-data.oms          \
  uninstall-load.oms          \
  uninstall-save-info.oms     \
  uninstall-schema.oms        \



#
# group: ����� ����
#

# build var: OMS_DEBUG_LEVEL
# ������� ������ ���������� ���������� ��������� OMS.
# ��������� ��������:
# 0   - �� �������� ( �� ���������);
# 1   - �������;
# 2   - �����������;
# 3   - ����������� � ������� ����������� ��������� ������ � �.�.;
#
export OMS_DEBUG_LEVEL = 0

# build var: OMS_INSTALL_SHARE_DIR
# ���� � �������� � �������������� ������� OMS.
export OMS_INSTALL_SHARE_DIR = /usr/local/share/oms

# build var: OMS_INSTALL_CONFIG_DIR
# ���� � �������� � ����������� OMS.
export OMS_INSTALL_CONFIG_DIR = /usr/local/etc/oms

# build var: OMS_SAVE_FILE_INSTALL_INFO
# ���� ���������� ���������� � �� �� ��������������� ������.
# ���������� ����������� � ������ �������� ������ �������� <oms-load> � �������
# SQL*Plus.
#
# ��������� ��������:
# 0   - �� ���������
# 1   - ��������� ( �� ���������)
#
export OMS_SAVE_FILE_INSTALL_INFO ?= 1



# target: all.oms
# ������� �������� ������.

all.oms:                      \
  gendoc-menu.oms             \
  load.oms                    \



# target: clean.oms
# ������� �����, ��������� ��� ������.

clean.oms:                    \
  load-clean.oms              \
  gendoc-clean.oms            \



#
# group: ������ ������
#

# ��������� ����� map-����� ��� �����, ���������� � ��.
mapFileXml := $(shell \
  if [[ -f ../Doc/map.xml ]]; then cat ../Doc/map.xml; fi; \
)

# �������� �������� ���� version �� map-�����
moduleVersion := $(call getXmlElementValue,version,$(mapFileXml))

# ���������� �������� �� ��������� ��� MODULE_VERSION.
ifeq ($(MODULE_VERSION),)
  ifneq ($(origin MODULE_VERSION),command line)

    ifneq ($(call lower,$(INSTALL_VERSION)),last)
      ifeq ($(call compareVersion,$(INSTALL_VERSION),$(moduleVersion)),1)

        moduleVersionNew := $(shell \
          oms-module set-version --directory .. \
            --used-only --quiet "$(INSTALL_VERSION)" \
          && echo \
            "OMS: module version changed using INSTALL_VERSION: $(INSTALL_VERSION) ( please, run \"make gendoc\")" >&2 \
        )

        ifneq ($(moduleVersionNew),)

          moduleVersion := $(moduleVersionNew)

        endif

      endif
    endif

    MODULE_VERSION := $(moduleVersion)

  endif
endif

# ���������� ���� ������ ��������� ������.
#
# ���������:
# (1)                         - ����� ��������������� ������ ��� Last ( ���
#                               ����� ��������) ��� ������ ��������� �������
#                               ������ ������
#
# �������:
# 1 ��� ������ ���������, 0 � ������ ��������� ( ���� ������� ������), �����
# ������ ������.
#
getIsFullInstall = \
  $(if $(call nullif,last,$(call lower,$(1))),$(if $(1),0),1)

# ���������� ��������������� ������ ������.
#
# ���������:
# (1)                         - ����� ��������������� ������ ��� Last ( ���
#                               ����� ��������), ���� ��������������� �������
#                               ������ ������
#
getInstallVersion = \
  $(if $(call nullif,1,$(call getIsFullInstall,$(1))),$(1),$(MODULE_VERSION))



# ������������ ��������� ��������� ��� ������� oms-load

export OMS_MODULE_INITIAL_SVN_PATH := \
  $(call getXmlElementValue,initialPath,$(mapFileXml))

export OMS_MODULE_SVN_ROOT := \
  $(call getXmlElementValue,path,$(mapFileXml))

export OMS_IS_FULL_MODULE_INSTALL := \
  $(call getIsFullInstall,$(INSTALL_VERSION))

export OMS_MODULE_INSTALL_VERSION := \
  $(call getInstallVersion,$(INSTALL_VERSION))

export OMS_MODULE_VERSION := $(MODULE_VERSION)

processStartTimeId := $(shell date "+%Y-%m-%dT%H:%M:%S%z $$PPID")
export OMS_PROCESS_ID := $(word 2,$(processStartTimeId))
export OMS_PROCESS_START_TIME := $(firstword $(processStartTimeId))

export OMS_PLSQL_WARNINGS := $(PLSQL_WARNINGS)

getSvnInfo := $(shell oms-module --directory .. show-svn-info --quiet)
export OMS_SVN_FILE_PATH := $(wordlist 2,999,$(getSvnInfo))
export OMS_SVN_VERSION_INFO := $(firstword $(getSvnInfo))

export OMS_ACTION_GOALS = $(MAKECMDGOALS)



# target: set-version.oms
# ������������� ����� ������� ������ ������.

set-version.oms:
	@oms-module set-version --directory .. "$(MODULE_VERSION)"



#
# group: ������ OMS-������
#

# ����� ������� ����� � OMS
omsRevisionKeyword    := \$$Revision:: 24409882 $$

omsRevision := $(call getRevisionFromKeyword,$(omsRevisionKeyword))

# ���� ���������� ��������� ����� � OMS
omsChangeDateKeyword  := \$$Date:: 2016-05-30 10:22:40 +0300 #$$

omsChangeDate := $(call getDateFromKeyword,$(omsChangeDateKeyword))



# target: show-oms-version.oms
# ���������� ������ OMS-������, �������� � ������ ������.

show-oms-version.oms:
	@echo "OMS files version: $(OMS_VERSION) ( rev. $(omsRevision), $(omsChangeDate))"



# target: update-oms-version.oms
# ��������� OMS-�����, �������� � ������ ������.

update-oms-version.oms:
	@oms-update-module --from-revision "$(omsRevision)" -d ..



#
# group: ��������� ������������
#

# ������������ ������ ���������� ������������ ��� ����������� ������.
ifneq ($(call isMakeFlag,B),)
  GENDOC_DB_FLAGS += "--rebuild"
endif

# ����� ��������� � ��������, ������������ ������� oms-auto-doc
autoDocFlags = -d ".." -o $(GENDOC_DB_DIR) \
  --nd-flags "$(GENDOC_DB_FLAGS)"

# target: gendoc.oms
# ���������� ������������.

gendoc.oms:
	@[[ -n "$(GENDOC_DB_DIR)" ]] \
	&& ( oms-auto-doc $(autoDocFlags)) \
	|| exit 0

# target: gendoc-clean.oms
# ������� ��������� ����� ( ���) ������� ����������������.

gendoc-clean.oms:
	@oms-auto-doc --clean $(autoDocFlags)

# target: gendoc-menu.oms
# ���������� ���� � ������������.
# ������������ ������ <oms-auto-doc>.

gendoc-menu.oms:
	@[[ -n "$(GENDOC_DB_DIR)" ]] \
	&& ( oms-auto-doc -m $(autoDocFlags)) \
	|| exit 0



#
# group: �������� ������ � ��
#

# ������� �� ������������ SQL-���������
omsSqlScriptDir  = $(OMS_INSTALL_SHARE_DIR)/SqlScript

# ������� � �������, ������������ ��� �������� � ��.
loadDir           = $(omsModuleDir)/Load

# ������� � ������ � ������� �������, ������������ ��� �������� � ��
loadLogDir        = $(loadDir)/Log

# ������� � ������ ��������� ������
installLogDir     = $(loadLogDir)/Install

# ������� � �������, ������������ ���� �������� � ��
loadStateDir      = $(loadDir)/State

# ��������� ���������� ������, ������������ ��� ���������� ������ � ��
runExt            = .run

# ���������� ������, ����������� ���� �������� � ��
loadExt            = .load

# ���������� ���� ��� ������ ������ � ��������� �����������
vpath %$(loadExt)    $(loadStateDir)

# ���� ��� ������ ����������� SQL-��������
vpath oms-%.sql    $(omsSqlScriptDir)



#
# ���������� ����� � ��
#

# build func: getFileModulePart
# ���������� ����� ����� ������, � ������� ��������� ����.
#
# ���������:
# $(1)    - ���� � ����� ������������ �������� DB
#
# �������:
# - ����� ����� ������ ( ����� �� 1 �� 9) ���� ������ ������, ���� �� �������
#   ����������
#
# ���������:
# - ���� �������� ����� ��������� ��� ���������� ������ ������, �� �����
#   ��������� ����������� ����� ����� ������;
#
getFileModulePart = $(firstword \
  $(foreach part, 1 2 3 4 5 6 7 8 9, \
    $(if $(filter $(1).$(part),$(getFileModulePart_FilePartList)),$(part),) \
  ) \
)

# ��������� � ���������� getFileModulePart_FilePartList ������ ������,
# ��������������� ��� ��������� ��� ��������, � ��������� ����� ������, �
# ������� ��� ���������.
# ������ ����� ������ ����������� � ���� ���������� �����, ��������, ��� �����
# "DB/Install/Schema/Last/run.sql", ��� ��� ����������� �������� �
# installSchemaTarget � ������ ����� ������ � ������� $(lu), � ������ �����
# ������� "DB/Install/Schema/Last/run.sql.1". ��� ����� ���������� lu* �
# ru* �������� ������������� ����������� ��������.

lu  = 1
lu2 = 2
lu3 = 3
lu4 = 4
lu5 = 5
lu6 = 6
lu7 = 7
lu8 = 8
lu9 = 9

ru  = 1
ru2 = 2
ru3 = 3
ru4 = 4
ru5 = 5
ru6 = 6
ru7 = 7
ru8 = 8
ru9 = 9

getFileModulePart_FilePartList := $(strip \
  $(loadTarget) \
  $(installBeforeTarget) \
  $(installSchemaTarget) \
  $(installDataTarget) \
  $(installAfterTarget) \
  $(uninstallBeforeTarget) \
  $(uninstallSchemaTarget) \
  $(uninstallLoadTarget) \
  $(uninstallDataTarget) \
  $(uninstallAfterTarget) \
  $(grantTarget) \
)

lu  =
lu2 =
lu3 =
lu4 =
lu5 =
lu6 =
lu7 =
lu8 =
lu9 =

ru  =
ru2 =
ru3 =
ru4 =
ru5 =
ru6 =
ru7 =
ru8 =
ru9 =

# ������, ����������� �������� ����� ����� �� SKIP_FILE_MASK � FILE_MASK.
#
# ����������:
# loadFile                    - ��� ������������ �����
# isNeedProcess               - ��������� �������� ( 1, ���� ���� ��������
#                               �� �������� ���������� �� ������, ����� 0)
#
checkFileMaskScript = \
	skipFileMask="$(strip $(subst $(comma),$(space),$(SKIP_FILE_MASK)))"; \
	isNeedProcess=1; \
	set -f ; set -- $$skipFileMask; set +f ; \
	for mask in "$$@" ; do \
		case "$$loadFile" in $$mask) \
			isNeedProcess=0; break; ;; \
		esac; \
	done; \
	if (( isNeedProcess)); then \
		fileMask="$(strip $(subst $(comma),$(space),$(FILE_MASK)))"; \
		set -f ; set -- $$fileMask; set +f ; \
		for mask in "$$@" ; do \
			isNeedProcess=0; \
			case "$$loadFile" in $$mask) \
				isNeedProcess=1; break; ;; \
			esac; \
		done; \
  fi;

# ��������� �� ������ �����, ������� ��������� ��� ����� ������������ ������ ��
# ���������� SKIP_FILE_MASK � �� ��������� ��� ����� FILE_MASK � ������
# �������.
#
# ���������:
# $(1)    - ������ ���� ������
#
filterOutFileMask = \
  $(if $(strip $(SKIP_FILE_MASK))$(strip $(FILE_MASK)),$(strip $(shell \
    loadFileList="$(strip $(1))"; \
    for loadFile in $$loadFileList ; do \
      $(checkFileMaskScript) \
      if (( isNeedProcess)) ; then \
        echo "$$loadFile"; \
      fi; \
   done; \
  )),$1)

# �������� ������������ ( ��� ������) ��� �������� �� $@ � $<.
# ����� ���������� ������ �� ������.
# ������������, ��� ����������� $< ������������ ����� ����������� � �� ������
# ( ������: Do/run.sql), � ���� $@ ������������ ����� ��� �� ������ �
# ����������� ����� ����� ����� ������������ � �� ( userName@dbName) �
# ������������� ���������� ( ������: Do/run.sql.userName@dbName.load).
getLoadUser  = $(patsubst $(<F).%,%,$(basename $(@F)))

# �������� ������������ � ������� ��� �������� �� loadUserIdList �
# �������������� ������� getLoadUser.
getLoadUserId  =  \
  $(firstword $(filter $(subst @,/%@,$(getLoadUser)),$(loadUserIdList)))

# ���������� ����� ����� ������, ����������� � ������ ����� ��.
# � ������, ���� ��������� ������ ������ ������������ ����������� � ���� �
# �� �� ����� ��, ������������ ����������� �����.
#
getLoadModulePart = \
  $(words 1 $(call wordListTo,$(getLoadUser),$(loadUserList)))

# ���������� ������ ����������, ������������ ������������ �����.
getLoadArgument = $(shell case "$@" in $(loadArgumentList) esac)

# ������� ���������� ����� � ��.
runFunction  = \
	{ \
	loadFile="$<"; \
	loadUser="$(getLoadUser)"; \
	loadUserId='$(getLoadUserId)'; \
	loadOperatorId='$(loadOperatorId)'; \
	$(checkFileMaskScript) \
	if (( isNeedProcess )) ; then \
		set -o pipefail; \
		{ \
		echo "$$loadFile: -> $$loadUser ..."; \
		oms-load \
			--file-module-part "$(firstword $(call getFileModulePart,$<) $(getLoadModulePart))" \
			$(if $(call isMakeFlag,i),--force) \
			$(if $(FILE_MASK),--file-mask "$(subst $(comma),$(space),$(strip $(FILE_MASK)))") \
			$(if $(SKIP_FILE_MASK),--skip-file-mask "$(subst $(comma),$(space),$(strip $(SKIP_FILE_MASK)))") \
			$(if $(SQL_DEFINE),--sql-define "$(subst ",\",$(SQL_DEFINE))") \
			$(if $(subst 0,,$(SKIP_CHECK_JOB)), --skip-check-job,) \
			$(if $(subst 0,,$(SKIP_LOAD_OPTION)), --skip-load-option,) \
			$(if $(subst 0,,$(UPDATE_OPTION_VALUE)), --update-option-value,) \
			$(if $(subst 0,,$(UPDATE_SCHEDULE)), --update-schedule,) \
			--userid "$${loadUserId:-$$loadUser}" \
			--operatorid "$$loadOperatorId" \
			--log-path-prefix "$(loadLogDir)/$$loadUser" \
			"$$loadFile" $(getLoadArgument); \
		} $(copyToLoadLogCmd); \
	fi; \
	}

# ������, ����������� �������� ����� ����� �� SKIP_FILE_MASK � FILE_MASK,
# � ����� ���������� �������������� ������.
#
# ���������:
#
# 1                           - ������������ ����������, � ������� ���������
#                               ����� ��������������� ������� ��� ��������
#                               �����
#
# ����������:
# loadFileTargetList          - ������ ����� ��� ����������� ������
#
# ��������� ��������� � ����������� �������� ����� � ���� ������ ����� ���
# ������ ��������.
checkFileTargetScript = \
  loadExtList="$(addprefix .,$(foreach e,$(loadExt) $(runExt),$(addsuffix $(e),$(loadUserListReal))))"; \
  for loadFileTarget in $$loadFileTargetList ; do \
    for loadExt in $$loadExtList ; do \
      loadFile="$${loadFileTarget%$$loadExt}"; \
      if [[ "$$loadFileTarget" = "$${loadFile}$${loadExt}" ]] ; then \
        $(1) \
        $(checkFileMaskScript) \
        if (( isNeedLoad)) && (( isNeedProcess)) ; then \
          echo "$$loadFileTarget"; \
        fi; \
        break; \
      fi; \
    done; \
  done;



#
# �������� ����� � ��
#

# ������, ����������� �������� ����� ����� �� LOAD_FILE_MASK.
#
# ����������:
# loadFile                    - ��� ������������ �����
# isNeedLoad                  - ��������� �������� ( 1 ���� ��������� ���
#                               �����, ����� 0)
#
checkLoadFileMaskScript = \
	loadFileMask="$(strip $(subst $(comma),$(space),$(LOAD_FILE_MASK)))"; \
	isNeedLoad=1; \
	if [[ -n "$$loadFileMask" ]] ; then \
		isNeedLoad=0; \
		set -f ; set -- $$loadFileMask; set +f ; \
		for mask in "$$@" ; do \
			case "$$loadFile" in $$mask) \
				isNeedLoad=1; break; ;; \
			esac; \
		done; \
	fi;

# ��������� � ������ ������ ����������� �����.
# �� ������ ����������� �����, ������� �� ��������� ��� ����� ������ ��
# ���������� LOAD_FILE_MASK � FILE_MASK( ���� ��� ������) ���� ��������� ���
# ����� ���������� SKIP_FILE_MASK.
#
# ���������:
# $(1)    - ������ ���� ����������� ������ ( � ���������� $(lu),...)
#
filterLoadFileTarget = \
  $(if $(strip $(LOAD_FILE_MASK) $(SKIP_FILE_MASK) $(FILE_MASK)),$(strip $(shell \
    loadFileTargetList="$(strip $(1))"; \
	  $(call checkFileTargetScript, $(checkLoadFileMaskScript)) \
  )),$1)

# ��������� ����������� ������������ ����� � ������ �������� ��� ���� load.
#
# ���������:
# $(1)    - ����������� ���� ( ���� � ����������� $(lu*) ��� $(ru*))
#
# �������:
# 1 ���� ��� ������������� ����������, ����� ""
#
isLoadTarget = $(if $(filter $(1),$(loadTarget)),1,)

# ������� �������� ����� � ��.
# � ������ ��������� ���������� ������� � ��, ������� � �������� $(loadStateDir)
# ����, ����������� � ������ ���� ( ��� ����������� ����� �������� ��������).
loadFunction  =  \
	loadFile="$<"; \
	isLoadTarget="$(call isLoadTarget,$@)"; \
	if (( isLoadTarget )) ; then \
	$(checkLoadFileMaskScript) \
	else \
		isNeedLoad=1; \
	fi; \
	if (( isNeedLoad )) ; then \
		$(runFunction) \
		&& mkdir -p "$(loadStateDir)/$(@D)" && touch "$(loadStateDir)/$@"; \
	fi;


#
# �������� ������ � ��.
#

# ������, ����������� �������� �����, ������������ � �����.
#
# ����������:
# loadFile                    - ��� ������������ ����� ��������������, ���
#								���������� ����� ��������� � ������ �����
# isNeedLoad                  - ��������� �������� ( 1 ���� ��������� ���
#                               �����, ����� 0)
#
checkBatchScript = \
  batchDirName=$${loadFile%/*}; \
  batchName=$${batchDirName\#\#*/}; \
  skipBatchMask="$(strip $(subst $(comma),$(space),$(SKIP_BATCH_MASK)))"; \
  isNeedLoad=1; \
  set -f ; set -- $$skipBatchMask; set +f ; \
  for mask in "$$@" ; do \
    case "$$batchName" in $$mask) \
      isNeedLoad=0; break; ;; \
    esac; \
  done; \
  if (( isNeedLoad)); then \
    batchMask="$(strip $(subst $(comma),$(space),$(BATCH_MASK)))"; \
    set -f ; set -- $$batchMask; set +f ; \
    for mask in "$$@" ; do \
      isNeedLoad=0; \
      case "$$batchName" in $$mask) \
        isNeedLoad=1; break; ;; \
      esac; \
    done; \
  fi;

# �������� ����� �������� �� ������ �����.
getSourceFileList = \
  $(foreach u, $(loadUserListReal), \
    $(foreach e, $(loadExt) $(runExt), \
      $(patsubst %.$(u)$(e),%, \
        $(filter %.$(u)$(e),$(1)) \
      ) \
    ) \
  )

# ��������� � ������ ������ �� ���� ��� ������, � ���������� ������� ���� ����
# batch.xml � ��� �� ������.
getBatchLocalTargetList = \
  $(foreach fileTarget, $(1), \
   $(if \
     $(filter \
        $(dir $(call getSourceFileList, $(fileTarget)))batch.xml \
        , $(call getSourceFileList, $(1)) \
     ) \
     , $(fileTarget) \
   ) \
  )

# ��������� � ������ ������ �� ���� ��� ������ ������, ������� �� ������
# � ������ getBatchLocalTargetList.
getBatchCommonTargetList = \
  $(filter-out \
    $(call getBatchLocalTargetList, $(1)) \
    , $(1) \
  )


# ��������� � ������ ������ ������ ������ �����, ��������������� ������,
# ������� ������������� ����� BATCH_MASK ��� SKIP_BATCH_MASK.
#
# ������ �������������� ������ ��� ������ ������, ������� ����� ������� �
# ������-���� �����, �.�. � ���������� �������� ���� ����� ���� batch.xml,
# ������� ������ � installBatchTarget.
#
# ���������:
# $(1)    - ������ ���� ����������� ������ ( � ���������� $(lu),...)
#
filterInstallBatchTarget = \
  $(if \
    $(strip $(BATCH_MASK) $(SKIP_BATCH_MASK)) \
    ,  $(strip $(shell \
          echo "$(call getBatchCommonTargetList, $(strip $(1)))"; \
          loadFileTargetList="$(call getBatchLocalTargetList, $(strip $(1)))"; \
          $(call checkFileTargetScript, $(checkBatchScript)) \
       )) \
    , $1 \
  )


#
# ��������� ���������� ����������� � ��
#

# ���������� ��������� ����������� ���������.
loadOperatorId    := $(LOAD_OPERATORID)

                                        # ������� �������� ������, ���� ������
                                        # �������� � ��� ������
ifneq ($(loadOperatorId),)
  ifeq ($(patsubst %/,%@,$(loadOperatorId)),$(subst /,@,$(loadOperatorId)))
    loadOperatorId    := $(shell            \
      oms-connect-info                      \
        --operatorid "$(loadOperatorId)"    \
        --out-operatorid                    \
        --ignore-absent-password            \
      )
  endif
endif

                                        # �������� ����� ��������� ( ��� ������)
loadOperatorName  := $(firstword $(subst /, ,$(loadOperatorId)))

# �������� ��������������� ������ ����������� � ��.
#
# ���������:
# (1)     - ������ ����������� � �� � ������� [userName[/password]][@dbName]
# (2)     - ��� �� �� ��������� ( ������������, ���� � (1) �� �� �������)
#
getConnectInfo = $(shell                \
  oms-connect-info                      \
    --userid '$(1)'                     \
    --default-db '$(2)'                 \
    --out-userid                        \
    --ignore-absent-password            \
  )

# ������ ������������� ��� �������� ( ��� �������).
# ������ ���������� ( LOAD_USERID LOAD_USERID2 ...), ��� ���������� ��������
# �� ��� ����� ����������� ����.
loadUserList         :=

# ������ ������������� ��� �������� ( �������� � ��������).
loadUserIdList       :=

# ���������� ��������� �����������.
ifneq ($(LOAD_DB)$(LOAD_USERID),)

  loadUserId          := $(call getConnectInfo,$(LOAD_USERID),$(LOAD_DB))
  loadUser            := $(call getUser,$(loadUserId))

  loadUserList        += $(loadUser)
  loadUserIdList      += $(loadUserId)
  ru                  := $(loadUser)$(runExt)
  lu                  := $(loadUser)$(loadExt)

  %.$(loadUser)$(runExt): %
		@$(runFunction)

  %.$(loadUser)$(loadExt): %
		@$(loadFunction)

else

  loadUserList        += -

endif

# ���������� ��������� ����������� #2.
ifneq ($(LOAD_DB2)$(LOAD_USERID2),)

  loadUserId          := $(call getConnectInfo,$(LOAD_USERID2),$(LOAD_DB2))
  loadUser            := $(call getUser,$(loadUserId))

  loadUserList        += $(loadUser)
  loadUserIdList      += $(loadUserId)
  ru2                 := $(loadUser)$(runExt)
  lu2                 := $(loadUser)$(loadExt)

  %.$(loadUser)$(runExt): %
		@$(runFunction)

  %.$(loadUser)$(loadExt): %
		@$(loadFunction)

else

  loadUserList        += -

endif

# ���������� ��������� ����������� #3.
ifneq ($(LOAD_DB3)$(LOAD_USERID3),)

  loadUserId          := $(call getConnectInfo,$(LOAD_USERID3),$(LOAD_DB3))
  loadUser            := $(call getUser,$(loadUserId))

  loadUserList        += $(loadUser)
  loadUserIdList      += $(loadUserId)
  ru3                 := $(loadUser)$(runExt)
  lu3                 := $(loadUser)$(loadExt)

  %.$(loadUser)$(runExt): %
		@$(runFunction)

  %.$(loadUser)$(loadExt): %
		@$(loadFunction)

else

  loadUserList        += -

endif

# ���������� ��������� ����������� #4.
ifneq ($(LOAD_DB4)$(LOAD_USERID4),)

  loadUserId          := $(call getConnectInfo,$(LOAD_USERID4),$(LOAD_DB4))
  loadUser            := $(call getUser,$(loadUserId))

  loadUserList        += $(loadUser)
  loadUserIdList      += $(loadUserId)
  ru4                 := $(loadUser)$(runExt)
  lu4                 := $(loadUser)$(loadExt)

  %.$(loadUser)$(runExt): %
		@$(runFunction)

  %.$(loadUser)$(loadExt): %
		@$(loadFunction)

else

  loadUserList        += -

endif

# ���������� ��������� ����������� #5.
ifneq ($(LOAD_DB5)$(LOAD_USERID5),)

  loadUserId          := $(call getConnectInfo,$(LOAD_USERID5),$(LOAD_DB5))
  loadUser            := $(call getUser,$(loadUserId))

  loadUserList        += $(loadUser)
  loadUserIdList      += $(loadUserId)
  ru5                 := $(loadUser)$(runExt)
  lu5                 := $(loadUser)$(loadExt)

  %.$(loadUser)$(runExt): %
		@$(runFunction)

  %.$(loadUser)$(loadExt): %
		@$(loadFunction)

else

  loadUserList        += -

endif

# ���������� ��������� ����������� #6.
ifneq ($(LOAD_DB6)$(LOAD_USERID6),)

  loadUserId          := $(call getConnectInfo,$(LOAD_USERID6),$(LOAD_DB6))
  loadUser            := $(call getUser,$(loadUserId))

  loadUserList        += $(loadUser)
  loadUserIdList      += $(loadUserId)
  ru6                 := $(loadUser)$(runExt)
  lu6                 := $(loadUser)$(loadExt)

  %.$(loadUser)$(runExt): %
		@$(runFunction)

  %.$(loadUser)$(loadExt): %
		@$(loadFunction)

else

  loadUserList        += -

endif

# ���������� ��������� ����������� #7.
ifneq ($(LOAD_DB7)$(LOAD_USERID7),)

  loadUserId          := $(call getConnectInfo,$(LOAD_USERID7),$(LOAD_DB7))
  loadUser            := $(call getUser,$(loadUserId))

  loadUserList        += $(loadUser)
  loadUserIdList      += $(loadUserId)
  ru7                 := $(loadUser)$(runExt)
  lu7                 := $(loadUser)$(loadExt)

  %.$(loadUser)$(runExt): %
		@$(runFunction)

  %.$(loadUser)$(loadExt): %
		@$(loadFunction)

else

  loadUserList        += -

endif

# ���������� ��������� ����������� #8.
ifneq ($(LOAD_DB8)$(LOAD_USERID8),)

  loadUserId          := $(call getConnectInfo,$(LOAD_USERID8),$(LOAD_DB8))
  loadUser            := $(call getUser,$(loadUserId))

  loadUserList        += $(loadUser)
  loadUserIdList      += $(loadUserId)
  ru8                 := $(loadUser)$(runExt)
  lu8                 := $(loadUser)$(loadExt)

  %.$(loadUser)$(runExt): %
		@$(runFunction)

  %.$(loadUser)$(loadExt): %
		@$(loadFunction)

else

  loadUserList        += -

endif

# ���������� ��������� ����������� #9.
ifneq ($(LOAD_DB9)$(LOAD_USERID9),)

  loadUserId          := $(call getConnectInfo,$(LOAD_USERID9),$(LOAD_DB9))
  loadUser            := $(call getUser,$(loadUserId))

  loadUserList        += $(loadUser)
  loadUserIdList      += $(loadUserId)
  ru9                 := $(loadUser)$(runExt)
  lu9                 := $(loadUser)$(loadExt)

  %.$(loadUser)$(runExt): %
		@$(runFunction)

  %.$(loadUser)$(loadExt): %
		@$(loadFunction)

else

  loadUserList        += -

endif

# ������ ������� �������� ������������� ��� �������� ( ��� ������������).
loadUserListReal = $(sort $(filter-out -,$(loadUserList)))

# �������� ����������� ( ���������� ���������� �����).
-include loaddeps.mk



#
# ��� �������� ������.
#

# ��� �������� ������ � �� ( ������� ���������� ��������).
loadFileLog =

# �������� ��� �������� ������ ��� ��������� ������.
ifneq ($(strip $(installGoals) $(uninstallGoals) $(grantGoals)),)

  moduleName := $(call getXmlElementValue,name,$(mapFileXml))

  # ��������� ��� ����� ����
  loadFileLog := $(shell \
    date \
    +"$(installLogDir)/"%Y%m%d_%H%M%S"$(strip \
        $(addprefix -, \
          $(subst $(space),_,$(moduleName)) \
        ) \
      )$(strip \
        $(addprefix -, \
          $(if $(installGoals),, \
          $(if $(uninstallGoals),uninstall, \
          $(if $(grantGoals),grant, \
          ))) \
        ) \
      )$(strip \
        $(addprefix -,$(INSTALL_VERSION)) \
      )$(strip \
        $(addprefix -,$(word 2,$(subst @, , \
          $(firstword $(filter-out -,$(loadUserList)))  \
        ))) \
      ).txt"; \
  )

endif

# ������ ��� ����������� ���� ����������� ������ ������� � ��� �������� ������.
# ���� ����� �������� ��������� ����������� �������, �������������� ������
# ���� ���������� ����� "set -o pipefail".
ifeq ($(loadFileLog),)
  toLoadLogCmd     =
  copyToLoadLogCmd =
else
  toLoadLogCmd     = 2>&1 | unix2dos >> "$(loadFileLog)"
  copyToLoadLogCmd = \
		2>&1 | gawk '{ \
			print; fflush(); \
			printf( "%s\r\n", $$0) >> "$(loadFileLog)"; fflush( "$(loadFileLog)"); \
			}'
endif



# target: load-start-log.oms
# ���������� ��������� ( ��������� make) � ��� �������� ������.

load-start-log.oms:
	@if [[ -z "$(loadFileLog)" ]] ; then \
		echo "Error: not defined log filename loadFileLog." ; exit 10; \
	else \
		set -o pipefail; \
		mkdir -p "$(dir $(loadFileLog))" \
		&& { \
			   echo "moduleName          : $(moduleName)" \
			&& echo "modulePath          : $(OMS_MODULE_SVN_ROOT)" \
			&& echo "moduleInitialPath   : $(OMS_MODULE_INITIAL_SVN_PATH)" \
			&& echo "moduleVersion       : $(moduleVersion)" \
			&& echo "SVN path            : $(OMS_SVN_FILE_PATH)" \
			&& echo "SVN version info    : $(OMS_SVN_VERSION_INFO)" \
			&& echo "" \
			&& echo "module OMS version    : $(OMS_VERSION) ( rev. $(omsRevision), $(omsChangeDate))" \
			&& { \
					omsLoadVersion=$$(oms-load --version | tr "\n\r" "  ") \
			  && usedOmsVersion=$${omsLoadVersion#oms-load (OMS) } \
				&& usedOmsVersion=$${usedOmsVersion%% *} \
				&& usedOmsRevision=$${omsLoadVersion#*File revision*: } \
				&& usedOmsRevision=$${usedOmsRevision%% *} \
				&& usedOmsChangeDate=$${omsLoadVersion#*File change date*: } \
				&& usedOmsChangeDate=$${usedOmsChangeDate:0:25} \
				&& echo "installed OMS version : $$usedOmsVersion ( rev. $$usedOmsRevision, $$usedOmsChangeDate)" \
				; } \
			&& echo "" \
			&& echo "process ID          : $(OMS_PROCESS_ID)" \
			&& echo "process start time  : $(OMS_PROCESS_START_TIME)" \
			&& echo "" \
			&& echo "*** make option" \
			&& echo "MAKECMDGOALS        : $(MAKECMDGOALS)" \
			&& if [[ "$(origin MODULE_VERSION)" == "command line" ]]; then \
			   echo "MODULE_VERSION      : $(MODULE_VERSION)"; \
			   fi \
			&& echo "INSTALL_VERSION     : $(INSTALL_VERSION)" \
			&& echo "loadUserList        :$(loadUserList)" \
			&& echo "loadOperator        : $(loadOperatorName)" \
			&& if [[ -n "$(grantGoals)" ]]; then \
			   echo "GRANT_SCRIPT        : $(GRANT_SCRIPT)" \
			&& echo "TO_USERNAME         : $(TO_USERNAME)"; \
			   fi \
			&& echo "FILE_MASK           : $(FILE_MASK)" \
			&& echo "LOAD_FILE_MASK      : $(LOAD_FILE_MASK)" \
			&& if [[ "$(LOCAL_DB_DIR)" != "-" ]]; then \
			   echo "LOCAL_DB_DIR        : $(LOCAL_DB_DIR)"; \
			   fi \
			&& if [[ "$(LOCAL_USER_DIR)" != "-" ]]; then \
			   echo "LOCAL_USER_DIR      : $(LOCAL_USER_DIR)"; \
			   fi \
			&& echo "SKIP_FILE_MASK      : $(SKIP_FILE_MASK)" \
			&& echo "SQL_DEFINE          : $(subst ",\",$(SQL_DEFINE))" \
			&& echo "PLSQL_WARNINGS      : $(PLSQL_WARNINGS)" \
			&& if [[ -n "$(BATCH_MASK)" ]]; then \
			   echo "BATCH_MASK          : $(BATCH_MASK)"; \
			   fi \
			&& if [[ -n "$(SKIP_BATCH_MASK)" ]]; then \
			   echo "SKIP_BATCH_MASK     : $(SKIP_BATCH_MASK)"; \
			   fi \
			&& if [[ -n "$(SKIP_LOAD_OPTION)" ]]; then \
			   echo "SKIP_LOAD_OPTION    : $(SKIP_LOAD_OPTION)"; \
			   fi \
			&& if [[ -n "$(SKIP_CHECK_JOB)" ]]; then \
			   echo "SKIP_CHECK_JOB      : $(SKIP_CHECK_JOB)"; \
			   fi \
			&& if [[ -n "$(UPDATE_OPTION_VALUE)" ]]; then \
			   echo "UPDATE_OPTION_VALUE    : $(UPDATE_OPTION_VALUE)"; \
			   fi \
			&& if [[ -n "$(UPDATE_SCHEDULE)" ]]; then \
			   echo "UPDATE_SCHEDULE     : $(UPDATE_SCHEDULE)"; \
			   fi \
			&& echo "make flags          : $(call getMakeFlagList)" \
			&& if [[ "$(OMS_DEBUG_LEVEL)" != "0" ]]; then \
			   echo "OMS_DEBUG_LEVEL     : $(OMS_DEBUG_LEVEL)"; \
			   fi \
			&& if [[ "$(OMS_INSTALL_SHARE_DIR)" != "/usr/local/share/oms" ]]; then \
			   echo "OMS_INSTALL_SHARE_DIR: $(OMS_INSTALL_SHARE_DIR)"; \
			   fi \
			&& if [[ "$(OMS_INSTALL_CONFIG_DIR)" != "/usr/local/etc/oms" ]]; then \
			   echo "OMS_INSTALL_CONFIG_DIR: $(OMS_INSTALL_CONFIG_DIR)"; \
			   fi \
			&& if [[ "$(OMS_SAVE_FILE_INSTALL_INFO)" != "1" ]]; then \
			   echo "OMS_SAVE_FILE_INSTALL_INFO: $(OMS_SAVE_FILE_INSTALL_INFO)"; \
			   fi \
			$(foreach v,$(installAddonOptionList), \
			&& if [[ -n "$($(v))" ]]; then printf "%-20s: %s\n" "$(v)" "$($(v))"; fi \
			) \
			&& echo ""; \
			} $(toLoadLogCmd) \
		&& echo "start log: $(loadFileLog)"; \
	fi



# ������� �� ������ ������������ ��-�� ���������� LOAD_DB* ����������� �����.
#
# ���������:
# $(1)    - ������ ����������� ������
#
filterOutZeroDbTarget = $(filter-out %.,$(1))

# �������� ��� ����� �� ����� ����� ��� ��������.
# �� ���������� ���� ��������� ����������, ������������ ��� ��������, �
# ����������, ������������ ���� ��� ��������.
#
# ���������:
# $(1)    - ������ ������ ��� ��������
#
# �������:
# - ������ ���� ������
#
getTargetFileName = \
  $(foreach t,$(1) \
    ,$(foreach u,$(loadUserListReal) \
      ,$(foreach e,$(loadExt) $(runExt),$(strip \
        $(if $(filter %.$(u)$(e),$(t)),$(patsubst %.$(u)$(e),%,$(t)),) \
      )) \
    ) \
  )

# ������� ����������� �����.
# �����������:
# - ������������ ��-�� ���������� ��;
# - �� ��������������� LOAD_FILE_MASK, ���� ��� ������;
# - �� ��������������� FILE_MASK, ���� ��� ������;
# - ��������������� SKIP_FILE_MASK, ���� ��� ������;
#
loadTargetReal := \
  $(call filterLoadFileTarget,$(call filterOutZeroDbTarget,$(loadTarget)))



# target: load.oms
# ��������� ����� � ��.

load.oms: $(loadTargetReal)



# target: load-clean.oms
# ������� ��������� �����, ��������� ��� �������� � ��.

load-clean.oms:
	-@rm -rf $(loadDir)/*



#
# group: ��������� ������ � ��
#

# ��������� �������� ���������� ������� �������� ���������� oms-check-load.sql.
# ����� ��� �������� ������� �� installCheckLockTarget ( �� ����������� ������,
# �� ����������� ��-�� FILE_MASK, LOAD_FILE_MASK � SKIP_FILE_MASK) �
# mandatoryCheckLockTarget.
# ������������� ���������� ������������ ��� ����������� ����������.

ifneq ($(call filterGoals, install install-before install-before.oms),)

  checkLockArgumentList := \
    $(foreach u, $(loadUserListReal) \
      ,$(call getNzArgumentDefine,oms-check-lock.sql.$(u)$(runExt),"$(strip \
          $(sort $(notdir \
            $(filter %.pks %.pkb %.prc %.snp %.tab %typ %tyb %.vw, \
              $(call filterOutFileMask, \
                $(foreach e, $(loadExt) $(runExt), \
                  $(patsubst %.$(u)$(e),%, \
                    $(filter $(loadTargetReal), \
                      $(filter %.$(u)$(e),$(installCheckLockTarget)) \
                    ) \
                    $(filter-out $(loadTarget), \
                      $(filter %.$(u)$(e),$(installCheckLockTarget)) \
                    ) \
                  ) \
                ) \
              ) \
              $(foreach e, $(loadExt) $(runExt), \
                $(patsubst %.$(u)$(e),%, \
                  $(filter %.$(u)$(e),$(mandatoryCheckLockTarget)) \
                ) \
              ) \
            ) \
          )) \
        )") \
    )

  loadArgumentList += $(checkLockArgumentList)

endif

# ��������� �������� ������� oms-check-lock.sql ��� ���������� ����������.
installBeforeTargetReal = $(strip \
  $(foreach t, $(call filterOutZeroDbTarget,$(installBeforeTarget)), \
    $(if $(filter oms-check-lock.sql.%$(runExt),$(t)), \
      $(call ifArgumentDefined,$(t),$(loadArgumentList)) \
      , $(t) \
    ) \
  ))



# target: install-before.oms
# ��������� ��������������� �������� ����� ����������.

install-before.oms: \
  load-start-log.oms \
  $(installBeforeTargetReal)



# target: install-schema.oms
# ������������� ������� ����� � ��.

install-schema.oms: \
  load-start-log.oms \
  $(call filterOutZeroDbTarget,$(installSchemaTarget))



# target: install-load.oms
# ��������� ������� � �� ��� ���������� ���������.

install-load.oms: \
  load-start-log.oms \
  load.oms



# target: install-data.oms
# ��������� ������������ ������ � ��.

install-data.oms: \
  load-start-log.oms \
  $(call filterOutZeroDbTarget,$(installDataTarget))



# ������� ����������� ����� ������.
# �����������:
# - ������������ ��-�� ���������� ��;
# - �� ��������������� SKIP_FILE_MASK, FILE_MASK, ���� ��� ������;
# - �� ��������������� BATCH_MASK, SKIP_BATCH_MASK, ���� ��� ������ � ���� ����
#   ��������� � ������ ���� ����� ( � ������ ������ ��� �������� � ��� ��
#   ���������� ������������ batch.xml);
#
installBatchTargetReal = $(call filterInstallBatchTarget, $(call filterOutZeroDbTarget,$(installBatchTarget)))



# target: install-batch.oms
# ������������� �������� ������� � ��.

install-batch.oms: \
  load-start-log.oms \
  $(installBatchTargetReal)



# target: install-after.oms
# ��������� ����������� ��������� ��������.

install-after.oms: \
  load-start-log.oms \
  $(call filterOutZeroDbTarget,$(installAfterTarget))



#
# ���������� � �� ���������� � ��������� �� ��������� ( ������� %-save-info)
#

# ���������� ��� ���� ��� ���������� ���������� � �������� �� ��������� �
# ������, ���� ��� ������ ����������� ��� ������� ������� make.
#
# ���������:
# (1)                         - ��� �������� ����
#

# �� ��������� ���������� ���������� � ��������� �� ������� ����� ( ��������,
# install � uninstall, ����� grant) � ������, ���� �� ���� �������
# ��������������� ������ ������ ( ��� ���� grant � ���� ������ ��-���������
# ������������ Last)
#
getSaveInfoGoal = $(if $(call filterGoals, \
  $(if $(if $(call nullif,grant,$(1)),$(OMS_MODULE_INSTALL_VERSION),1), \
    $(1) $(1).oms) \
  $(1)-save-info $(1)-save-info.oms \
),$(1)-save-info.oms)

# ���������� ����������� ����� ��� ���� %-save-info.
#
# ���������:
# (1)                         - ��� �������� ����
#
getSaveInfoTarget = \
  $(addprefix oms-save-$(1)-info.sql, \
    $(addprefix .,$(addsuffix $(runExt),$(loadUserList))))

# ���������� ������� ����������� ����� ��� ���� %-save-info
#
# ���������:
# (1)                         - ��� �������� ����
#
getSaveInfoTargetReal = \
  $(sort $(filter-out %.-$(runExt),$(call getSaveInfoTarget,$(1))))

# ��������� ���������� ������ ��� ���� %-save-info
#
# ���������:
# (1)                         - ��� �������� ����
# (2)                         - �������������� ��������� ( ���������� �������
#                               ������� �� ������ �������)
#
getSaveInfoArgumentList = \
  $(foreach f,$(call getSaveInfoTargetReal,$(1)), \
    $(call getArgumentDefine,$(f),"$(subst $(space),:,$(strip \
        $(call wordPosition,$(f),$(call getSaveInfoTarget,$(1))) \
      ))"$(if $(2), $(2))))



# target: install-save-info.oms
# ��������� � �� ���������� �� ��������� ������.

ifneq ($(call getSaveInfoGoal,install),)

  loadArgumentList += \
    $(call getSaveInfoArgumentList,install)

endif

install-save-info.oms: \
  load-start-log.oms \
  $(call getSaveInfoTargetReal,install)



# target: install.oms
# ������������� ������ � ��.

install.oms:                            \
    load-start-log.oms                  \
    install-before.oms                  \
    install-schema.oms                  \
    install-load.oms                    \
    install-data.oms                    \
    install-batch.oms                   \
    install-after.oms                   \
    $(call getSaveInfoGoal,install)     \

	@echo -e "\ninstall: finished" $(toLoadLogCmd)



#
# group: ������������ ������
#

# target: install-test.oms
# ��������� ������� ��� ������������ � ��.
#
install-test.oms: \
  $(call filterOutZeroDbTarget,$(installTestTarget))



# target: test.oms
# ��������� ������ ������� �� ������������ ������.
#
test.oms: \
  $(call filterOutZeroDbTarget,$(testTarget))



#
# group: ������ ��������� ������ � ��
#

# ������� ����������� ����� ��� ������ ���������.
uninstallLoadTargetReal := \
  $(call filterOutFileMask,$(call filterOutZeroDbTarget,$(uninstallLoadTarget)))


# ��������� �������� ���������� ������� �������� ���������� oms-check-load.sql.
# ����� ��� �������� ������� �� uninstallCheckLockTarget ( �� �����������
# ������, �� ����������� ��-�� FILE_MASK, SKIP_FILE_MASK) �
# mandatoryCheckLockTarget.  ������������� ���������� ������������ ���
# ����������� ����������.

ifneq ($(call filterGoals, uninstall uninstall-before uninstall-before.oms),)

  uninstallCheckLockArgumentList := \
    $(foreach u, $(loadUserListReal) \
      ,$(call getNzArgumentDefine,oms-check-lock.sql.$(u)$(runExt),"$(strip \
          $(sort $(notdir \
            $(filter %.pks %.pkb %.prc %.snp %.tab %typ %tyb %.vw, \
              $(call filterOutFileMask, \
                $(foreach e, $(loadExt) $(runExt), \
                  $(patsubst %.$(u)$(e),%, \
                    $(filter $(uninstallLoadTargetReal), \
                      $(filter %.$(u)$(e),$(uninstallCheckLockTarget)) \
                    ) \
                    $(filter-out $(uninstallLoadTarget), \
                      $(filter %.$(u)$(e),$(uninstallCheckLockTarget)) \
                    ) \
                  ) \
                ) \
              ) \
              $(foreach e, $(loadExt) $(runExt), \
                $(patsubst %.$(u)$(e),%, \
                  $(filter %.$(u)$(e),$(mandatoryCheckLockTarget)) \
                ) \
              ) \
            ) \
          )) \
        )") \
    )

  loadArgumentList += $(uninstallCheckLockArgumentList)

endif

# ��������� �������� ������� oms-check-lock.sql ��� ���������� ����������.
uninstallBeforeTargetReal = $(strip \
  $(foreach t, $(call filterOutZeroDbTarget,$(uninstallBeforeTarget)), \
    $(if $(filter oms-check-lock.sql.%$(runExt),$(t)), \
      $(call ifArgumentDefined,$(t),$(loadArgumentList)) \
      , $(t) \
    ) \
  ))



# target: uninstall-before.oms
# ��������� ��������������� �������� ����� ������� ���������.

uninstall-before.oms: \
  load-start-log.oms \
  $(uninstallBeforeTargetReal)



# target: uninstall-schema.oms
# �������� ���������, ��������� � ������� ����� ��� ���������� ���������.

uninstall-schema.oms: \
  load-start-log.oms \
  $(call filterOutZeroDbTarget,$(uninstallSchemaTarget))



# target: uninstall-load.oms
# ��������� ���������� ������ �������� � �� ��� ������ ���������.

uninstall-load.oms: \
  load-start-log.oms \
  $(uninstallLoadTargetReal)



# target: uninstall-data.oms
# �������� ���������, ��������� ��� �������� ������������ ������ � ��.

uninstall-data.oms: \
  load-start-log.oms \
  $(call filterOutZeroDbTarget,$(uninstallDataTarget))



# target: uninstall-after.oms
# ��������� ����������� ������ ��������� ��������.

uninstall-after.oms: \
  load-start-log.oms \
  $(call filterOutZeroDbTarget,$(uninstallAfterTarget))



# target: uninstall-save-info.oms
# ��������� � �� ���������� �� ������ ��������� ������.

ifneq ($(call getSaveInfoGoal,uninstall),)

  loadArgumentList += \
    $(call getSaveInfoArgumentList,uninstall,"$(UNINSTALL_RESULT_VERSION)")

endif

uninstall-save-info.oms: \
  load-start-log.oms \
  $(call getSaveInfoTargetReal,uninstall)



# target: uninstall.oms
# �������� ��������� ������ ������ � ��.

uninstall.oms:                            \
    load-start-log.oms                  \
    uninstall-before.oms                  \
    uninstall-schema.oms                  \
    uninstall-load.oms                    \
    uninstall-data.oms                    \
    uninstall-after.oms                   \
    $(call getSaveInfoGoal,uninstall)     \

	@echo -e "\nuninstall: finished" $(toLoadLogCmd)



#
# group: ������ ���� ������������� ��
#

# ������� ����������� ������� ��� ������ ����.
grantTargetReal = $(call filterOutZeroDbTarget,$(grantTarget))

# ��������� �������� ���������� �������� ������ ����.

ifneq ($(call filterGoals, grant grant.oms),)

  loadArgumentList += \
    $(call getArgumentDefine,$(grantTargetReal),"$(TO_USERNAME)")

endif

# target: grant-exec.oms
# ��������� ������� ������ ����.

grant-exec.oms:                         \
  load-start-log.oms                    \
  $(grantTargetReal)                    \

	@set -o pipefail; \
	if [[ -z "$(firstword $(grantTargetReal))" ]]; then \
		echo -e "Error: grant script not found."; exit 11; \
	fi $(copyToLoadLogCmd)



# target: grant-save-info.oms
# ��������� � �� ���������� � ������ ���� ������������.

ifneq ($(call getSaveInfoGoal,grant),)

  loadArgumentList += \
    $(call getSaveInfoArgumentList,grant,"$(call getInstallVersion,$(grantVersion))" "$(call getIsFullInstall,$(grantVersion))" "$(grantScript)" "$(TO_USERNAME)")

endif

grant-save-info.oms: \
  load-start-log.oms \
  $(call getSaveInfoTargetReal,grant)



# target: grant.oms
# ������ ����� ������������ ��.

grant.oms: \
  load-start-log.oms \
  grant-exec.oms \
  $(call getSaveInfoGoal,grant) \

	@echo -e "\ngrant: finished" $(toLoadLogCmd)

