# script: Java/drop-java-lib.sh
# Удаление jar-файла из БД.
#
# Параметры:
# $1                         - имя файла
# $2                         - идентификатор соединения c Oracle
#                              ( в формате в ???/???@???);

loadFile=$1
connectUid=$2

echo "* Dropping $loadFile ..."

dropjava.bat -u $connectUid \
  $loadFile

echo "* Java archive dropped"
