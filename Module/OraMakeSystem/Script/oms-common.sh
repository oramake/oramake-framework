#!/bin/bash

# script: oms-common.sh
# ���������� ������, ���������� ���������, ���������� � �������, ������������
# � shell-��������.
#
# ����������� ������� ������� � ��������� ������� ������ ����������� �
# ������� ������� "." ��� �������� ���������� �������:
#
# (code)
#
# . oms-common.sh || exit 11
#
# (end)
#
# ��� ���� �������������� ������ ���� ���������� � ����������������
# ����������:
#
# OMS_VERSION                 - ������ ���������
#
# fileRevisionValue           - ������ � ������� ��������� ������, � �������
#                               ��� ������� ���� ��������� �������
#
# fileChangeDateValue         - ������ � ����� ���������� ��������� �����
#                               ��������� �������
#



# group: ����������



# group: ���������� � ������

# ������������ ��������� ����� ��� ��������� ������ ���������.
# � �������� ������������ ���������� OMS_VERSION �� ��������� ������.
:<<END
OMS_VERSION=1.7.3
END

# var: omsSvnRoot
# ���� � ��������� �������� OMS � Subversion ( ������� � ����� �����������).
omsSvnRoot='Oracle/Module/OraMakeSystem'

# var: omsInitialSvnPath
# �������������� ���� � ��������� �������� OMS � Subversion ( ������� � �����
# ����������� � � ��������� ������ ������, � ������� ��� ������ �������).
omsInitialSvnPath='Oracle/Module/OraMakeSystem@633'

# var: commonRevisionValue
# ������ � ������� ��������� ������, � ������� ��� ������� ����
commonRevisionValue='$Revision:: 2133 $'

# var: commonChangeDateValue
# ������ � ��������� ����� ��������� �����
commonChangeDateValue='$Date:: 2014-07-09 10:34:20 +0400 #$'


