comment on column opt_object_type.object_type_short_name is
  'Краткое наименование типа объекта ( уникальное в рамках модуля)'
/
comment on column opt_object_type.object_type_name is
  'Наименование типа объекта'
/



comment on column opt_option.object_short_name is
  'Краткое наименование объекта модуля ( уникальное в рамках модуля), к которому относится параметр ( null если не требуется разделения параметров по объектам либо параметр относится ко всему модулю)'
/
comment on column opt_option.option_short_name is
  'Краткое наименование параметра ( уникальное в рамках модуля либо в рамках объекта модуля, если заполнено поле object_short_name)'
/
comment on column opt_option.option_name is
  'Наименование параметра'
/



comment on column opt_option_history.object_short_name is
  'Краткое наименование объекта модуля ( уникальное в рамках модуля), к которому относится параметр ( null если не требуется разделения параметров по объектам либо параметр относится ко всему модулю)'
/
comment on column opt_option_history.option_short_name is
  'Краткое наименование параметра ( уникальное в рамках модуля либо в рамках объекта модуля, если заполнено поле object_short_name)'
/
comment on column opt_option_history.option_name is
  'Наименование параметра'
/



comment on column opt_value_type.value_type_name is
  'Наименование типа значения параметра'
/
