define packageScript=""

-- Устанавливаем спецификацию только если её не существовало

@oms-default packageScript "' || ( select 'Install/Config/Last/pkg_Scheduler.pks' from dual where not exists ( select 1 from user_objects where object_name = 'PKG_SCHEDULER' and object_type = 'PACKAGE')) || '"

@oms-run "&packageScript"


undefine packageScript
