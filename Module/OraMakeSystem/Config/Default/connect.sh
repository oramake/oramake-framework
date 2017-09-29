#!/bin/bash

# script: connect.sh
# ���������� ������, ���������� ����������� ������� ��� ����������, �������
# ����� ���������������� ����� ���������.
#
# ���������� �� ����������:
# - ������������ �� ������ �������� ����� ( �������, ����������) ������
#   ���������� � �������� "csp" ( "custom public");
# - ��������� ����� ( ����� ��������� ����������) ������ ���������� �
#   �������� "csl" ( "custom local");
#
# ����������� ������� ������� � ��������� ������� ������ ����������� �
# ����� ����������� ������� <oms-common.sh> � ������� ������� "source" ���
# �������� ���������� �������:
#
# (code)
#
# source ${configDir}/connect.sh || exit 12
#
# (end)
#



# group: ����������� ���������

# var: cslGetPasswordScript
# ��� ��������� ( �������) ��� ��������� ������.
cslGetPasswordScript="${GET_PASSWORD:-get-password}"

# var: cslGetPasswordScriptAlias
# ����� ������� ��������� ������
cslGetPasswordScriptAlias="${cslGetPasswordScript}.bat"

# var: cslGetOperatorPasswordHost
# ����, ������������ ��� ������������ URL ��� ��������� ������ ���������
# � ������� <cspGetOperatorPassword>.
cslGetOperatorPasswordHost="info"



# group: ����������

# var: cslPassword
# ������, ������������ �������� cslGetPassword.
cslPassword=""



# group: ��������� �������


# func: cslGetPassword
# �������� �������� ������ ��� URL � ������� ������ ������� ���������.
#
# ���������:
# $1                    - URL ��� �������� ����� ������
#
# �������:
# cslPassword           - ������ ( ���� �������, �� ������)
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



# group: ��������� �������



# func: cspGetDefaultUserName
# ���������� ��� ������������ �� ��������� ��� ��.
#
# ���������:
# $1                    - ��� �� ( � ������ ��������)
#
# �������:
# userName              - ��� ������������
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
# ���������� ������ ������������ ��.
#
# ���������:
# $1                    - ��� �� ( � ������ ��������)
# $2                    - ��� ������������
#
# �������:
# userPassword          - ������ ������������ ( ������ ������, ����
#                         �� ������� ��������)
#
# ���������:
# - ��� ��������� ������ ���������� ������� <cslGetPassword> ��� URL ����
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
# ���������� ������ ���������.
#
# ���������:
# $1                    - ��� ���������
#
# �������:
# userPassword          - ������ ��������� ( ������ ������, ����
#                         �� ������� ��������)
#
# ���������:
# - ��� ��������� ������ ���������� ������� <cslGetPassword> ��� URL ����
#   "http://<operatorName>@<host>" ( host �� <cslGetOperatorPasswordHost>);
#
cspGetOperatorPassword()
{
  local operatorName="$1"
  cslGetPassword "http://${operatorName}@${cslGetOperatorPasswordHost}"
  operatorPassword="$cslPassword"
}
