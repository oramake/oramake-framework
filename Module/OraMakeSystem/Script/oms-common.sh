#!/bin/bash

# script: oms-common.sh
# Внутренний скрипт, содержащий константы, переменные и функции, используемые
# в shell-скриптах.
#
# Подключение данного скрипта к основному скрипту должно выполняться с
# помощью команды "." без указания аргументов скрипта:
#
# (code)
#
# source oms-common.sh || exit 11
#
# (end)
#
# При этом предварительно должны быть определены и инициализированы
# переменные:
#
# OMS_VERSION                 - версия программы
#
# fileRevisionValue           - строка с номером последней правки, в которой
#                               был изменен файл основного скрипта
#
# fileChangeDateValue         - строка с датой последнего изменения файла
#                               основного скрипта
#



# group: Переменные



# group: Информация о версии

# Обеспечивает изменение файла при изменении версии программы.
# В функциях используется переменная OMS_VERSION из основного скрипта.
:<<END
OMS_VERSION=2.2.0
END

# var: omsSvnRoot
# Путь к корневому каталогу OMS в Subversion ( начиная с имени репозитария).
omsSvnRoot='Oracle/Module/OraMakeSystem'

# var: omsInitialSvnPath
# Первоначальный путь к корневому каталогу OMS в Subversion ( начиная с имени
# репозитария и с указанием номера правки, в которой был создан каталог).
omsInitialSvnPath='Oracle/Module/OraMakeSystem@633'

# var: commonRevisionValue
# Строка с номером последней правки, в которой был изменен файл
commonRevisionValue='$Revision:: 26037021 $'

# var: commonChangeDateValue
# Строка с последней датой изменения файла
commonChangeDateValue='$Date:: 2019-07-04 09:21:56 +0300 #$'


