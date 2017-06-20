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

# var: cslGetPasswordCmd
# ������ ���� � ��������� ��������� ������
cslGetPasswordCmd=""



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

  # ���������� ��������� ��������� ������
  if [[ -z "$cslGetPasswordCmd" ]]; then
    cslGetPasswordCmd=`which $cslGetPasswordScript 2>/dev/null`
    if (( $? )); then
      cslGetPasswordCmd=`which $cslGetPasswordScriptAlias 2>/dev/null`
      if (( $? )); then
        cslGetPasswordCmd=" "
      fi
    fi
  fi
  if [[ -x "$cslGetPasswordCmd" ]]; then
    # ����������� ������
    cslPassword=`$cslGetPasswordCmd "$1"`
    if (( $? )); then
      cslPassword=""
    fi
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
