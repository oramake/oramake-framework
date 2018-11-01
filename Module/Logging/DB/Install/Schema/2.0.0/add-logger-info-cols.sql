alter table
  lg_log
add (
  module_name                   varchar2(128)
  , object_name                   varchar2(128)
  , module_id                     integer
)
/

comment on column lg_log.module_name is
  '��� ������, ����������� ������'
/
comment on column lg_log.object_name is
  '��� ������� ������ (������, ����, �������), ����������� ������'
/
comment on column lg_log.module_id is
  'Id ������, ����������� ������ (���� ������� ����������)'
/
comment on column lg_log.parent_log_id is
  '���������� ����: Id ������������ ������ ����'
/
comment on column lg_log.message_type_code is
  '���������� ����: ��� ���� ���������'
/



alter table
  lg_log
add constraint
  lg_log_fk_module_id
foreign key
  ( module_id)
references
  mod_module (
    module_id
  )
enable novalidate
/

@oms-run Install/Schema/add-install-job.sql "validate-lg_log_fk_module_id" "15" "execute immediate ''alter table lg_log enable validate constraint lg_log_fk_module_id'';"
