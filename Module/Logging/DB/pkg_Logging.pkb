create or replace package body pkg_Logging is
/* package body: pkg_Logging::body */

/* proc: SetDestination
  ������������� ������������ ���������� ��� ������.

  ���������:
  destinationCode             - ��� ����������

  ���������:
  - �������� <pkg_LoggingInternal.SetDestination>;
*/
procedure SetDestination(
  destinationCode varchar2
)
is
begin
  pkg_LoggingInternal.SetDestination(
    destinationCode => destinationCode
  );
end SetDestination;

/* func: LogDebug
  �������� ���������� ��������� ������ <Debug_LevelCode>.

  ���������:
  Message - ���������

  ���������:
  - �������� <pkg_LoggingInternal.LogMessage>;
*/
procedure LogDebug
 (Message varchar2
 )
 is
begin
  pkg_LoggingInternal.LogMessage(
    levelCode     => Debug_LevelCode
    , messageText => message
  );
end LogDebug;


/* proc: LogMessage
  �������� �������������� ��������� ������ <Info_LevelCode>.

  ���������:
    Message - ���������

  ���������:
  - �������� <pkg_LoggingInternal.LogMessage>;
*/
procedure LogMessage( Message varchar2 )
is
begin
  pkg_LoggingInternal.LogMessage(
    levelCode     => Info_LevelCode
    , messageText => message
  );
end LogMessage;

/* func: GetErrorStack
  �������� ���������� � ����� ������.

  ���������:
    isStackPreserved         - ��������� �� ������ �� �����.
                               ��-��������� ( null) �� ��������� 
                               ( �.�. �������), 
                               ����� ������� ��-��������� 
                               ����� ������ ���� �� ����� ���� 
                               ������� �����.

  �������:
    - ����� � ����������� � �����

  ���������:
  - �������� <pkg_LoggingErrorStack.GetErrorStack>;
*/
function GetErrorStack( 
  isStackPreserved integer := null
)
return varchar2
is
begin
  return
    pkg_LoggingErrorStack.GetErrorStack(
      isStackPreserved => isStackPreserved
    );
end GetErrorStack;

/* proc: ClearErrorStack
  �������( ����������) ���� ������.

  ���������:
  - �������� <pkg_LoggingErrorStack.ClearLastStack>;
*/
procedure ClearErrorStack
is
begin
  pkg_LoggingErrorStack.ClearLastStack();
end ClearErrorStack;

end pkg_Logging;
/
