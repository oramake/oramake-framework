/* proc: dsn_test_t_refresh
  Обертка для процедуры refresh типа <dsn_test_t>, обеспечивающая
  выполнение данной процедуры с правами владельца интерфейсных таблиц
  ( для успешного выполнения из пакетного задания).
*/
create or replace procedure dsn_test_t_refresh(
  forTableName varchar2 := null
  , createMViewFlag integer := null
  , forceCreateMViewFlag integer := null
)
is
begin
  dsn_test_t().refresh(
    forTableName            => forTableName
    , createMViewFlag       => createMViewFlag
    , forceCreateMViewFlag  => forceCreateMViewFlag
  );
end dsn_test_t_refresh;
/
