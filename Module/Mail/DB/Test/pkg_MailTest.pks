create or replace package pkg_MailTest
as
/* package: pkg_MailTest
   ����� ��� ������������ ������ Mail
*/



/* group: ��������� */



/* group: ��������� ������������ */

/* const: TestSender_OptSName
  ������������ ������������ ���������
  "�����: ����� �����������"
*/
TestSender_OptSName constant varchar2(50) := 'TestSender';

/* const: TestRecipient_OptSName
  ������������ ������������ ���������
  "�����: ������ �����������"
*/
TestRecipient_OptSName constant varchar2(50) := 'TestRecipient';

/* const: TestSmtpServer_OptSName
  ������������ ������������ ���������
  "�����: SMTP ������"
*/
TestSmtpServer_OptSName constant varchar2(50) := 'TestSmtpServer';

/* const: TestFetchUrl_OptSName
  ������������ ������������ ���������
  "�����: URL ��������� ����� � URL-encoded ������� ( pop3://user@server.domen)"
*/
TestFetchUrl_OptSName constant varchar2(50) := 'TestFetchUrl';

/* const: TestFetchPassword_OptSName
  ������������ ������������ ���������
  "�����: ������ ��� ����������� � ��������� �����"
*/
TestFetchPassword_OptSName constant varchar2(50) := 'TestFetchPassword';

/* const: TestFetchSendAddress_OptSName
  ������������ ������������ ���������
  "�����: ����� ��� �������� ��������� �� �������� ���� ( � ������, ���� �� ���������� �� ������, ����������� �� URL ��������� �����)"
*/
TestFetchSendAddress_OptSName constant varchar2(50) := 'TestFetchSendAddress';



/* group: ������� */

/* pproc: testEmailValidation
   ��������� �������� �������� ��� �������� ������ ���������� email �������

  ( <body::testEmailValidation>)
*/
procedure testEmailValidation;

/* pproc: testSendMail
  ������������ ����������� �������� �������� ���������.

  ���������:
  testCaseNumber              - ����� ������������ ��������� ������
                                ( �� ��������� ��� �����������)

  ( <body::testSendMail>)
*/
procedure testSendMail(
  testCaseNumber integer := null
);

/* pproc: testSendMessage
  ������������ �������� �������� ���������.

  ���������:
  testCaseNumber              - ����� ������������ ��������� ������
                                ( �� ��������� ��� �����������)

  ( <body::testSendMessage>)
*/
procedure testSendMessage(
  testCaseNumber integer := null
);

/* pproc: testSendHtmlMessage
  ������������ �������� �������� ��������� � ������� HTML.

  ���������:
  testCaseNumber              - ����� ������������ ��������� ������
                                ( �� ��������� ��� �����������)

  ( <body::testSendHtmlMessage>)
*/
procedure testSendHtmlMessage(
  testCaseNumber integer := null
);

/* pproc: testFetchMessage
  ������������ ��������� �������� ���������.

  ���������:
  testCaseNumber              - ����� ������������ ��������� ������
                                ( �� ��������� ��� �����������)

  ( <body::testFetchMessage>)
*/
procedure testFetchMessage(
  testCaseNumber integer := null
);

end pkg_MailTest;
/
