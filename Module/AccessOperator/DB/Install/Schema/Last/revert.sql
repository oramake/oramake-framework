-- script: Install/Schema/Last/revert.sql
-- ???????? ????????? ??????, ?????? ????????? ??????? ?????.


-- ??????

drop package pkg_AccessOperator
/
drop package pkg_Operator
/


-- ?????????????

drop view v_op_login_attempt_group
/
drop view v_op_operator_grant_group
/
drop view v_op_operator_grant_role
/
drop view v_op_operator_role
/
drop view v_op_operator_to_lock
/
drop view v_op_operator
/
drop view v_op_password_hist
/
drop view v_op_role
/


-- ??????? ?????

@oms-drop-foreign-key op_group_role
@oms-drop-foreign-key op_group
@oms-drop-foreign-key op_lock_type
@oms-drop-foreign-key op_login_attempt_group
@oms-drop-foreign-key op_operator_group
@oms-drop-foreign-key op_operator_role
@oms-drop-foreign-key op_operator
@oms-drop-foreign-key op_password_hist
@oms-drop-foreign-key op_role


-- ???????

drop table op_group_role
/
drop table op_group
/
drop table op_lock_type
/
drop table op_login_attempt_group
/
drop table op_operator_group
/
drop table op_operator_role
/
drop table op_operator
/
drop table op_password_hist
/
drop table op_role
/



