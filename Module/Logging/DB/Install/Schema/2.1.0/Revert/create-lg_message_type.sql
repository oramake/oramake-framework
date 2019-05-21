create table
  lg_message_type
(
  message_type_code               varchar2(10)                        not null
  , message_type_name             varchar2(100)                       not null
  , message_type_name_en          varchar2(100)                       not null
  , date_ins                      date                default sysdate not null
  , constraint lg_message_type_pk primary key
    ( message_type_code)
)
organization index
tablespace &indexTablespace
/



comment on table lg_message_type is
  'Типы сообщений лога [ SVN root: Oracle/Module/Logging]'
/
comment on column lg_message_type.message_type_code is
  'Код типа сообщения'
/
comment on column lg_message_type.message_type_name is
  'Наименование типа сообщения'
/
comment on column lg_message_type.message_type_name_en is
  'Наименование типа сообщения ( анг.)'
/
comment on column lg_message_type.date_ins is
  'Дата добавления записи'
/


insert into
  lg_message_type d
(
  message_type_code
  , message_type_name
  , message_type_name_en
)
select
  trim( substr( t.column_value, 1, 11)) as message_type_code
  , trim( substr( t.column_value, 12, 25)) as message_type_name
  , trim( substr( t.column_value, 37)) as message_type_name_en
from
  table( pkg_Common.split(
'
BFINISH    Завершение пакета        Finish
BMANAGE    Управление пакетом       Manage batch
BSTART     Старт пакета             Start batch
DEBUG      Отладка                  Debug
ERROR      Ошибка                   Error
INFO       Информация               Information
JFINISH    Завершение задания       Finish
JSTART     Старт задания            Start job
WARNING    Предупреждение           Warning
'
    , chr(10)
  )) t
where
  t.column_value is not null
/

commit
/
