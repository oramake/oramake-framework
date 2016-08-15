create or replace package pkg_OptionTest is
/* package: pkg_OptionTest
  �������� ����� ������.

  SVN root: Oracle/Module/Option
*/



/* group: ������� */

/* pproc: testOptionList
  ���� ������ � ����������� � ������� ���� <opt_option_list_t>.

  ���������:
  saveDataFlag                - �������� �������� ������ � �������� ���
                                �������� ���������� �����
                                ( 1 ��, 0 ��� ( �� ���������))

  ( <body::testOptionList>)
*/
procedure testOptionList(
  saveDataFlag integer := null
);

/* pproc: testWebApi
  ���� API ��� web-����������.

  ���������:
  saveDataFlag                - �������� �������� ������ � �������� ���
                                �������� ���������� �����
                                ( 1 ��, 0 ��� ( �� ���������))

  ( <body::testWebApi>)
*/
procedure testWebApi(
  saveDataFlag integer := null
);

end pkg_OptionTest;
/
