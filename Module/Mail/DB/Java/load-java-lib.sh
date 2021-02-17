# script: Java/load-java-lib.sh
# Загрузка jar-файла в БД с игнорированием отсутствия классов, от которых
# зависит загружаемый файл.
#
# Параметры:
# $1                         - имя файла
# $2                         - идентификатор соединения c Oracle
#                              ( в формате в ???/???@???);

loadFile=$1
connectUid=$2

echo "* loading $loadFile ..."

loadjava.bat -u $connectUid \
  $loadFile \
  -resolve \
  -resolver \
  "((* ${connectUid/%\/*/}) (* PUBLIC) (* -))"

echo "* Java archive loaded"
