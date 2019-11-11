set feedback off

begin
  pkg_SchedulerTest.testBatchOperation(
    testCaseNumber => '&testCaseNumber'
    , saveDataFlag => '&saveDataFlag'
  );
end;
/

set feedback on
