create or replace package pkg_CalendarTest is
/* package: pkg_CalendarTest
  ����� ��� ������������ ������.

  SVN root: Oracle/Module/Calendar
*/



/* group: ������� */

/* pproc: testWebApi
  ���� API ��� web-����������.

  ���������:
  saveDataFlag                - ��������� �������� ������ � �������� ���
                                �������� ���������� �����
                                ( 1 ��, 0 ��� ( �� ���������))

  ( <body::testWebApi>)
*/
procedure testWebApi(
  saveDataFlag integer := null
);

end pkg_CalendarTest;
/
