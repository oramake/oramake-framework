#!/bin/bash
# Экспорт данных
# Перед запуском скрипта необходимо создать директорию в Oracle, в которой будут храниться дампы
# и сохранить ее значение в переменную среды ORACLE_DUMP_DIR
#
# func: usage
# Выводит информацию об опциях для вызова скрипта
#
usage() {
  cat <<END
Integrate set of packages into application environment.

Usage:
  $(baseName $0) [options]

Options:
  --login | -l               - login/password@db
  --schema | -s              - exported schema
  --dumpfile | -d            - dump file path in Oracle directories
  --logfile | -lg            - log file path in Oracle directories
  --help | -h                - show this help
END
}

  if [[ ! -z "$@" ]]; then
    while [[ $# -ne 0 ]]; do
      case "$1" in
        --login | -l )
          pLogin="$2"
          shift
          ;;
        --schema | -s )
          pSchema="$2"
		  shift
          ;;
        --dumpfile | -d )
          pDumpFile="$2"
		  shift
          ;;
        --logfile | -lg )
          pLogFile="$2"
          shift
          ;;
        --help | -h )
          usage
          exit 0
          ;;
        * )
          echo "Illegal argument: $1"
          exit 11
          ;;
      esac
      shift
    done
  else
    usage
    exit
  fi

  if [[ -z "$pLogin" ]]; then
    echo "Error: Login is not specified!"
    exit 11
  elif [[ -z "$pSchema" ]]; then
    echo "Error: Schema is not specified!"
    exit 11
  elif [[ -z "$pDumpFile" ]]; then
    echo "Error: Dump file is not specified!"
    exit 11
  elif [ -z "$pLogFile" ]; then
   pLogFile="$pSchema.log"
  fi

echo "login=$pLogin"
echo "schemas=$pSchema"
echo "dump directory=$ORACLE_DUMP_DIR"
echo "dump file=$pDumpFile"
echo "log file=expdp$pLogFile"


expdp $pLogin schemas=$pSchema directory=$ORACLE_DUMP_DIR dumpfile=$pDumpFile logfile=$pLogFile