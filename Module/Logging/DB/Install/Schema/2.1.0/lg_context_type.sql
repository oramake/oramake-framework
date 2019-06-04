alter table
  lg_context_type
add (
  temporary_use_date            date
)
/

comment on column lg_context_type.temporary_use_date is
  'Дата последнего использования временного типа контекста (null если тип контекста не является временным). Временный тип контекста удаляется автоматически по истечении определенного срока после его последнего использоваия'
/