# var: commonRevision
# ����� ��������� ������, � ������� ��� ������� ����.
commonRevision=$(( ${commonRevisionValue:12:${#commonRevisionValue}-13} ))

# var: commonChangeDate
# ���� ���������� ��������� �����.
commonChangeDate=${commonChangeDateValue:8:26}



# group: ���� ������

# var: E_FALSE_RESULT
# ��� �������� � ������ �������������� ���������� ����������.
E_FALSE_RESULT=1

# var: E_ARG_ERROR
# ��� ������ ��-�� �������� ����������.
E_ARG_ERROR=10

# var: E_PROCESS_ERROR
# ��� ������ ���������
E_PROCESS_ERROR=11



# group: ������ ���������� ���������

# var: FATAL_LOG_LEVEL
# ��������� � ����������� ������, ���������� ��������� ���������� ����������.
FATAL_LOG_LEVEL=1

# var: ERROR_LOG_LEVEL
# ��������� �� ������.
ERROR_LOG_LEVEL=2

# var: WARNING_LOG_LEVEL
# ��������������.
WARNING_LOG_LEVEL=3

# var: INFO_LOG_LEVEL
# �������������� ���������.
INFO_LOG_LEVEL=4

# var: DEBUG_LOG_LEVEL
# ���������� ��������� 1-�� ������.
DEBUG_LOG_LEVEL=5

# var: DEBUG2_LOG_LEVEL
# ���������� ��������� 2-�� ������.
DEBUG2_LOG_LEVEL=6

# var: DEBUG3_LOG_LEVEL
# ���������� ��������� 3-�� ������.
DEBUG3_LOG_LEVEL=7



# group: ����������� ������

# var: scriptName
# ��� ��������� ������� ( ��� ����).
scriptName=${0##*/}

# var: scriptRevision
# ����� ��������� ������, � ������� ��� ������� ���� ��������� �������.
# �������� ������������ �� ���������� <fileRevisionValue>, ������� ������
# ���� ��������� � ���������������� � �������� �������.
scriptRevision=$(( ${fileRevisionValue:12:${#fileRevisionValue}-13} ))

# var: scriptChangeDate
# ���� ���������� ��������� ����� ��������� �������.
# �������� ������������ �� ���������� <fileChangeDateValue>, ������� ������
# ���� ��������� � ���������������� � �������� �������.
scriptChangeDate=${fileChangeDateValue:8:26}

# var: scriptArgumentList
# ��������� ������ ������� ( ����������� ��� �������)
scriptArgumentList=( "$@" )



# group: ����������� ���������

# var: svnCmd
# ����������� ���� Subversion.
svnCmd="svn"

# var: installDataDir
# ���� � �������� � ������� OMS.
installDataDir="${OMS_INSTALL_DATA_DIR:-/usr/local/share/oms}"

# var: sqlScriptDir
# ������� �� ������������ SQL-���������
sqlScriptDir="${installDataDir}/SqlScript"

# var: configDir
# ������� � �����������.
configDir="${installDataDir}/Config"

# var: templateDir
# ������� � �������� ������ ������.
templateDir="${configDir}/NewModule"

# var: templatePackageName
# ������� ��� ( ��� ����������) ������ � �������� ������ Oracle.
templatePackageName="pkg_NewModule"

# var: patchConfigDir
# ����������� ������� � ������� ��� ���������� ������ ������.
patchConfigDir="$configDir/UpdateModule"

# var: moduleOmsDir
# ������� � ������� OMS ������ ����������� ������.
moduleOmsDir="DB/OmsModule"

# var: tmpFileDir
# ������� ��� ��������� ������
tmpFileDir="${TEMP:-/tmp}"

# var: tmpFile
# ��������� ���� ��� ������������� � �������.
tmpFile="${tmpFileDir}/${scriptName}.$$"

# var: fileExtensionList
# ������ �������� �� ����������� ������ ( � ������������ � ������������
# <�����>).
# ������ �������� ������: ������������������ ����� � ���������� ���������.
# ���� �������� ������:
# - ���������� ����� ( ��� �����)
# - ��������������� ��� ������� � �� ( ���� ����)
# - ������ ��������� ����� ������� � �� �� ����� ����� ��� ����������
#   ( �� ��������� ������ ������������, "u" ������� � ������� �������)
#
# ���������:
# - �������� ���������� ���������� SQL-�������� ����� oms_file_extension_list
#   ( � ������������ ��������� �������) � ������������ � ������� <oms-run.sql>;
#
fileExtensionList=( \
  jav:JAVA\ SOURCE: \
  pks:PACKAGE:u \
  pkb:PACKAGE\ BODY:u \
  prc:PROCEDURE:u \
  snp:MATERIALIZED\ VIEW:u \
  sqs:SEQUENCE:u \
  tab:TABLE:u \
  trg:TRIGGER:u \
  typ:TYPE:u \
  tyb:TYPE\ BODY:u \
  vw:VIEW:u \
)


# group: ��������� ������



# var: logLevel
# ������� ������ ��������� � ���������� �������.
# ����� ���� ������� � ������� ����� --debug-level.
logLevel=$(( INFO_LOG_LEVEL + ${OMS_DEBUG_LEVEL:-0} ))

# var: isDryRun
# ������� ��������� ������� ( ������ ������ ������ ��� ����������).
# �������������� � ������� <setDryRun>.
isDryRun=0

# var: runCmd
# ���������� ������� ( � ������ <isDryRun> ����������� "echo", ����� ������
# ������).
# �������������� � ������� <setDryRun>.
runCmd=""



# group: ������������ ��������� ��������



# var: svnModuleRoot
# ���� � ��������� �������� ������ � Subversion ( ������� � �����������)
# ��������������� � ������� <getSvnModuleRoot>.
svnModuleRoot=""

# var: svnModuleRootUrl
# URL ��������� �������� ������ � Subversion.
# ��������������� � ������� <getSvnModuleRoot>.
svnModuleRootUrl=""

# var: svnModuleRootFilePath
# ���� � Subversion, �� �������� ���� �������� ����� ������ ( ������� � �����
# �����������).
# ��������������� � ������� <getSvnModuleRoot>.
svnModuleRootFilePath=""

# var: svnInitialPath
# �������������� ���� � ��������� �������� ������ � Subversion.
# ��������������� � ������� <getSvnInitialPath>.
svnInitialPath=""

# var: fileObjectName
# ��� ������� ��, �������� ������������� ����.
# ��������������� � ������� <getFileObject>.
#
fileObjectName=""

# var: fileObjectType
# ��� ������� ��, �������� ������������� ����.
# ��������������� � ������� <getFileObject>.
#
fileObjectType=""



# group: �������



# group: ����������� ���������



# func: isLogLevelEnabled
# ��������� ����������� ������ ��������� ���������� ������.
#
# ���������:
# messageLevel                - ������� ���������
#
# �������:
# 0 ���� ����� ��������, ����� 1.
#
isLogLevelEnabled()
{
  if [[ $1 -le $logLevel ]]; then
    return 0;
  else
    return 1;
  fi
}



# func: logMessage
# ������� ���������, ��������� � ����������� �������, � stderr.
#
# ���������:
# messageLevel                - ������� ���������
# messageText                 - ����� ���������
# ...                         - �������������� ����� ������ ���������
#
logMessage()
{
  local messageLevel=$1
  local messageText=$2
  shift 2
  if isLogLevelEnabled $messageLevel; then
    local outPrefix=""
    if (( messageLevel < DEBUG_LOG_LEVEL )); then
      outPrefix="$scriptName: "
    else
      outPrefix="OMS-DBG$(( messageLevel - DEBUG_LOG_LEVEL + 1 )): "
    fi
    echo "${outPrefix}${messageText}" "$@" >&2
  fi
}



# func: logError
# ������� ��������� �� ������.
#
# ���������:
# messageText                 - ����� ���������
# ...                         - �������������� ����� ������ ���������
#
logError()
{
  logMessage $ERROR_LOG_LEVEL "$@"
}



# func: logWarning
# ������� ��������������.
#
# ���������:
# messageText                 - ����� ���������
# ...                         - �������������� ����� ������ ���������
#
logWarning()
{
  logMessage $WARNING_LOG_LEVEL "$@"
}



# func: logDebug
# ������� ���������� ��������� 1-�� ������ �������.
#
# ���������:
# messageText                 - ����� ���������
# ...                         - �������������� ����� ������ ���������
#
logDebug()
{
  logMessage $DEBUG_LOG_LEVEL "$@"
}



# func: logDebug2
# ������� ���������� ��������� 2-�� ������ �������.
#
# ���������:
# messageText                 - ����� ���������
# ...                         - �������������� ����� ������ ���������
#
logDebug2()
{
  logMessage $DEBUG2_LOG_LEVEL "${FUNCNAME[1]}:" "$@"
}



# func: logDebug3
# ������� ���������� ��������� 3-�� ������ �������.
#
# ���������:
# messageText                 - ����� ���������
# ...                         - �������������� ����� ������ ���������
#
logDebug3()
{
  logMessage $DEBUG3_LOG_LEVEL "${FUNCNAME[1]}:" "$@"
}



# func: logInitDebugInfo
# ����� ��������� ���������� ����������.
logInitDebugInfo()
{
  logDebug "$scriptName: start: source='$0', rev. $scriptRevision" \
    "( common rev. $commonRevision)"
  logMessage $DEBUG2_LOG_LEVEL "script arguments[${#scriptArgumentList[@]}]:" \
    "${scriptArgumentList[@]}"
}



# group: ����� ���������



# func: printMessage
# ������� ��������� � stdout, �������� � �������� �������� ��� ������������
# �������.
#
# ���������:
# messageText                 - ����� ���������
# ...                         - �������������� ����� ������ ���������
#
printMessage()
{
  echo "${scriptName}:" "$@"
}



# group: ���������� ����������



# func: exitScript
# ��������� ���������� �������.
#
# ���������:
# exitCode                    - ��� ���������� ���������� ( �� ��������� 0)
#
exitScript()
{
  local exitCode="${1:-0}"
  logDebug "$scriptName: exit: $exitCode"
  exit $exitCode
}



# func: exitFatalError
# ������� ��������� � ����������� ������ � ��������� ���������� � ���������
# �����.
#
# ���������:
# exitCode                    - ��� ���������� ����������
# messageText                 - ����� ���������
# ...                         - �������������� ����� ������ ���������
#
exitFatalError()
{
  local exitCode=$1
  shift
  logDebug "Exit on fatal error ( exitCode=$exitCode):" "$@"
  logMessage $FATAL_LOG_LEVEL "$@"
  exit $exitCode;
}



# func: exitArgError
# ������� ��������� �� ������ � ��������� ���������� � ����� ������
# <E_ARG_ERROR>.
#
# ���������:
# messageText                 - ����� ���������
# ...                         - �������������� ����� ������ ���������
#
exitArgError()
{
  exitFatalError $E_ARG_ERROR "$@"
}



# func: exitError
# ������� ��������� �� ������ � ��������� ���������� � ����� ������
# <E_PROCESS_ERROR>.
#
# ���������:
# messageText                 - ����� ���������
# ...                         - �������������� ����� ������ ���������
#
exitError()
{
  exitFatalError $E_PROCESS_ERROR "$@"
}



# group: ��������� ���������� ������



# func: setDebugLevel
# ������������� ������� ������ ���������� ����������.
# ������� ������������ ��� ��������� ����������� ����� "--debug-level"
# ��������� ������.
#
# ��������:
# debugLevel                  - ������� ������� ( 1 �������������
#                               <DEBUG_LOG_LEVEL>, 2 ��� <DEBUG2_LOG_LEVEL>
#                               � �.�.)
#
# ���������:
# - ��������� �������� �������� ��� ������������� ��������, ��� ���� �������
#   ����� �������� ( 0 ��� <INFO_LOG_LEVEL>, -1 ��� <WARNING_LOG_LEVEL>
#   � �.�.);
# - � ������ ��������� ���������� ��������� ���������� �������
#   <logInitDebugInfo> ��� ������ ��������� ���������� ����������;
#
setDebugLevel()
{
  local debugLevel=$1
  local logLevelOld=$logLevel
  logLevel=$(( DEBUG_LOG_LEVEL - 1 + debugLevel ))
                                        # ����� ��������� ���������� ����������
  if (( logLevel >= DEBUG_LOG_LEVEL && logLevelOld < DEBUG_LOG_LEVEL )); then
    logInitDebugInfo
  fi
  logDebug3 "Set logLevel: $logLevel ( debug level: $debugLevel)"
}



# func: setDryRun
# ������������� ����� "���������" �������, ����� ������ �������� ���������
# ��������� ����� ������, ������� ������ ���� ���� ���������.
#
# ���������:
# - � ���������� ���������� ������� ������������ �������� ���������� <isDryRun>
#   � <runCmd>, ������� ������ �������������� � �������� ��� ��� ������ ������
#   ������ ������ �� ����������;
#
setDryRun()
{
  isDryRun=1
  runCmd="echo"
  logDebug3 "Set isDryRun: $isDryRun"
}



# func: showVersion
# ������� ���������� � ������.
#
showVersion()
{
  cat <<END
$scriptName (OMS) $OMS_VERSION
OMS Version Information:
  Module root               : $omsSvnRoot
  File revision             : $scriptRevision
  File change date          : $scriptChangeDate
  oms-common.sh revision    : $commonRevision
  oms-common.sh change date : $commonChangeDate
END
}



# group: ���������� �� Subversion



# func: getSvnModuleRoot
# ���������� URL � ���� � ��������� �������� ������ � Subversion.
#
# ���������:
# modulePath                  - ��������� ���� � ��������� �������� ������
#
# �������:
# <svnModuleRoot>             - ���� � ��������� �������� ������ � Subversion
#                               ( ������� � ����� �����������)
# <svnModuleRootFilePath>     - ���� � Subversion, �� �������� ���� ��������
#                               ����� ������ ( ������� � ����� �����������)
# <svnModuleRootUrl>          - URL ��������� �������� ������ � Subversion
#
getSvnModuleRoot()
{
  local modulePath="$1"
  logDebug3 "start: modulePath='$modulePath'"
  local svnPath=""
  local svnRootUrl=""
  local svnRoot=""
  local svnInfo=$($svnCmd info --xml "$modulePath" 2>/dev/null)
  if (( ! $? )) ; then
    svnRootUrl=${svnInfo#*<url>}

    # ���������, ��� ��� <url> ��� ������
    if [[ $svnRootUrl != $svnInfo ]]; then
      svnRootUrl=${svnRootUrl%%</url>*}
      svnPath=${svnRootUrl#svn://*/}
      svnRootUrl=${svnRootUrl%/Trunk}
      svnRoot=${svnRootUrl#svn://*/}
    fi
  fi

  # ������� ��������
  svnModuleRootFilePath=$svnPath
  svnModuleRootUrl=$svnRootUrl
  svnModuleRoot=$svnRoot
  logDebug2 "Set svnModuleRootFilePath: '$svnModuleRootFilePath'"
  logDebug2 "Set svnModuleRootUrl: '$svnModuleRootUrl'"
  logDebug2 "Set svnModuleRoot: '$svnModuleRoot'"
}



# func: getSvnInitialPath
# ���������� �������������� ���� � ��������� �������� ������ � Subversion.
#
# ���������:
# rootUrl                     - URL ��������� �������� ������
#
# �������:
# <svnInitialPath>            - �������������� ���� � ��������� �������� ������
#                               ( ������� ����� ������, � ������� �� ��� ������,
#                               ��������, "Oracle/Module/OraMakeSystem@350")
#
# ���������:
# - �������������� ���� ������������ ������ �� �������� �����������, ��������
#   ����� ������������� �� �����������;
#
getSvnInitialPath()
{
  local rootUrl="$1"
  logDebug3 "start: rootUrl='$rootUrl'"
  local initialPath=""
  local firstLog=$($svnCmd log -r 1:HEAD --limit 1 --xml "$rootUrl")
  if (( $? == 0 )); then
    local initialRevision=${firstLog#*revision=\"}
    initialRevision=${initialRevision%%\"*}
    logDebug3 "Set initialRevision: $initialRevision"
    local initialInfo=$($svnCmd info -r "$initialRevision" --xml "$rootUrl")
    if (( $? == 0 )); then
      initialPath=${initialInfo#*<url>svn://*/}
      initialPath="${initialPath%%</url>*}@${initialRevision}"
    fi
  fi
                                        # ������� ��������
  svnInitialPath=$initialPath
  logDebug2 "Set svnInitialPath: '$svnInitialPath'"
}



# group: ������



# func: getFileObject
# ���������� ��� � ��� ������� ��, �������� ������������� ����.
# ��������� ������������ �� ��������� ����������� ����������
# <fileExtensionList>.
#
# ���������:
# filePath                    - ���� � �����
#
# �������:
# <fileObjectName>            - ��� ������� � ��
# <fileObjectType>            - ��� ������� � ��
#
getFileObject()
{
  local filePath="$1"
  logDebug3 "start: filePath='$filePath'"
  local fileName=${filePath##*/}
  local baseName=${fileName%.*}
  fileObjectName=""
  fileObjectType=""
  local item
  for item in "${fileExtensionList[@]}"; do
    case $fileName in
      *.${item%%:*})
        item=${item#*:}
        fileObjectType=${item%%:*}
        item=${item#*:}
        if [[ ${item%%:*} == u ]]; then
          fileObjectName=$(echo "$baseName" | tr "[:lower:]" "[:upper:]")
        else
          fileObjectName=$baseName
        fi
        break
        ;;
    esac
  done
  logDebug2 "Set fileObjectName: '$fileObjectName'"
  logDebug2 "Set fileObjectType: '$fileObjectType'"
}



# func: getSvnInitialPath
# ���������� �������������� ���� � ��������� �������� ������ � Subversion.
#
# ���������:
# rootUrl                     - URL ��������� �������� ������
#
# �������:
# <svnInitialPath>            - �������������� ���� � ��������� �������� ������
#                               ( ������� ����� ������, � ������� �� ��� ������,
#                               ��������, "Oracle/Module/OraMakeSystem@350")
#
# ���������:
# - �������������� ���� ������������ ������ �� �������� �����������, ��������
#   ����� ������������� �� �����������;
#
getSvnInitialPath()
{
  local rootUrl="$1"
  logDebug3 "start: rootUrl='$rootUrl'"
  local initialPath=""
  local firstLog=$($svnCmd log -r 1:HEAD --limit 1 --xml "$rootUrl")
  if (( $? == 0 )); then
    local initialRevision=${firstLog#*revision=\"}
    initialRevision=${initialRevision%%\"*}
    logDebug3 "Set initialRevision: $initialRevision"
    local initialInfo=$($svnCmd info -r "$initialRevision" --xml "$rootUrl")
    if (( $? == 0 )); then
      initialPath=${initialInfo#*<url>svn://*/}
      initialPath="${initialPath%%</url>*}@${initialRevision}"
    fi
  fi
                                        # ������� ��������
  svnInitialPath=$initialPath
  logDebug2 "Set svnInitialPath: '$svnInitialPath'"
}


                                        # ����� ��������� ���������� ����������
logInitDebugInfo
