title: ��������

������������ ����������� ������ ���������� �������.


Group: ����������� ����� ������

��� ����������� ����� �������������
���������� � ��������� raise_application_error � �������� ������� ���������
��������� ������� <lg_logger_t.ErrorStack>, ��������� �� ����������� ���������.
��� ������ � �������� ��, ������� ������������ <lg_logger_t.RemoteErrorStack>, ��������
� �������� ������� ��������� ��� �����.
��� ��������� ���������� � ����� ������� ������������ ������� <lg_logger_t.GetErrorStack>
��� <pkg_Logging.GetErrorStack>. ��� ������ ���������� � ���������� ����� ���������.
� ������, ���� ����� ���� ������� <lg_logger_t.ErrorStack>, ���������� � ����� �� ����
�������� � �������� ����� ����������, ���� ����������� ���������� ������������
( ���������� ���������� � ������� <pkg_Logging.Debug_LevelCode> ).

������������� ������� <lg_logger_t.GetErrorStack> ���������� ������������� ����������� plsql-������� SQLERRM,
��� ������� ���� ����������� ������� ������ raise_application_error, �� ���� ������������
<lg_logger_t.ErrorStack>. ����� ��������� ����� ��������� 32767 ��������.

� ������, ���� ���������� �� ���� �������� �� �������, ���������� � ����� ���������� � �������
<pkg_Logging.Error_LevelCode> ( ������������ ������� on servererror <lg_after_server_error>).

������� ����������� ����� ������:

- ��������� ��������� �� ������ �����, ������������ ���� ������ varchar2

(start code)
declare
  lg lg_logger_t := lg_logger_t.GetLogger(
    moduleName => 'Test'
    , objectName => 'TestBlock'
  );

  procedure Internal
  is
  begin
    raise_application_error(
      pkg_Error.ProcessError
      , lg.ErrorStack( '��������� ������' || lpad( '!', 10000, '_'))
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , lg.ErrorStack( '������ "Internal_"' || lpad( '!', 10000, '_'))
      , true
    );
  end Internal;

begin
  Internal;
exception when others then
  pkg_Common.OutputMessage(
    lg.GetErrorStack
  );
end;
/

declare
  lg lg_logger_t := lg_logger_t.GetLogger(
    moduleName => 'Test'
    , objectName => 'TestBlock'
  );

  procedure Internal
  is
  begin
    raise_application_error(
      pkg_Error.ProcessError
      , lg.ErrorStack( '��������� ������' || lpad( '!', 1000, '_'))
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , lg.ErrorStack( '������ "Internal_"' || lpad( '!', 1000, '_'))
      , true
    );
  end Internal;

  procedure Internal2
  is
    errorMessage varchar2( 32267);
  begin
    begin
      Internal;
    exception when others then
      errorMessage := lg.GetErrorStack();
    end;
                                       -- ����� ������������� ����������
                                       -- ����� � errorMessage
    raise_application_error(
      pkg_Error.ProcessError
      , lg.ErrorStack(
          '��������� ������ ���������' || lpad( '!', 100, '_')
          || '"' || errorMessage || '"'
        )
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , lg.ErrorStack( '������ "Internal_2"' || lpad( '!', 1000, '_'))
      , true
    );
  end Internal2;

begin
  Internal2;
exception when others then
  pkg_Common.OutputMessage(
    lg.GetErrorStack
  );
end;
/
(end)

- ��������� ����� � �������������� �����

(code)
declare
  lg lg_logger_t := lg_logger_t.GetLogger(
    moduleName => 'Test'
    , objectName => 'TestBlock'
  );
  dblink varchar2( 30) := '&dblink';

  procedure Internal
  is
    a integer;
  begin
    execute immediate
'begin drop_me_tmp100@' || dblink || ';end;'
    ;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , lg.RemoteErrorStack( '������ "Internal_"' || lpad( '!', 10000, '_'), dblink)
      , true
    );
  end Internal;

begin
  Internal;
exception when others then
  pkg_Common.OutputMessage(
    lg.GetErrorStack
  );
end;
(end)



