create package pkg_Scheduler is
/* package: pkg_Scheduler(dummy)
  ��������� ������������ ��� ���������� pkg_LoggingInternal.

  SVN root: Oracle/Module/Logging
*/



/* const: Error_MessageTypeCode
  ��� ���� ��������� "������".
*/
Error_MessageTypeCode constant varchar2(10) := 'ERROR';

/* const: Warning_MessageTypeCode
  ��� ���� ��������� "��������������".
*/
Warning_MessageTypeCode constant varchar2(10) := 'WARNING';

/* const: Info_MessageTypeCode
  ��� ���� ��������� "����������".
*/
Info_MessageTypeCode constant varchar2(10) := 'INFO';

/* const: Debug_MessageTypeCode
  ��� ���� ��������� "�������".
*/
Debug_MessageTypeCode constant varchar2(10) := 'DEBUG';



/* group: ������� */

/* pproc: dummyProcedure
  ��������� ��� ����, ����� ��� ���������� ���������� ������, ����������
  ������.
*/
procedure dummyProcedure;

/* pproc: writeLog
  ���������� ��������� � ��� (������� sch_log).

  ���������:
  messageTypeCode           - ��� ���� ���������
  messageText               - ����� ���������
  messageValue              - ����� ��������, ��������� � ����������
  operatorId                - Id ���������
*/
procedure writeLog(
  messageTypeCode varchar2
  , messageText varchar2
  , messageValue number := null
  , operatorId integer := null
);

/* pproc: setDebugFlag
  ������������� ���� ������� � ��������� ��������.
*/
procedure setDebugFlag(
  flagValue integer := 1
);

/* pfunc: getDebugFlag
  ���������� �������� ����� �������.
*/
function getDebugFlag
return integer;


end pkg_Scheduler;
/
