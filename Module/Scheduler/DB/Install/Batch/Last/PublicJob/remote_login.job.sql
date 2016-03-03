-- Регистрация оператора в удаленной БД
-- Регистрирует текущего оператора в удаленной БД (по линку).
-- 
-- Параметры:
-- 
-- TargetDbLink                  - имя линка к удаленной БД
declare
                                        --Имя файла блокировки
  dbLink varchar2(100) := pkg_Scheduler.GetContextString( 
    'TargetDbLink'
    , 1
  );

begin
  pkg_Operator.RemoteLogin( dbLink);
  jobResultMessage := 'Оператор "' || pkg_Operator.GetCurrentUserName
      || '" зарегистирован в ' || dbLink || '.';
end;