# var: commonRevision
# Номер последней правки, в которой был изменен файл.
commonRevision=$(( ${commonRevisionValue:12:${#commonRevisionValue}-13} ))

# var: commonChangeDate
# Дата последнего изменения файла.
commonChangeDate=${commonChangeDateValue:8:26}



# group: Коды ошибок

# var: E_FALSE_RESULT
# Код возврата в случае отрицательного результата выполнения.
E_FALSE_RESULT=1

# var: E_ARG_ERROR
# Код ошибки из-за неверных агрументов.
E_ARG_ERROR=10

# var: E_PROCESS_ERROR
# Код ошибки обработки
E_PROCESS_ERROR=11



# group: Уровни логируемых сообщений

# var: FATAL_LOG_LEVEL
# Сообщение о критической ошибке, вызывающей аварийное завершение выполнения.
FATAL_LOG_LEVEL=1

# var: ERROR_LOG_LEVEL
# Сообщение об ошибке.
ERROR_LOG_LEVEL=2

# var: WARNING_LOG_LEVEL
# Предупреждение.
WARNING_LOG_LEVEL=3

# var: INFO_LOG_LEVEL
# Информационное сообщение.
INFO_LOG_LEVEL=4

# var: DEBUG_LOG_LEVEL
# Отладочное сообщение 1-го уровня.
DEBUG_LOG_LEVEL=5

# var: DEBUG2_LOG_LEVEL
# Отладочное сообщение 2-го уровня.
DEBUG2_LOG_LEVEL=6

# var: DEBUG3_LOG_LEVEL
# Отладочное сообщение 3-го уровня.
DEBUG3_LOG_LEVEL=7



# group: Исполняемый скрипт

# var: scriptName
# Имя основного скрипта ( без пути).
scriptName=${0##*/}

# var: scriptRevision
# Номер последней правки, в которой был изменен файл основного скрипта.
# Значение определяется по переменной <fileRevisionValue>, которая должна
# быть объявлена и инициализирована в основном скрипте.
scriptRevision=$(( ${fileRevisionValue:12:${#fileRevisionValue}-13} ))

# var: scriptChangeDate
# Дата последнего изменения файла основного скрипта.
# Значение определяется по переменной <fileChangeDateValue>, которая должна
# быть объявлена и инициализирована в основном скрипте.
scriptChangeDate=${fileChangeDateValue:8:26}

# var: scriptArgumentList
# Параметры вызова скрипта ( сохраняются для отладки)
scriptArgumentList=( "$@" )



# group: Настроечные параметры

# var: svnCmd
# Исполняемый файл Subversion.
svnCmd="svn"

# var: installShareDir
# Путь к каталогу с данными OMS ( за исключением скриптов и настроек)
installShareDir="${OMS_INSTALL_SHARE_DIR:-/usr/local/share/oms}"

# var: sqlScriptDir
# Каталог со стандартными SQL-скриптами
sqlScriptDir="${installShareDir}/SqlScript"

# var: configDir
# Каталог с настройками.
configDir="${OMS_CONFIG_DIR:-/usr/local/etc/oms}"

# var: templateDir
# Каталог с шаблоном нового модуля.
templateDir="${installShareDir}/Data/NewModule"

# var: templatePackageName
# Базовое имя ( без расширения) файлов с шаблоном пакета Oracle.
templatePackageName="pkg_NewModule"

# var: patchConfigDir
# Настроечный каталог с патчами для обновления файлов модуля.
patchConfigDir="$configDir/UpdateModule"

# var: moduleOmsDir
# Каталог с файлами OMS внутри прикладного модуля.
moduleOmsDir="DB/OmsModule"

# var: tmpFileDir
# Каталог для временных файлов
tmpFileDir="${TEMP:-/tmp}"

# var: tmpFile
# Временный файл для использования в скрипте.
tmpFile="${tmpFileDir}/${scriptName}.$$"

# var: fileExtensionList
# Список настроек по расширениям файлов ( в соответствии с соглашениями
# <Файлы>).
# Формат элемента списка: последовательность полей с разделитем двоеточие.
# Поля элемента списка:
# - расширение файла ( без точки)
# - соответствующий тип объекта в БД ( если есть)
# - способ получения имени объекта в БД по имени файла без расширения
#   ( по умолчанию точное соответствие, "u" перевод в верхний регистр)
#
# Замечания:
# - значение переменной передается SQL-скриптам через oms_file_extension_list
#   ( с разделителем элементов запятая) и используется в скрипте <oms-run.sql>;
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


# group: Параметры вызова



# var: logLevel
# Уровень вывода сообщений о выполнении скрипта.
# Может быть изменен с помощью опции --debug-level.
logLevel=$(( INFO_LOG_LEVEL + ${OMS_DEBUG_LEVEL:-0} ))

# var: isDryRun
# Признак тестового запуска ( только печать команд без выполнения).
# Устаналивается в функции <setDryRun>.
isDryRun=0

# var: runCmd
# Выполнение команды ( в случае <isDryRun> указывается "echo", иначе пустая
# строка).
# Устаналивается в функции <setDryRun>.
runCmd=""



# group: Возвращаемые функциями значения



# var: svnModuleRoot
# Путь к корневому каталогу модуля в Subversion ( начиная с репозитария)
# Устанавливается в функции <getSvnModuleRoot>.
svnModuleRoot=""

# var: svnModuleRootUrl
# URL корневого каталога модуля в Subversion.
# Устанавливается в функции <getSvnModuleRoot>.
svnModuleRootUrl=""

# var: svnModuleRootFilePath
# Путь в Subversion, из которого были получены файлы модуля ( начиная с имени
# репозитария).
# Устанавливается в функции <getSvnModuleRoot>.
svnModuleRootFilePath=""

# var: svnInitialPath
# Первоначальный путь к корневому каталогу модуля в Subversion.
# Устанавливается в функции <getSvnInitialPath>.
svnInitialPath=""

# var: fileObjectName
# Имя объекта БД, которому соответствует файл.
# Устанавливается в функции <getFileObject>.
#
fileObjectName=""

# var: fileObjectType
# Тип объекта БД, которому соответствует файл.
# Устанавливается в функции <getFileObject>.
#
fileObjectType=""

# var: moduleGendocEncoding
# Encoding of module's documentation ( enconding name for iconv)
# Is set in <getModuleGendocEncoding>.
moduleGendocEncoding=""



# group: Функции



# group: Логирование сообщений



# func: isLogLevelEnabled
# Проверяет возможность вывода сообщения указанного уровня.
#
# Параметры:
# messageLevel                - уровень сообщения
#
# Возврат:
# 0 если вывод разрешен, иначе 1.
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
# Выводит сообщение, связанное с выполнением скрипта, в stderr.
#
# Параметры:
# messageLevel                - уровень сообщения
# messageText                 - текст сообщения
# ...                         - дополнительные части текста сообщения
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
# Выводит сообщение об ошибке.
#
# Параметры:
# messageText                 - текст сообщения
# ...                         - дополнительные части текста сообщения
#
logError()
{
  logMessage $ERROR_LOG_LEVEL "$@"
}



# func: logWarning
# Выводит предупреждение.
#
# Параметры:
# messageText                 - текст сообщения
# ...                         - дополнительные части текста сообщения
#
logWarning()
{
  logMessage $WARNING_LOG_LEVEL "$@"
}



# func: logDebug
# Выводит отладочное сообщение 1-го уровня отладки.
#
# Параметры:
# messageText                 - текст сообщения
# ...                         - дополнительные части текста сообщения
#
logDebug()
{
  logMessage $DEBUG_LOG_LEVEL "$@"
}



# func: logDebug2
# Выводит отладочное сообщение 2-го уровня отладки.
#
# Параметры:
# messageText                 - текст сообщения
# ...                         - дополнительные части текста сообщения
#
logDebug2()
{
  logMessage $DEBUG2_LOG_LEVEL "${FUNCNAME[1]}:" "$@"
}



# func: logDebug3
# Выводит отладочное сообщение 3-го уровня отладки.
#
# Параметры:
# messageText                 - текст сообщения
# ...                         - дополнительные части текста сообщения
#
logDebug3()
{
  logMessage $DEBUG3_LOG_LEVEL "${FUNCNAME[1]}:" "$@"
}



# func: logInitDebugInfo
# Вывод стартовой отладочной информации.
logInitDebugInfo()
{
  logDebug "$scriptName: start: source='$0', rev. $scriptRevision" \
    "( common rev. $commonRevision)"
  logMessage $DEBUG2_LOG_LEVEL "script arguments[${#scriptArgumentList[@]}]:" \
    "${scriptArgumentList[@]}"
}



# group: Вывод сообщений



# func: printMessage
# Выводит сообщение в stdout, добавляя в качестве префикса имя выполняемого
# скрипта.
#
# Параметры:
# messageText                 - текст сообщения
# ...                         - дополнительные части текста сообщения
#
printMessage()
{
  echo "${scriptName}:" "$@"
}



# group: Завершение выполнения



# func: exitScript
# Завершает выполнение скрипта.
#
# Параметры:
# exitCode                    - код завершения выполнения ( по умолчанию 0)
#
exitScript()
{
  local exitCode="${1:-0}"
  logDebug "$scriptName: exit: $exitCode"
  exit $exitCode
}



# func: exitFatalError
# Выводит сообщение о критической ошибке и завершает выполнение с указанным
# кодом.
#
# Параметры:
# exitCode                    - код завершения выполнения
# messageText                 - текст сообщения
# ...                         - дополнительные части текста сообщения
#
exitFatalError()
{
  local exitCode=$1
  shift
  logDebug "Exit on fatal error ( exitCode=$exitCode):" "$@"
  if (( $# )); then
    logMessage $FATAL_LOG_LEVEL "$@"
  fi
  exit $exitCode;
}



# func: exitArgError
# Выводит сообщение об ошибке и завершает выполнение с кодом ошибки
# <E_ARG_ERROR>.
#
# Параметры:
# messageText                 - текст сообщения
# ...                         - дополнительные части текста сообщения
#
exitArgError()
{
  exitFatalError $E_ARG_ERROR "$@"
}



# func: exitError
# Выводит сообщение об ошибке и завершает выполнение с кодом ошибки
# <E_PROCESS_ERROR>.
#
# Параметры:
# messageText                 - текст сообщения
# ...                         - дополнительные части текста сообщения
#
exitError()
{
  exitFatalError $E_PROCESS_ERROR "$@"
}



# group: Обработка аргументов вызова



# func: setDebugLevel
# Устанавливает уровень вывода отладочной информации.
# Функция используется для обработки стандартной опции "--debug-level"
# командной строки.
#
# Параметр:
# debugLevel                  - уровень отладки ( 1 соответствует
#                               <DEBUG_LOG_LEVEL>, 2 для <DEBUG2_LOG_LEVEL>
#                               и т.д.)
#
# Замечания:
# - допустимо указание нулевого или отрицательных значений, при этом уровень
#   будет уменьшен ( 0 для <INFO_LOG_LEVEL>, -1 для <WARNING_LOG_LEVEL>
#   и т.д.);
# - в случае включения отладочных сообщений вызывается функция
#   <logInitDebugInfo> для вывода стартовой отладочной информации;
#
setDebugLevel()
{
  local debugLevel=$1
  local logLevelOld=$logLevel
  logLevel=$(( DEBUG_LOG_LEVEL - 1 + debugLevel ))
                                        # Вывод стартовой отладочной информации
  if (( logLevel >= DEBUG_LOG_LEVEL && logLevelOld < DEBUG_LOG_LEVEL )); then
    logInitDebugInfo
  fi
  logDebug3 "Set logLevel: $logLevel ( debug level: $debugLevel)"
}



# func: setDryRun
# Устанавливает режим "холостого" запуска, когда вместо внесения изменений
# выводится текст команд, которые должны были быть выполнены.
#
# Замечания:
# - в результате выполнения функции выставляются значения переменным <isDryRun>
#   и <runCmd>, которые должны использоваться в скриптах при для вывода текста
#   команд вместо их выполнения;
#
setDryRun()
{
  isDryRun=1
  runCmd="echo"
  logDebug3 "Set isDryRun: $isDryRun"
}



# func: showVersion
# Выводит информацию о версии.
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



# group: Информация из Subversion



# func: getSvnModuleRoot
# Определяет URL и путь к корневому каталогу модуля в Subversion.
#
# Параметры:
# modulePath                  - локальный путь к корневому каталогу модуля
#
# Возврат:
# <svnModuleRoot>             - путь к корневому каталогу модуля в Subversion
#                               ( начиная с имени репозитария)
# <svnModuleRootFilePath>     - путь в Subversion, из которого были получены
#                               файлы модуля ( начиная с имени репозитария)
# <svnModuleRootUrl>          - URL корневого каталога модуля в Subversion
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

    # Проверяем, что тэг <url> был найден
    if [[ $svnRootUrl != $svnInfo ]]; then
      svnRootUrl=${svnRootUrl%%</url>*}
      svnPath=$svnRootUrl
      svnPath=${svnPath#svn://*/}
      svnPath=${svnPath#http://*/}
      svnPath=${svnPath#https://*/}
      svnRootUrl=${svnRootUrl%/Trunk}
      svnRoot=$svnRootUrl
      svnRoot=${svnRoot#svn://*/}
      svnRoot=${svnRoot#http://*/}
      svnRoot=${svnRoot#https://*/}
    fi
  fi

  # Возврат значения
  svnModuleRootFilePath=$svnPath
  svnModuleRootUrl=$svnRootUrl
  svnModuleRoot=$svnRoot
  logDebug2 "Set svnModuleRootFilePath: '$svnModuleRootFilePath'"
  logDebug2 "Set svnModuleRootUrl: '$svnModuleRootUrl'"
  logDebug2 "Set svnModuleRoot: '$svnModuleRoot'"
}



# func: getSvnInitialPath
# Определяет первоначальный путь к корневому каталогу модуля в Subversion.
#
# Параметры:
# rootUrl                     - URL корневого каталога модуля
#
# Возврат:
# <svnInitialPath>            - первоначальный путь к корневому каталогу модуля
#                               ( включая номер правки, в которой он был создан,
#                               например, "Oracle/Module/OraMakeSystem@350")
#
# Замечания:
# - первоначальный путь определяется только по текущему репозитарию, переносы
#   между репозитариями не учитываются;
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
      initialPath=$initialInfo
      # Для симметрии дальше работаем с initialPath
      initialPath=${initialPath#*<url>svn://*/}
      initialPath=${initialPath#*<url>http://*/}
      initialPath=${initialPath#*<url>https://*/}
      initialPath="${initialPath%%</url>*}@${initialRevision}"
    fi
  fi
  # Возврат значения
  svnInitialPath=$initialPath
  logDebug2 "Set svnInitialPath: '$svnInitialPath'"
  # Проверка, что svnInitialPath - одна строка
  if (( $(expr index "$svnInitialPath" $'\n') != 0 )); then
    exitError "svnInitialPath contains a line end"
  fi
}



# group: Другие



# func: getFileObject
# Определяет имя и тип объекта БД, которому соответствует файл.
# Результат определяется на основании настроечной переменной
# <fileExtensionList>.
#
# Параметры:
# filePath                    - путь к файлу
#
# Возврат:
# <fileObjectName>            - имя объекта в БД
# <fileObjectType>            - тип объекта в БД
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



# func: getModuleGendocEncoding
# Returns encoding of module's documentation.
#
# Parameters:
# modulePath                  - Path to root directory of module
#                               ( empty string for new module)
#
# Return:
# <moduleGendocEncoding>      - Encoding of module's documentation
#                               ( enconding name for iconv)
#
getModuleGendocEncoding()
{
  local modulePath="$1"
  logDebug3 "start: modulePath='$modulePath'"

  # return value
  moduleGendocEncoding="cp1251"
  logDebug2 "Set moduleGendocEncoding: '$moduleGendocEncoding'"
}



# Вывод стартовой отладочной информации
logInitDebugInfo
