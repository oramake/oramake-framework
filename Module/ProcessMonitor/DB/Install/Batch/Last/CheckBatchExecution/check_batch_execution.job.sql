-- �������� ������������ ���������� �������
-- �������� ������������ ���������� �������.
-- 
-- WarningTimePercent            - ����� �������������� ( � ���������)
-- WarningTimeHour               - ����� �������������� ( � �����)
-- MinWarningTimeHour            - ����������� ����� �������������� ( � �����)
-- AbortTimeHour                 - ����� ���������� ( � �����)
-- OrakillWaitTimeHour           - ����� ���������� �����
--                                 orakill ( � �����)
declare
  --����� �������������� ( � ���������)
  warningTimePercent number := pkg_Scheduler.getContextInteger(
    'WarningTimePercent', riseException => 1
  );

  --����� �������������� ( � �����)
  warningTimeHour number := pkg_Scheduler.getContextInteger(
    'WarningTimeHour', riseException => 1
  );

  --����������� ����� �������������� ( � �����)
  minWarningTimeHour number := pkg_Scheduler.getContextInteger(
    'MinWarningTimeHour', riseException => 1
  );

  --����� ���������� ( � �����)
  abortTimeHour number := pkg_Scheduler.getContextInteger(
    'AbortTimeHour', riseException => 1
  );

  --����� ���������� ����� orakill ( � �����)
  orakillWaitTimeHour number := pkg_Scheduler.getContextInteger(
    'OrakillWaitTimeHour', riseException => 1
  );

begin
  pkg_ProcessMonitor.checkBatchExecution(
    warningTimePercent => warningTimePercent
    , warningTimeHour => warningTimeHour
    , minWarningTimeHour => minWarningTimeHour
    , abortTimeHour => abortTimeHour
    , orakillWaitTimeHour => orakillWaitTimeHour
  );
end;