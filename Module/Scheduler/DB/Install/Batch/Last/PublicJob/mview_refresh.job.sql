-- Обновление материализованных представлений
-- Обновление материализованных представлений.
--
-- Параметры:
-- MViewList                     - список материализованных представлений
-- MethodList                    - строка кодов методов обновления
-- IsRefreshAfterErrors          - обновлять остальные представления при ошибке
-- IsAtomicRefresh               - выполнять обновление в единой транзакции
declare
                                        --Список представлений
  mviewList varchar2(1000) := pkg_Scheduler.GetContextString(
    'MViewList', riseException => 1
  );

  methodList varchar2(1000) := pkg_Scheduler.GetContextString(
    'MethodList'
  );

  isRefreshAfterErrors integer := pkg_Scheduler.getContextNumber(
    'IsRefreshAfterErrors'
  );

  isAtomicRefresh integer := pkg_Scheduler.getContextNumber(
    'IsAtomicRefresh'
  );

begin
  dbms_mview.refresh(
    list                    => mviewList
    , method                => methodList
    , refresh_after_errors  => coalesce( isRefreshAfterErrors <> 0, false)
    , atomic_refresh        => coalesce( isAtomicRefresh <> 0, true)
  );
end;
