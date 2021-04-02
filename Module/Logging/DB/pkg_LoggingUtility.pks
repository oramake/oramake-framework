create or replace package pkg_LoggingUtility is
/* package: pkg_LoggingUtility
  �������������� ������� ������ Logging ��� ������������� � ������ �������.

  SVN root: Oracle/Module/Logging
*/



/* group: ������� */

/* pfunc: clearLog
  ������� ������ ����.

  ���������:
  toTime                      - �����, �� �������� ����� ������� ����
                                (�� �������)

  �������:
  ����� ��������� �������

  ( <body::clearLog>)
*/
function clearLog(
  toTime timestamp with time zone
)
return integer;

end pkg_LoggingUtility;
/
