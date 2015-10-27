create or replace package pkg_FileBase is
/* package: pkg_FileBase
  ������� ����� ������.

  SVN root: Oracle/Module/File
*/



/* group: ��������� */



/* group: ������������ ����������� ���������� */

/* const: ProxyServerAddress_OptSName
  �������� ������������ ����� "����� ������-������� ( ������������ ���
  �������� �� ��������� HTTP)"
*/
ProxyServerAddress_OptSName constant varchar2(50) := 'ProxyServerAddress';

/* const: ProxyServerPort_OptSName
  �������� ������������ ����� "���� ������-�������"
*/
ProxyServerPort_OptSName constant varchar2(50) := 'ProxyServerPort';

/* const: ProxyUsername_OptSName
  �������� ������������ �����
  "��� ������������ ��� ����������� �� ������-�������"
*/
ProxyUsername_OptSName constant varchar2(50) := 'ProxyUsername';

/* const: ProxyPassword_OptSName
  �������� ������������ �����
  "������ ������������ ��� ����������� �� ������-�������"
*/
ProxyPassword_OptSName constant varchar2(50) := 'ProxyPassword';

/* const: ProxyDomain_OptSName
  �������� ������������ �����
  "����� ������������ ��� ����������� �� ������-�������"
*/
ProxyDomain_OptSName constant varchar2(50) := 'ProxyDomain';

/* const: ProxySkipAddressList_OptSName
  �������� ������������ �����
  "������ �������, ��� ������� ������-������ �� ������������"
*/
ProxySkipAddressList_OptSName constant varchar2(50) := 'ProxySkipAddressList';



/* group: ������� */

/* pproc: getProxyConfig
  ���������� ��������� ������-������� ��� ��������� �� ���������� URL.
  ���������� �� Java-������ ru.company.netfile.HttpFile.

  ���������:
  serverAddress               - ����� ������-������� ( null ���� �� ���������
                                ������������ ������-������)
                                ( �������)
  serverPort                  - ���� ������-�������
                                ( �������)
  username                    - ��� ������������ ��� ����������� ��
                                ������-�������
  password                    - ������ ������������ ��� ����������� ��
                                ������-�������
  domain                      - ����� ������������ ��� ����������� ��
                                ������-�������
  targetProtocol              - �������� �� URL ����������
  targetHost                  - ���� �� URL ����������
  targetPort                  - ���� �� URL ����������

  ( <body::getProxyConfig>)
*/
procedure getProxyConfig(
  serverAddress out varchar2
  , serverPort out integer
  , username out varchar2
  , password out varchar2
  , domain out varchar2
  , targetProtocol varchar2
  , targetHost varchar2
  , targetPort integer
);

end pkg_FileBase;
/
