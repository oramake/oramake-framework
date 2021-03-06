-- Автоматическая разблокировка пользователей
declare
  -- Количество разблокированных операторов
  cnt integer;
begin
  cnt := pkg_AccessOperator.autoUnlockOperator(
    operatorId => pkg_Operator.getCurrentUserId()
  );
  jobResultMessage := 'Разблокировано операторов: ' || to_char( cnt ) || '.';
end;