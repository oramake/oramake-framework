-- Лог сообщение в одну строчку
begin
  lg_logger_t.getRootLogger().info('Hellow World');
end;
/



-- Посмотреть лог в той же сессии
-- Ещё можно увидеть его в выводе output
select
  vl.*
from 
  v_lg_current_log vl
order by
  vl.date_ins
/