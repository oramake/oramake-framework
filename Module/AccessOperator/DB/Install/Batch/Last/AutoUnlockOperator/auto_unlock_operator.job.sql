-- јвтоматическа€ разблокировка пользователей
declare
  --  оличество разблокированных операторов
  cnt integer;
begin
  cnt := pkg_AccessOperator.autoUnlockOperator();
  jobResultMessage := '–азблокировано операторов: ' || to_char( cnt ) || '.';
end;