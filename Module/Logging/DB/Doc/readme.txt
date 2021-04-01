title: ��������



group: ��������

������ Logging ������������ ����������� ������ ���������� �������. �������
��������� ���������� ������������ � ������� Apache Log4j 1.x
(<http://logging.apache.org/log4j/1.2/manual.html>).

��� ����������� ������������ ����� (������ ���� <lg_logger_t>). ������
����������� ���, �� ������ �������� �������� �������� �������. ����� ���������
������� ������� ������, ���� ��� ��� (� ����������� �����) �������� ���������
����� ������� ������. ��������, ����� � ������ "com.foo" �������� �������
������ � ������ "com.foo.Bar". � ������� �������� ��������� �������� �����,
������� ��������� ������� ���� ��������� ������� � ������������ ��������
<lg_logger_t.getRootLogger()>. ������ ��� ����������� ������������ �����,
���������� ������� ������� <lg_logger_t.getLogger()> � ��������� ����� ������
� ����� ������� � ������. �������� � ������ pkg_TestModule ������ TestModule
������������ �����

(code)

/* ivar: logger
  ����� ������.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => Module_Name
  , objectName  => 'pkg_TestModule'
);

(end)

(�������� ����� ����������� ��������� Module_Name ����� 'TestModule',
������������ ����� � ������ 'TestModule.pkg_TestModule')

������ ����� ���� �������� ������� ����������� � ������� �������
<lg_logger_t.setLevel()>. ���������� ���� ������� ������������ ���������
<lg_logger_t::������ �����������>, ����� ����� ������������ ��������� ������
pkg_Logging (<pkg_Logging::������ �����������>). ���� ������ �� ��������
������� �����������, �� �� ��������� ��� �� ���������� ������ � �����������
������� �����������. ��� ������� ������������ ������ ������ �����������
������������ ����� ������� <lg_logger_t.setLevel> �� ��������� NULL. ��������
����� ������ ����� ����������� ������� �����������, �� ��������� ��� "INFO" �
������������ �� � "DEBUG" � �������� ��.

��� ���������� ��������� � ��� ������������ ������ ���� lg_logger_t
(<lg_logger_t::����������� ���������>). ��� ���� ��������� ����������� �������
�����������, ��������������� ������������� ������ (��������, "DEBUG" ���
������������� <lg_logger_t.debug()>) ���� ��������� ���� � ������ �������������
<lg_logger_t.log()>. ��������� ��������� � ���, ���� ������� ��������� ������
��� ����� ������ ������. ��������, ���� ������� ������� ������ "INFO"
(����������� ��� ��������������), �� ��������� ������� "DEBUG", "TRACE" �
���� ����� �� �������������� (�� ����� ���������� � ���). ��������� ���������
������ ��������� ���������� ������ ����� � ������� �������
<lg_logger_t.isEnabledFor()> ���� �� ���������, ��������� � ���������� �������
�����������, �������� <lg_logger_t.isDebugEnabled()>. ��� ���������, ���������
� ���������� ��������� ����������, ������������ �������������� �������
(��. <�������� ����������>).

� �������� ����, � ������� ��������� ���������, ������������ ������� <lg_log>.
������������� � �������� �� ���������� ��������� ��������� ����� ����� �����
dbms_output. � ������� ������� <pkg_Logging.setDestination> ����� �������
������������ ���������� ��� ������ ��������� (��������� ���������
<pkg_Logging.���������� ������>).

������ ��������� ������ � ���������� ����������� �������� � �������
<Test/Example/set-level-destination.sql>:
(code)
...
declare

  procedure f1( step integer)
  is

    logger lg_logger_t := lg_logger_t.getLogger(
      moduleName    => 'TestModule'
      , objectName  => 'f1'
    );

  begin
    logger.debug( 'f1(' || step || '): start...');

    logger.info( 'f1(' || step || '): working...');

    logger.trace( 'f1(' || step || '): finished');
  end f1;

begin

  -- ���������� ������ ���������� ��������� (�������� � �������� �� ��
  -- ���������)
  lg_logger_t.getRootLogger().setLevel( lg_logger_t.getInfoLevelCode());
  f1( 1);

  -- ��������� ������ ���������� ��������� ��� ������ TestModule
  lg_logger_t.getLogger('TestModule')
    .setLevel( lg_logger_t.getDebugLevelCode())
  ;
  f1( 2);

  -- ��������� ������ �������������� ��������� ��� ������ TestModule
  lg_logger_t.getLogger('TestModule')
    .setLevel( lg_logger_t.getTraceLevelCode())
  ;
  -- ����� ���� ��������� ������ ����� dbms_output
  pkg_Logging.setDestination( pkg_Logging.DbmsOutput_DestinationCode);
  f1( 3);

  -- ��������������� ���������� ������ �� ���������
  pkg_Logging.setDestination( null);
end;
...
(end)



group: �������� ����������

��� ��������� ���� ���� ����������� ��������� �������� ����������. � �������
��������� ���������� ����� ����� ���������� �������� ������ ����, ���������
� ���������� ������������� ������� ���� � ������������ ����������. ��������
���������� ����� ���� ��������� ��� �����������. ��� ��������� ����������
�������������� ������� ����������� (�������� context_level �
context_type_level ������� <lg_log>), ��� �������� ���������� ���������
���������� ��������� ��������� �������� ������ (�������� �����) �����������
�������������. ��������� �������� ����������� � ������ ���������� � ���
�������� (context_value_id), ����������� ��� ����� ��������. � ������� Apache
Log4j ����������� ��������� ���������� "Nested Diagnostic Context" ("NDC") �
"Mapped Diagnostic Context" ("MDC"), ��������� �
<https://wiki.apache.org/logging-log4j/NDCvsMDC>.

��� ������������� ��������� ���������� ����� �������� ��� ��������� � �������
������� <lg_logger_t.mergeContextType()> (�������� nestedFlag ����������,
����� �� �������� ��������� ��� ���). ���� �������� ���������� �����
�������������� �������� (��������, � ������� ��������� ������������ ������
������), ����� ��������� ��� � ���� �� ������� ��� ��������� (������ ��������
temporaryFlag ������ 1). � ���� ������ ��� ��������� ����� ������
������������� �� ��������� ������������� �������. ��� �������� ��������� ���
���������� ��������� � ��� (��������, �������� <lg_logger_t.log()>) �����
������� ��� ��������� (� ������� contextTypeShortName �, ��������,
contextTypeModuleId), �������� ��������� (contextValueId) � 1 �� �����
�������� (openContextFlag). ��� �������� ���������� ��������� ����������� ��
�� �������� ���� � �������� ��������� � 0 �� ����� ��������, ��� ��������
������������ �������� �������� ��������� (contextValueId) ����� �� ���������.
���� ������ ��� � �������� ���������, �� �� ������ ���� ��������, ��
���������, ��� � ��������� ��������� ������ ������ ��������� (��������
����������� � ����������� ���� ����������). �������� ���������� ��������� �
������ ������� ������ ��, ��������� �� �������� ��������� ����� ����
������������ � ��������� � ��� ������������� (��������, � ������ ��������
������������� ���������� ��������� ��� ���������� �������� ������������
��������� ���� �� ����). ��� ����������� ����������� ��������� � ����
���������� ��� ������������� ���������� ��������� ��������� ��� ����, � �.�. �
������ ������ ��� ���������. ������ ������������� �������� � �������
<Test/Example/nested-context.sql>.

��� ���������, ��������� � ���������� ���������, ������������ ��������������
������� ��� ������ � ���:
- ��� ������ � ��� ������ ��������� �������������� ��������������� �����
  ��������� �� �������� ����������� ���������� ���������� (���������� ��������
  ������ �����������);
- ���� ���� �������� ��������� �� �������� ��������� ����������, �� �����
  �������� � ��������� �� �������� ����� ��������� ���������� (���������� ��
  ��� ������ �����������);

��� ������� ������������ ������� � ���� ���������� �� ������������ ���������
���������� ��� ���� ��������� � ��� ���������.

��� ������ ������� ������������� ������������� ��������� � ���� ������������
������������� <v_lg_context_change> (������ <Show/context-change.sql>).
��� ��������� ���������� ����������, �������� �� ������ ������������ ���������
������ ����, ����� ������������ ������ <Show/context.sql>. ��� ��������� �����
����, ��������� � ���������� ���������� ����������, ����� ������������ ������
<Show/branch.sql>.



group: ����������� ����� ������

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



