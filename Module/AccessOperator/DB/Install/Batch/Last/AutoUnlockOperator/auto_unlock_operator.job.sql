-- Автоматическая разблокировка пользователей
declare
  -- Количество разблокированных операторов
  cnt integer;
begin
  cnt := pkg_AccessOperator.autoUnlockOperator();
  jobResultMessage := 'Разблокировано операторов: ' || to_char( cnt ) || '.';
end;