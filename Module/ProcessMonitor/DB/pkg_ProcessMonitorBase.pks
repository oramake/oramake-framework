create or replace package pkg_ProcessMonitorBase is
/* package: pkg_ProcessMonitorBase
  ����� ������ ProcessMonitor, ���������� ���������
  � ������� �������

  SVN root: Oracle/Module/ProcessMonitor
*/



/* group: ��������� */



/* const: Module_Name
  �������� ������, � �������� ��������� �����.
*/
Module_Name constant varchar2(30) := 'ProcessMonitor';

/* const: OraKill_SessionActionCode
  ��� �������� orakill ��� ������
*/
OraKill_SessionActionCode constant varchar2(10) := 'ORAKILL';

/* const: Trace_SessionActionCode
  ��� �������� "��������� �����������" ��� ������
*/
Trace_SessionActionCode constant varchar2(10) := 'TRACE';

/* const: SendTrace_SessionActionCode
  ��� �������� "�������� ��������� �����������" ��� ������
*/
SendTrace_SessionActionCode constant varchar2(10) := 'SENDTRACE';

/* const: TraceCopyPath_OptionName
  ����� "���������� ��� Trace-������" ��-���������.
*/
TraceCopyPath_OptionName constant varchar2(100) :=
  'DefaultTraceCopyPath';

end pkg_ProcessMonitorBase;
/
