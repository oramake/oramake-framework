/* ��� � ���� �������
*/
begin
  pkg_logging.logMessage('Hellow World');
end;



/* ���������� ��� � ��� �� ������
��� ����� ������� ��� � ������ output
*/
select
  vl.*
from 
  v_lg_current_log vl
order by
  vl.date_ins
;



/* ��������� ������ � ����������� ��������
*/
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



/* ��������� ����������� ��������� � ��� ������ ���� clob ( textData)
*/
declare

  procedure f( step integer)
  is
    
    testText clob := 'test';
  
    logger lg_logger_t := lg_logger_t.getLogger(
      moduleName    => 'TestModule'
      , objectName  => 'f'
    );

  begin
    logger.debug( 'f(' || step || '): start...');

    logger.info( messageText => 'f(' || step || '): working...'
      , textData => testText);

  end f;

begin
  
  f( 1);

end;



/*����������� �������������� � ������ ��� ������������� �������� ����������
(� ������������ ����� ��������� ����������, �� error �� ���������� ������ ��� ����������)
*/
declare

  procedure f( step integer)
  is
    
    testFlag boolean := false;
  
    logger lg_logger_t := lg_logger_t.getLogger(
      moduleName    => 'TestModule'
      , objectName  => 'f'
    );

  begin
    logger.debug( 'f(' || step || '): start...');

    logger.info( 'f(' || step || '): working...');

    if testFlag = false then
      
      logger.warn( 'f(' || step || '): have warning...');
      
    end if;
  end f;

begin

  f( 1);

end;



/*
*/
declare

  procedure f( step integer)
  is
    
    testFlag boolean := false;
  
    logger lg_logger_t := lg_logger_t.getLogger(
      moduleName    => 'TestModule'
      , objectName  => 'f'
    );

  begin
    logger.debug( 'f(' || step || '): start...');

    logger.info( 'f(' || step || '): working...');

    if logger.isDebugEnabled() then
      
      -- ����� ��������� ��� ��������� �����-���� �������� ���� �������� �����-���� ������� �����������
      dbms_output.put_line('Debug Enabled');
    
    end if;
  end f;

begin

  f( 1);

end;



/*����������� ����� ������
*/

/*������� ����������� ����� ������
*/

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
      , '��������� ������' || lpad( '!', 1000, '_')
    );
  exception when others then
    raise_application_error(
      pkg_Error.ErrorStackInfo
      , lg.errorStack( '������ "Internal"' || lpad( '!', 1000, '_'))
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
      , '��������� ������' || lpad( '!', 1000, '_')
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
      , '��������� ������ ���������' || lpad( '!', 100, '_')
          || '"' || errorMessage || '"'
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

