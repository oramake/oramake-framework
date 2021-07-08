alter table
  tp_task
add (
  exec_result_string            varchar2(4000)
)
/

comment on column tp_task.exec_result is
  'Результат выполнения в виде числа, возвращенный прикладным обработчиком'
/
comment on column tp_task.exec_result_string is
  'Результат выполнения в виде строки, возвращенный прикладным обработчиком'
/
