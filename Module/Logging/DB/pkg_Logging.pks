create or replace package pkg_Logging is
/* package: pkg_Logging
  ������������ ����� ������ Logging.

  SVN root: Oracle/Module/Logging
*/



/* group: ��������� */

/* const: Module_Name
  �������� ������, � �������� ��������� �����.
*/
Module_Name constant varchar2(30) := 'Logging';



/* group: ������ ����������� */

/* const: Off_LevelCode
  ��� ������ ����������� "����������� ���������".
*/
Off_LevelCode varchar2(10) := 'OFF';

/* const: Fatal_LevelCode
  ��� ������ ����������� "��������� ������".
*/
Fatal_LevelCode varchar2(10) := 'FATAL';

/* const: Error_LevelCode
  ��� ������ ����������� "������".
*/
Error_LevelCode varchar2(10) := 'ERROR';

/* const: Warn_LevelCode
  ��� ������ ����������� "��������������".
*/
Warn_LevelCode varchar2(10) := 'WARN';

/* const: Info_LevelCode
  ��� ������ ����������� "����������".
*/
Info_LevelCode varchar2(10) := 'INFO';

/* const: Debug_LevelCode
  ��� ������ ����������� "�������".
*/
Debug_LevelCode varchar2(10) := 'DEBUG';

/* const: Trace_LevelCode
  ��� ������ ����������� "�����������".
*/
Trace_LevelCode varchar2(10) := 'TRACE';

/* const: All_LevelCode
  ��� ������ ����������� "������������ ������� �����������".
*/
All_LevelCode varchar2(10) := 'ALL';

/* const: Warning_LevelCode( DEPRECATED)
  ���������� ���������, ������� ������������ <Warn_LevelCode>.
*/
Warning_LevelCode varchar2(10) := Warn_LevelCode;



/* group: ���������� ������ */

/* const: DbmsOutput_DestinationCode
  ��� ���������� "����� ����� dbms_output".
*/
DbmsOutput_DestinationCode varchar2(10) := 'DBOUT';

/* const: Table_DestinationCode
  ��� ���������� "������� ���� � ��".
*/
Table_DestinationCode varchar2(10) := 'TAB';



/* group: ������� */

/* pproc: setDestination
  ������������� ������������ ���������� ��� ������.

  ���������:
  destinationCode             - ��� ����������

  ���������:
  - �������� <pkg_LoggingInternal.setDestination>;

  ( <body::setDestination>)
*/
procedure setDestination(
  destinationCode varchar2
);

/* pproc: logDebug
  �������� ���������� ��������� ������ <Debug_LevelCode>.

  ���������:
  message                     - ���������

  ���������:
  - �������� <pkg_LoggingInternal.logMessage>;

  ( <body::logDebug>)
*/
procedure logDebug(
  message varchar2
);

/* pproc: logMessage
  �������� �������������� ��������� ������ <Info_LevelCode>.

  ���������:
  message                         - ���������

  ���������:
  - �������� <pkg_LoggingInternal.logMessage>;

  ( <body::logMessage>)
*/
procedure logMessage(
  message varchar2
);

/* pfunc: getErrorStack
  �������� ���������� � ����� ������.

  ���������:
  isStackPreserved            - ��������� �� ������ �� �����.
                                ��-��������� ( null) �� ���������
                                ( �.�. �������),
                                ����� ������� ��-���������
                                ����� ������ ���� �� ����� ����
                                ������� �����.

  �������:
  - ����� � ����������� � �����

  ���������:
  - �������� <pkg_LoggingErrorStack.getErrorStack>;

  ( <body::getErrorStack>)
*/
function getErrorStack(
  isStackPreserved integer := null
)
return varchar2;

/* pproc: clearErrorStack
  �������( ����������) ���� ������.

  ���������:
  - �������� <pkg_LoggingErrorStack.clearLastStack>;

  ( <body::clearErrorStack>)
*/
procedure clearErrorStack;

end pkg_Logging;
/
