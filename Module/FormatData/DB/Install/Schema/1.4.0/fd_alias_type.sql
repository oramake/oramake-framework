drop trigger
  fd_alias_type_bi_define
/

alter table
  fd_alias_type
drop column
  alias_type_name_eng
/

alter table
  fd_alias_type
drop column
  operator_id
/

alter table
  fd_alias_type
rename column
  alias_type_name_rus
to
  alias_type_name
/

comment on column fd_alias_type.alias_type_name is
  'Название типа синонима'
/
