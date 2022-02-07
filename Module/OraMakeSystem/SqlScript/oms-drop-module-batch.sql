-- script: oms-drop-module-batch.sql
-- Удаляет пакетные задания (Батчи) по названию модуля
--
-- Параметры:
-- moduleName                  - имя модуля у которго удаляются батчи
--

define moduleName = &1

prompt Dropping batches by module name &moduleName ...

declare
  -- Название модуля
  moduleName varchar2(100):= '&moduleName';
  -- Id оператора, выполняющего удаление
  operatorId constant integer := pkg_Operator.GetCurrentUserId();
begin
  pkg_SchedulerLoad.deleteModuleBatch(
    moduleName   => moduleName
  );
exception
  when others
    then
      dbms_output.put_line( 'Exception: [' || sqlerrm || ']' );

end;
/

undefine moduleName
