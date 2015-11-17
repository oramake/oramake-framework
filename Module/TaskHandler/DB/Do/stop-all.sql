--script: Do/stop-all.sql
--�������� ������� ��������� ���� �������, ��� ������� ���������� ���������
--�����.
--
--���������:
--  - ������ �� ���������� ���������������� ������ ( ������� <pkg_TaskHandler>)
--    ����� ���������� ������������� � ������ �� �����������;
--

declare
  
  cursor curSession is
    select
      ss.sid
      , ss.serial#
      , cp.name as pipe_name
    from
      v$session ss
      inner join v_th_command_pipe cp
        on cp.sid = ss.sid
        and cp.serial# = ss.serial#
    order by
      1, 2
  ;

  PROCEDURE SENDMESSAGE
   (PIPENAME VARCHAR2
   ,TIMEOUT INTEGER := dbms_pipe.maxwait
   ,MAXPIPESIZE INTEGER := 8192
   )
   IS
  --�������� ��������� � �����.
  --
  --���������:
  --pipeName                    - ��� ������
  --timeout                     - ������� �������� (� ��������)
  --maxPipeSize                 - ��������� ������������ ������ ������

                                          --��������� �������� � �������
    pipeStatus number := null;            
    
  --SendMessage
  begin
                                          --�������� ���������
    pipeStatus := dbms_pipe.send_message(
      pipename  => pipeName
      , timeout => timeout
      , maxpipesize => maxPipeSize
    );
                                          --��������� ���������� �������
    if pipeStatus <> 0 then
      if pipeStatus = 1 then
        raise_application_error(
          -20001
          , '���������� ��������� �������� ��������� ('
            || ' ��� ' || to_char( pipeStatus)
            || ').'
        );
      end if;
    end if;
  exception when others then
    dbms_pipe.reset_buffer;
    raise_application_error(
      -20001
      , '������ ��� �������� ��������� � ����� "' || pipeName || '".'
      , true
    );
  end SendMessage;

begin
  for rec in curSession loop
    dbms_output.put_line( 
      rec.sid || ',' || rec.serial# || ' stop...'
    );
    dbms_pipe.pack_message( 'stop');
    SendMessage( rec.pipe_name);
  end loop;
end;
/
