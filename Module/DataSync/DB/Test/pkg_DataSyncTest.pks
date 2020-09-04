create or replace package pkg_DataSyncTest
authid current_user
is
/* package: pkg_DataSyncTest
  ������� ������������ ������.

  SVN root: Oracle/Module/DataSync
*/



/* group: ������� */

/* pproc: apiTest
  ������������ API.

  ( <body::apiTest>)
*/
procedure apiTest;

/* pproc: refreshTest
  ������������ ���������� ������.

  ���������:
  refreshMethod         - ����� ���������� ( "d" ���������� ������ ( ��
                          ���������), "m" � ������� ������������������
                          �������������, "t" ���������� � ��������������
                          ��������� �������)

  ( <body::refreshTest>)
*/
procedure refreshTest(
  refreshMethod varchar2
);

/* pproc: testAppendData
  ��������� �������� ������ �������� <pkg_DataSync.appendData>.

  ���������:
  testCaseNumber              - ����� ������������ ��������� ������
                                (�� ��������� ��� �����������)

  ( <body::testAppendData>)
*/
procedure testAppendData(
  testCaseNumber integer := null
);

end pkg_DataSyncTest;
/
