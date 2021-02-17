# script: Java/load-java-lib.sh
# �������� jar-����� � �� � �������������� ���������� �������, �� �������
# ������� ����������� ����.
#
# ���������:
# $1                         - ��� �����
# $2                         - ������������� ���������� c Oracle
#                              ( � ������� � ???/???@???);

loadFile=$1
connectUid=$2

echo "* loading $loadFile ..."

loadjava.bat -u $connectUid \
  $loadFile \
  -resolve \
  -resolver \
  "((* ${connectUid/%\/*/}) (* PUBLIC) (* -))"

echo "* Java archive loaded"
