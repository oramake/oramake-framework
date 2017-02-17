title: ��������

������������ ����������� ������ ���������� �������.


Group: ����������� ����� ������

��� ����������� ����� �������������
���������� � ��������� raise_application_error � �������� ������� ���������
��������� ������� <lg_logger_t.errorStack>, ��������� �� ����������� ���������.
��� ������ � �������� ��, ������� ������������ <lg_logger_t.remoteErrorStack>, ��������
� �������� ������� ��������� ��� �����.
��� ��������� ���������� � ����� ������� ������������ ������� <lg_logger_t.getErrorStack>
��� <pkg_Logging.GetErrorStack>. ��� ������ ���������� � ���������� ����� ���������.
� ������, ���� ����� ���� ������� <lg_logger_t.errorStack>, ���������� � ����� �� ����
�������� � �������� ����� ����������, ���� ����������� ���������� ������������
( ���������� ���������� � ������� <pkg_Logging.Debug_LevelCode> ).

������������� ������� <lg_logger_t.getErrorStack> ���������� ������������� ����������� plsql-������� SQLERRM,
��� ������� ���� ����������� ������� ������ raise_application_error, �� ���� ������������
<lg_logger_t.errorStack>. ����� ��������� ����� ��������� 32767 ��������.

� ������, ���� ���������� �� ���� �������� �� �������, ���������� � ����� ���������� � �������
<pkg_Logging.Error_LevelCode> ( ������������ ������� on servererror <lg_after_server_error>).

������� ����������� ����� ������:

- ��������� ��������� �� ������ �����, ������������ ���� ������ varchar2

(start code)
declare
  lg lg_logger_t := lg_logger_t.getLogger(
    moduleName => 'Test'
    , objectName => 'TestBlock'
  );

  procedure internal
  is
  begin
    raise_application_error(
      pkg_Error.ProcessError
      , lg.errorStack( '��������� ������' || lpad( '!', 10000, '_'))
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , lg.errorStack( '������ "Internal_"' || lpad( '!', 10000, '_'))
      , true
    );
  end internal;

begin
  internal();
exception when others then
  pkg_Common.outputMessage(
    lg.getErrorStack()
  );
end;
/

declare
  lg lg_logger_t := lg_logger_t.getLogger(
    moduleName => 'Test'
    , objectName => 'TestBlock'
  );

  procedure internal
  is
  begin
    raise_application_error(
      pkg_Error.ProcessError
      , lg.errorStack( '��������� ������' || lpad( '!', 1000, '_'))
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , lg.errorStack( '������ "Internal_"' || lpad( '!', 1000, '_'))
      , true
    );
  end internal;

  procedure internal2
  is
    errorMessage varchar2( 32267);
  begin
    begin
      internal();
    exception when others then
      errorMessage := lg.getErrorStack();
    end;

    -- ����� ������������� ���������� ����� � errorMessage
    raise_application_error(
      pkg_Error.ProcessError
      , lg.errorStack(
          '��������� ������ ���������' || lpad( '!', 100, '_')
          || '"' || errorMessage || '"'
        )
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , lg.errorStack( '������ "Internal_2"' || lpad( '!', 1000, '_'))
      , true
    );
  end internal2;

begin
  internal2();
exception when others then
  pkg_Common.outputMessage(
    lg.getErrorStack()
  );
end;
/
(end)

- ��������� ����� � �������������� �����

(code)
declare
  lg lg_logger_t := lg_logger_t.getLogger(
    moduleName => 'Test'
    , objectName => 'TestBlock'
  );
  dblink varchar2( 30) := '&dblink';

  procedure internal
  is
    a integer;
  begin
    execute immediate
'begin drop_me_tmp100@' || dblink || ';end;'
    ;
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , lg.remoteErrorStack( '������ "Internal_"' || lpad( '!', 10000, '_'), dblink)
      , true
    );
  end internal;

begin
  internal();
exception when others then
  pkg_Common.outputMessage(
    lg.getErrorStack()
  );
end;
(end)



