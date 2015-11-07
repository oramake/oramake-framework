create or replace package body pkg_FileBase is
/* package body: pkg_FileBase::body */



/* group: ���������� */

/* ivar: logger
  ����� ������.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => pkg_FileOrigin.Module_Name
  , objectName  => 'pkg_FileBase'
);



/* group: ������� */

/* proc: getProxyConfig
  ���������� ��������� ������-������� ��� ��������� �� ���������� URL.
  ���������� �� Java-������ com.technology.oramake.file.netfile.HttpFile.

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
)
is

  -- ������ ���������� ������
  opl opt_option_list_t := opt_option_list_t(
    moduleName => pkg_FileOrigin.Module_Name
  );

  -- ���� ������������� ������-�������
  useProxyFlag integer;

  -- �������� � ������������ ���������
  badOptionValue varchar2(200);

begin
  select
    1 - count(*)
  into useProxyFlag
  from
    (
    select
      lower( replace( t.column_value, '*', '%')) as host_mask
    from
      table( pkg_Common.split(
        opl.getString( ProxySkipAddressList_OptSName)
        , ';'
      )) t
    ) a
  where
    lower( targetHost) like a.host_mask
    or lower( targetProtocol || '://' || targetHost) like a.host_mask
    or lower( targetHost || ':' || targetPort) like a.host_mask
    or lower( targetProtocol || '://' || targetHost || ':' || targetPort)
      like a.host_mask
    and rownum <= 1
  ;
  if useProxyFlag = 1 then
    serverAddress := opl.getString( ProxyServerAddress_OptSName);
    serverPort    := opl.getNumber( ProxyServerPort_OptSName);
    username      := opl.getString( ProxyUsername_OptSName);
    password      := opl.getString( ProxyPassword_OptSName);
    domain        := opl.getString( ProxyDomain_OptSName);
    badOptionValue :=
      case
        when serverAddress is null then ProxyServerAddress_OptSName
        when serverPort is null then ProxyServerPort_OptSName
        when username is null then ProxyUsername_OptSName
        when password is null then ProxyPassword_OptSName
        when domain is null then ProxyDomain_OptSName
      end
    ;
    if badOptionValue is not null then
      raise_application_error(
        pkg_Error.ProcessError
        , '�� ������ �������� ������������ ��������� ������'
          || ' "' || badOptionValue || '"'
          || ', ����������� ��� ������������� ������-�������.'
      );
    end if;
  end if;
  logger.trace(
    'getProxyConfig'
    || ': for'
      || ' protocol "' || targetProtocol || '"'
      || ', host "' || targetHost || '"'
      || ', port "' || targetPort || '"'
    || case when serverAddress is null then
        ': without proxy'
      else
        ': use proxy'
        || ' address "' || serverAddress || '"'
        || ', port "' || serverPort || '"'
        || ', username "' || username || '"'
        || ', domain "' || domain || '"'
      end
  );
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������� �������� ������-������� ��� ��������� �� URL ('
        || ' targetProtocol="' || targetProtocol || '"'
        || ', targetHost="' || targetHost || '"'
        || ', targetPort=' || targetPort
        || ').'
      )
    , true
  );
end getProxyConfig;

end pkg_FileBase;
/
