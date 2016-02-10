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



/* group: ������ ��������� ���� */

/* const: Off_LevelCode
  ��� ������ "����������� ���������".
*/
Off_LevelCode varchar2(10) := 'OFF';

/* const: Fatal_LevelCode
  ��� ������ "��������� ������".
*/
Fatal_LevelCode varchar2(10) := 'FATAL';

/* const: Error_LevelCode
  ��� ������ "������".
*/
Error_LevelCode varchar2(10) := 'ERROR';

/* const: Warning_LevelCode
  ��� ������ "��������������".
*/
Warning_LevelCode varchar2(10) := 'WARN';

/* const: Info_LevelCode
  ��� ������ "����������".
*/
Info_LevelCode varchar2(10) := 'INFO';

/* const: Debug_LevelCode
  ��� ������ "�������".
*/
Debug_LevelCode varchar2(10) := 'DEBUG';

/* const: Trace_LevelCode
  ��� ������ "�����������".
*/
Trace_LevelCode varchar2(10) := 'TRACE';

/* const: All_LevelCode
  ��� ������ "������������ ������� �����������".
*/
All_LevelCode varchar2(10) := 'ALL';



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

/* pproc: SetDestination
  ������������� ������������ ���������� ��� ������
  (<body::SetDestination>)
*/
procedure SetDestination(
  destinationCode varchar2
);

/* pproc: LogMessage
  �������� �������������� ���������
  ( <body::LogMessage>)
*/
procedure LogMessage( Message varchar2 );

/* pfunc: LogDebug
  �������� ���������� ���������
  ( ������ ( <body::LogDebug>)
*/
procedure LogDebug( Message varchar2 );

/* pfunc: GetErrorStack
  �������� ���������� � ����� ������
  ( <body::GetErrorStack>).
*/
function GetErrorStack(
  isStackPreserved integer := null
)
return varchar2;

/* pproc: ClearErrorStack
   �������( ����������) ���� ������
  ( <body::ClearErrorStack>).
*/
procedure ClearErrorStack;

end pkg_Logging;
/
