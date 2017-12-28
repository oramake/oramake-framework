-- ѕроверка длительности выполнени€ пакетов
-- ѕроверка длительности выполнени€ пакетов.
--
-- WarningTimePercent            - порог предупреждени€ ( в процентах)
-- WarningTimeHour               - порог предупреждени€ ( в часах)
-- MinWarningTimeHour            - минимальный порог предупреждени€ ( в часах)
-- AbortTimeHour                 - порог прерывани€ ( в часах)
-- OrakillWaitTimeHour           - порог прерывани€ через
--                                 orakill ( в часах)
-- HandlerWarningTimeHour        - порог предупреждени€ дл€ обработчиков (в
--                                 часах)
-- HandlerAbortTimeHour          - порог прерывани€ дл€ обработчиков (в часах)
-- HandlerOrakillTimeHour        - порог прерывани€ через orakill дл€
--                                 обработчиков (в часах)
declare
  -- ѕорог предупреждени€ ( в процентах)
  warningTimePercent number := pkg_Scheduler.getContextInteger(
    'WarningTimePercent', riseException => 1
  );

  -- ѕорог предупреждени€ ( в часах)
  warningTimeHour number := pkg_Scheduler.getContextInteger(
    'WarningTimeHour', riseException => 1
  );

  -- ћинимальный порог предупреждени€ ( в часах)
  minWarningTimeHour number := pkg_Scheduler.getContextInteger(
    'MinWarningTimeHour', riseException => 1
  );

  -- ѕорог прерывани€ ( в часах)
  abortTimeHour number := pkg_Scheduler.getContextInteger(
    'AbortTimeHour', riseException => 1
  );

  -- ѕорог прерывани€ через orakill ( в часах)
  orakillTimeHour number := pkg_Scheduler.getContextInteger(
    'OrakillTimeHour', riseException => 1
  );

  -- ѕорог предупреждени€ дл€ обработчиков (в часах)
  handlerWarningTimeHour number := pkg_Scheduler.getContextInteger(
    'HandlerWarningTimeHour', riseException => 1
  );

  -- ѕорог прерывани€ через orakill дл€ обработчиков (в часах)
  handlerAbortTimeHour number := pkg_Scheduler.getContextInteger(
    'HandlerAbortTimeHour', riseException => 1
  );

  -- ѕорог прерывани€ через orakill дл€ обработчиков (в часах)
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
