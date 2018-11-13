create or replace package body pkg_Logging is
/* package body: pkg_Logging::body */



/* group: ������� */

/* proc: setDestination
  ������������� ������������ ���������� ��� ������.

  ���������:
  destinationCode             - ��� ����������
                                (null ��� �������� � ������ �� ���������)

  ���������:
  - �� ��������� (���� �� ������ ������������ ���������� ��� ������)
    ���������� ��������� ����������� � ������� <lg_log>, � � �������� ��
    ������������� ��������� ����� ����� dbms_output;
*/
procedure setDestination(
  destinationCode varchar2
)
is
begin
  pkg_LoggingInternal.setDestination(
    destinationCode => destinationCode
  );
end setDestination;

/* proc: logDebug
  �������� ���������� ��������� ������ <Debug_LevelCode>.

  ���������:
  message                     - ���������

  ���������:
  - �������� <pkg_LoggingInternal.logMessage>;
*/
procedure logDebug(
  message varchar2
)
is
begin
  pkg_LoggingInternal.logMessage(
    levelCode     => Debug_LevelCode
    , messageText => message
  );
end logDebug;

/* proc: logMessage
  �������� �������������� ��������� ������ <Info_LevelCode>.

  ���������:
  message                         - ���������

  ���������:
  - �������� <pkg_LoggingInternal.logMessage>;
*/
procedure logMessage(
  message varchar2
)
is
begin
  pkg_LoggingInternal.logMessage(
    levelCode     => Info_LevelCode
    , messageText => message
  );
end logMessage;

/* func: getErrorStack
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
*/
function getErrorStack(
  isStackPreserved integer := null
)
return varchar2
is
begin
  return
    pkg_LoggingErrorStack.getErrorStack(
      isStackPreserved => isStackPreserved
    );
end getErrorStack;

/* proc: clearErrorStack
  �������( ����������) ���� ������.

  ���������:
  - �������� <pkg_LoggingErrorStack.clearLastStack>;
*/
procedure clearErrorStack
is
begin
  pkg_LoggingErrorStack.clearLastStack();
end clearErrorStack;

end pkg_Logging;
/
