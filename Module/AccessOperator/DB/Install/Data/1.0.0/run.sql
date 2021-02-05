-- временно отключаем FK из-за циклической зависимости между таблицами
alter table op_operator disable constraint op_operator_fk_log_attmpt_grp
/

@oms-run op_operator.sql
@oms-run op_lock_type.sql
@oms-run op_login_attempt_group.sql

alter table op_operator enable constraint op_operator_fk_log_attmpt_grp
/


@oms-run op_group.sql
@oms-run op_role.sql
