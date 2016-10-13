-- Обработчик запросов извлечения писем
--
declare

  checkRequestInterval integer := pkg_Scheduler.getContextNumber(
    'CheckRequestInterval'
  );

  batchShortName varchar2(1024) := pkg_Scheduler.getContextString(
    'BatchShortName'
  );

  maxRequestCount integer := pkg_Scheduler.getContextNumber(
    'MaxRequestCount'
  );

begin
  pkg_MailHandler.fetchHandler(
    checkRequestInterval  => numToDSInterval( checkRequestInterval, 'SECOND')
    , maxRequestCount     => maxRequestCount
    , batchShortName      => batchShortName
  );
end;
