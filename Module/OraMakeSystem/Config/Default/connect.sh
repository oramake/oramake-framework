#!/bin/bash

# script: connect.sh
# Внутренний скрипт, содержащий настроечные функции для соединения, которые
# могут модифицироваться после установки.
#
# Соглашения по именованию:
# - используемые из других скриптов имена ( функций, переменных) должны
#   начинаться с префикса "csp" ( "custom public");
# - остальные имена ( кроме локальных переменных) должны начинаться с
#   префикса "csl" ( "custom local");
#
# Подключение данного скрипта к основному скрипту должно выполняться с
# после подключения скрипта <oms-common.sh> с помощью команды "source" без
# указания аргументов скрипта:
#
# (code)
#
# source ${configDir}/connect.sh || exit 12
#
# (end)
#



# group: Настроечные параметры

# var: cslGetPasswordScript
# Имя программы ( скрипта) для получения пароля.
cslGetPasswordScript="${GET_PASSWORD:-get-password}"

# var: cslGetPasswordScriptAlias
# Алиас скрипта получения пароля
cslGetPasswordScriptAlias="${cslGetPasswordScript}.bat"

# var: cslGetOperatorPasswordHost
# Хост, используемый при формировании URL для получения пароля оператора
# в функции <cspGetOperatorPassword>.
cslGetOperatorPasswordHost="info"



# group: Переменные

# var: cslPassword
# Пароль, определенный функцией cslGetPassword.
cslPassword=""



# group: Локальные функции


# func: cslGetPassword
# Пытается получить пароль для URL с помощью вызова внешней программы.
#
# Параметры:
# $1                    - URL для которого нужен пароль
#
# Возврат:
# cslPassword           - пароль ( если неудача, то пустой)
#
cslGetPassword()
{
  cslPassword=""
  local passwdScript=""

  if [[ "$OSTYPE" == "msys" ]] && [[ -n "$OMS_SRC_PATH" ]]; then
    cslPassword=`
      export PATH=$(cygpath --path --unix "$OMS_SRC_PATH");
      passwdScript=$(type -p "$cslGetPasswordScript") || \
        passwdScript=$(type -p "$cslGetPasswordScriptAlias")
      if [[ -n "$passwdScript" ]]; then
        bashCmd=$(type -p "bash")
        if [[ -n "$bashCmd" ]]; then
          $bashCmd -c "$passwdScript \"$1\""
        else
          $passwdScript "$1"
        fi
      fi
      `
  else
    passwdScript=$(type -p "$cslGetPasswordScript") || \
      passwdScript=$(type -p "$cslGetPasswordScriptAlias")
    if [[ -n "$passwdScript" ]]; then
      cslPassword=`$passwdScript "$1"`
    fi
  fi
  if (( $? )); then
    cslPassword=""
  fi
}



# group: Публичные функции



# func: cspGetDefaultUserName
# Определяет имя пользователя по умолчанию для БД.
#
# Параметры:
# $1                    - имя БД ( в нижнем регистре)
#
# Возврат:
# userName              - имя пользователя
#
cspGetDefaultUserName()
{
  local user=""
  case "$1" in
    testdb?                 ) user="main";;
    *                       ) user="operation";;
  esac
  userName="$user"
}



# func: cspGetUserPassword
# Возвращает пароль пользователя БД.
#
# Параметры:
# $1                    - имя БД ( в нижнем регистре)
# $2                    - имя пользователя
#
# Возврат:
# userPassword          - пароль пользователя ( пустая строка, если
#                         не удалось получить)
#
# Замечания:
# - для получения пароля вызывается функция <cslGetPassword> для URL вида
#   "oracle://<userName>@<dbName>";
#
cspGetUserPassword()
{
  local dbName="$1"
  local userName="$2"
  cslGetPassword "oracle://${userName}@${dbName}"
  userPassword="$cslPassword"
}



# func: cspGetOperatorPassword
# Возвращает пароль оператора.
#
# Параметры:
# $1                    - имя оператора
#
# Возврат:
# userPassword          - пароль оператора ( пустая строка, если
#                         не удалось получить)
#
# Замечания:
# - для получения пароля вызывается функция <cslGetPassword> для URL вида
#   "http://<operatorName>@<host>" ( host из <cslGetOperatorPasswordHost>);
#
cspGetOperatorPassword()
{
  local operatorName="$1"
  cslGetPassword "http://${operatorName}@${cslGetOperatorPasswordHost}"
  operatorPassword="$cslPassword"
}
