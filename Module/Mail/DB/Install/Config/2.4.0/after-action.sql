
--begin
--  pkg_TaskHandler.sendStopCommand( moduleName => 'SendSms');
--  pkg_TaskHandler.sendStopCommand( moduleName => 'SendSMS');
--end;
--/


@oms-run copy-drop-index.sql

--@oms-reactivate-batch SendSms%

set timing on

@oms-run copy-ml_message.sql
@oms-run copy-create-index.sql

set timing off

@oms-run drop-old-table.sql



