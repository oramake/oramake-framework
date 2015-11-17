--script: Do/stop.sql
--�������� ������� ��������� ������� ������������.
--
--���������:
--taskPattern                 - ������ ����� ������ ( ������
--                              "<module_name>:<process_full_name>" ������������
--                              �� like � ���� ��������, �� ��������� ���
--                              �����������)
--
--���������:
--  - ������ ��� �������� ������� ������� ������������ ( ������� ��������
--    ������� ������������ ���� ���������� ������� ���������� �� ������
--    ��������);
--

define taskPattern = "coalesce( nullif( '&1', 'null'), '%')"



declare

  cursor curSession is
select
  ss.*
from
  v_th_session ss
where
  ss.module_name || ':' || ss.process_full_name like &taskPattern
order by
  ss.module_name
  , ss.process_full_name
  , ss.sid
;

begin
  for rec in curSession loop
    begin
      dbms_output.put( 
        rec.sid || ',' || rec.serial#  || ': '
        || rec.module_name || ':' || rec.process_full_name
        || ': '
      );
      pkg_TaskHandler.sendStopCommand(
        sessionSid => rec.sid
        , sessionSerial => rec.serial#
      );
      dbms_output.put_line( 'stop sended');
    exception when others then
      dbms_output.put_line( 'ERROR');
      dbms_output.put_line( substr( SQLERRM, 1, 250));
    end;
  end loop;
end;
/



undefine taskPattern
