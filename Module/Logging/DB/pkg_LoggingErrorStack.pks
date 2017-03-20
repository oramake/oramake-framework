create or replace package pkg_LoggingErrorStack is
/* package: pkg_LoggingErrorStack
  ���������� ����� ������ Logging, ����������
  �� ����������� ���������� �� ������� ( �����������)

  SVN root: Oracle/Module/Logging
*/



/* group: ������� */

/* pproc: clearLastStack
  ���������� ���������� � ���������� ����� ������

  ����������:
  - ����� ���� ������� ��� � ����� ��������� ����������,
    ��� � ��� ���.
  - �������� <clearLastStack(messageText)>
    � ���������� "����� �����"

  ( <body::clearLastStack>)
*/
procedure clearLastStack;

/* pfunc: processStackElement
  �������� � ���������� ��������� �������� �����.
  ���������� ������ ��� ��������� ����������.

  ���������:
  messageText                 - ����� ���������

  �������:
  - ����� ��� ��������� ����������, ��� ��������� ����� ����� �� ���������� ��
    messageText

  ����������:
  - ����� ���� ������� ��� � ����� ��������� ����������, ��� � ��� ���.  ���
    ������ ��� ����� ����������, ��������� ���� �� ������ ���� ������� �
    ����������, ���� �� �� �������.

  ( <body::processStackElement>)
*/
function processStackElement(
  messageText varchar2
)
return varchar2;

/* pproc: logErrorStack
  ������� ���� ������. �������� ���������� � ����� � �������
  <pkg_Logging.Error_LevelCode>, ���� ������� ������� ���� � ����������
  �����������.

  ���������:
  messageText                 - ����� ��������������� ���������

  ( <body::logErrorStack>)
*/
procedure logErrorStack(
  messageText varchar2
);

/* pfunc: processRemoteStackElement
  �������� � ���������� ��������� �������� �����, �������� ���� �� ��������
  ����. � ������ ������� ���������� � <body::lastStack>, ������� ��������
  ���������� ��������� ����

  ���������:
  messageText                 - ����� ���������
  dbLink                      - ��� ����� � ��

  �������:
  - ����� ��� ��������� ����������, ��� ��������� ����� ����� �� ���������� ��
    messageText

  ����������:
  - ������������ ������� <getRemoteStack>;
  - ������������� �������� � ����� ��������� ����������;

  ( <body::processRemoteStackElement>)
*/
function processRemoteStackElement(
  messageText varchar2
  , dbLink varchar2
)
return varchar2;

/* pfunc: getErrorStack
  �������� ���������� � ����� ������.

  isStackPreserved            - ��������� �� ������ �� �����.
                                ��-��������� ( null) �� ��������� ( �.�.
                                �������), ����� ������� ��-��������� �����
                                ������ ���� �� ����� ���� ������� �����.

  �������:
  - ����� � ����������� � �����

  ����������:
  - ������������� �������� � ����� ��������� ����������;

  ( <body::getErrorStack>)
*/
function getErrorStack(
  isStackPreserved integer := null
)
return varchar2;

/* pproc: getLastStack
  �������� ������ �� ���������� �����.
  ���� ���������� � <body::lastStack> �� ��������,
  ���������� ������ <body::lastStack>, ����� ����������
  ������ <body::lastClearedStack>.

  ���������:
  raisedText                 - ��������� ��� ��������� ����������,
                               ������������ �������� <processStackElement>
  oracleMessage              - �������� <errorStack> ��������� � �����
  messageText                - ���������� ����� ��������� �� ������
  resolvedStack              - ������ ������������� ����� ���������
                               �� ������
  callStack                  - ����� ���������� � ����� �������

  ( <body::getLastStack>)
*/
procedure getLastStack(
  raisedText               out varchar2
  , oracleMessage          out varchar2
  , messageText            out varchar2
  , resolvedStack          out varchar2
  , callStack              out varchar2
);

end pkg_LoggingErrorStack;
/
