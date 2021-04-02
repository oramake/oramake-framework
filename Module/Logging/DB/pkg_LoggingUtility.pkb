create or replace package body pkg_LoggingUtility is
/* package body: pkg_LoggingUtility::body */



/* group: ���������� */

/* ivar: logger
  ����� ������.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => pkg_Logging.Module_Name
  , objectName  => 'pkg_LoggingUtility'
);



/* group: ������� */

/* func: clearLog
  ������� ������ ����.

  ���������:
  toTime                      - �����, �� �������� ����� ������� ����
                                (�� �������)

  �������:
  ����� ��������� �������
*/
function clearLog(
  toTime timestamp with time zone
)
return integer
is


  -- ����� ��������� ������� ����
  nDeleted integer;

begin
  logger.trace(
    'clearLog: toTime: ' || to_char( toTime, 'dd.mm.yyyy hh24:mi:ss.ff tzh:tzm')
  );

  -- ������� ���� ������, � ������� ��� ������ ������������ �� ��������� ����
  delete
    lg_log lg
  where
    lg.sessionid in
      (
      select
        t.sessionid
      from
        lg_log t
      where
        t.log_time < toTime
      group by
        t.sessionid
      having
        not exists
          (
          select
            null
          from
            lg_log tt
          where
            tt.sessionid = t.sessionid
            and tt.log_time >= toTime
          )
      )
  ;
  nDeleted := sql%rowcount;

  logger.trace( 'lg_log rows deleted: ' || nDeleted);
  return nDeleted;
exception when others then
  raise_application_error(
    pkg_Error.ErrorStackInfo
    , logger.errorStack(
        '������ ��� �������� ������� ���� ('
        || ' toTime=' || to_char( toTime, 'dd.mm.yyyy hh24:mi:ss.ff tzh:tzm')
        || ').'
      )
    , true
  );
end clearLog;

end pkg_LoggingUtility;
/
