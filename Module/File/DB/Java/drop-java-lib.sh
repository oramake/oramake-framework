# script: Java/drop-java-lib.sh
# �������� jar-����� �� ��.
#
# ���������:
# $1                         - ��� �����
# $2                         - ������������� ���������� c Oracle
#                              ( � ������� � ???/???@???);

loadFile=$1
connectUid=$2

echo "* Dropping $loadFile ..."

dropjava.bat -u $connectUid \
  $loadFile

echo "* Java archive dropped"
