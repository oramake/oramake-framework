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
  '���� ��������� ���� [ SVN root: Oracle/Module/Logging]'
/
comment on column lg_message_type.message_type_code is
  '��� ���� ���������'
/
comment on column lg_message_type.message_type_name is
  '������������ ���� ���������'
/
comment on column lg_message_type.message_type_name_en is
  '������������ ���� ��������� ( ���.)'
/
comment on column lg_message_type.date_ins is
  '���� ���������� ������'
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
BFINISH    ���������� ������        Finish
BMANAGE    ���������� �������       Manage batch
BSTART     ����� ������             Start batch
DEBUG      �������                  Debug
ERROR      ������                   Error
INFO       ����������               Information
JFINISH    ���������� �������       Finish
JSTART     ����� �������            Start job
WARNING    ��������������           Warning
'
    , chr(10)
  )) t
where
  t.column_value is not null
/

commit
/
