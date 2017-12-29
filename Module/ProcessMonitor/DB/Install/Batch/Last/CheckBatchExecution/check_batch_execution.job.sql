-- �������� ������������ ���������� �������
-- �������� ������������ ���������� �������.
--
-- WarningTimePercent            - ����� �������������� ( � ���������)
-- WarningTimeHour               - ����� �������������� ( � �����)
-- MinWarningTimeHour            - ����������� ����� �������������� ( � �����)
-- AbortTimeHour                 - ����� ���������� ( � �����)
-- OrakillWaitTimeHour           - ����� ���������� �����
--                                 orakill ( � �����)
-- HandlerWarningTimeHour        - ����� �������������� ��� ������������ (�
--                                 �����)
-- HandlerAbortTimeHour          - ����� ���������� ��� ������������ (� �����)
-- HandlerOrakillTimeHour        - ����� ���������� ����� orakill ���
--                                 ������������ (� �����)
declare
  -- ����� �������������� ( � ���������)
  warningTimePercent number := pkg_Scheduler.getContextInteger(
    'WarningTimePercent', riseException => 1
  );

  -- ����� �������������� ( � �����)
  warningTimeHour number := pkg_Scheduler.getContextInteger(
    'WarningTimeHour', riseException => 1
  );

  -- ����������� ����� �������������� ( � �����)
  minWarningTimeHour number := pkg_Scheduler.getContextInteger(
    'MinWarningTimeHour', riseException => 1
  );

  -- ����� ���������� ( � �����)
  abortTimeHour number := pkg_Scheduler.getContextInteger(
    'AbortTimeHour', riseException => 1
  );

  -- ����� ���������� ����� orakill ( � �����)
  orakillTimeHour number := pkg_Scheduler.getContextInteger(
    'OrakillTimeHour', riseException => 1
  );

  -- ����� �������������� ��� ������������ (� �����)
  handlerWarningTimeHour number := pkg_Scheduler.getContextInteger(
    'HandlerWarningTimeHour', riseException => 1
  );

  -- ����� ���������� ����� orakill ��� ������������ (� �����)
  handlerAbortTimeHour number := pkg_Scheduler.getContextInteger(
    'HandlerAbortTimeHour', riseException => 1
  );

  -- ����� ���������� ����� orakill ��� ������������ (� �����)
  handlerOrakillTimeHour number := pkg_Scheduler.getContextInteger(
    'HandlerOrakillTimeHour', riseException => 1
  );

begin
  pkg_ProcessMonitor.checkBatchExecution(
    warningTimePercent      => warningTimePercent
  , warningTimeHour         => warningTimeHour
  , minWarningTimeHour      => minWarningTimeHour
  , abortTimeHour           => abortTimeHour
  , orakillTimeHour         => orakillTimeHour
  , handlerWarningTimeHour  => handlerWarningTimeHour
  , handlerAbortTimeHour    => handlerAbortTimeHour
  , handlerOrakillTimeHour  => handlerOrakillTimeHour
  );
end;
