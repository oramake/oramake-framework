-- script: Install/Grant/Last/grant_local.sql
-- Выдает права локальному пользователю.

define toUserName = "&1"


GRANT ALL ON op_group TO &toUserName
/
GRANT ALL ON op_group_role TO &toUserName
/
GRANT ALL ON op_operator TO &toUserName
/
GRANT ALL ON op_operator_group TO &toUserName
/
GRANT ALL ON op_operator_role TO &toUserName
/
GRANT ALL ON op_password_hist TO &toUserName
/
GRANT ALL ON op_role TO &toUserName
/
GRANT ALL ON op_login_attempt_group TO &toUserName
/
GRANT ALL ON op_lock_type TO &toUserName
/

GRANT SELECT ON v_op_operator_grant_group TO &toUserName
/
GRANT SELECT ON v_op_operator_grant_role TO &toUserName
/
GRANT SELECT ON v_op_operator_role TO &toUserName
/
GRANT SELECT ON v_op_password_hist TO &toUserName
/
GRANT SELECT ON v_op_login_attempt_group TO &toUserName
/
GRANT SELECT ON v_op_operator TO &toUserName
/
GRANT SELECT ON v_op_operator_to_lock TO &toUserName
/


