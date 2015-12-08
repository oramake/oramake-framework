create or replace package pkg_LoggingErrorStack is
/* package: pkg_LoggingErrorStack
  ���������� ����� ������ Logging, ����������
  �� ����������� ���������� �� ������� ( �����������)

  SVN root: Oracle/Module/Logging
*/

/* pproc: ClearLastStack
  ���������� ���������� � ���������� ����� ������
  (<body::ClearLastStack> ).
*/
procedure ClearLastStack;

/* pfunc: ProcessStackElement
  �������� � ���������� ��������� �������� �����.
  ���������� ������ ��� ��������� ����������.
  (<body::ProcessStackElement> ).
*/
function ProcessStackElement(
  messageText varchar2
)
return varchar2;

/* pfunc: ProcessRemoteStackElement
  �������� � ���������� ��������� �������� �����,
  �������� ���� �� �������� ����. � ������
  ������� ���������� � <body::lastStack>, ������� ��������
  ���������� ��������� ����
  ( <body::ProcessRemoteStackElement>).
*/
function ProcessRemoteStackElement(
  messageText varchar2
  , dbLink varchar2
)
return varchar2;

/* pproc: LogErrorStack
  �������� � ������� ���� ������
  (<body::LogErrorStack> ).
*/
procedure LogErrorStack(
  messageText varchar2
);

/* pfunc: GetErrorStack
  �������� ���������� � ����� ������
  (<body::GetErrorStack> ).
*/
function GetErrorStack(
  isStackPreserved integer := null
)
return varchar2;

/* pproc: GetLastStack
  �������� ������ �� ���������� �����.
  ���� ���������� � <body::lastStack> �� ��������,
  ���������� ������ <body::lastStack>, ����� ����������
  ������ <body::lastClearedStack>
  ( <body::GetLastStack>).
*/  
procedure GetLastStack(
  raisedText               out varchar2
  , oracleMessage          out varchar2
  , messageText            out varchar2
  , resolvedStack          out varchar2
  , callStack              out varchar2
);

end pkg_LoggingErrorStack;
/
