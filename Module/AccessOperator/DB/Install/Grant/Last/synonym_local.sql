-- script: Install/Grant/Last/synonym_local.sql
-- Создает сининимы для локального пользователя
-- Для запуска скрипта пользователь должен обладать
-- привилегией "create any synonym"

define toUserName = "&1"

create or replace synonym &toUserName..op_group_role
for op_group_role
/
create or replace synonym &toUserName..op_operator_group
for op_operator_group
/
create or replace synonym &toUserName..op_operator_role
for op_operator_role
/
create or replace synonym &toUserName..op_password_hist
for op_password_hist
/
create or replace synonym &toUserName..op_login_attempt_group
for op_login_attempt_group
/
create or replace synonym &toUserName..op_lock_type
for op_lock_type
/
create or replace synonym &toUserName..v_op_operator_grant_group
for v_op_operator_grant_group
/
create or replace synonym &toUserName..v_op_operator_grant_role
for v_op_operator_grant_role
/
create or replace synonym &toUserName..v_op_operator_role
for v_op_operator_role
/
create or replace synonym &toUserName..v_op_password_hist
for v_op_password_hist
/
create or replace synonym &toUserName..v_op_login_attempt_group
for v_op_login_attempt_group
/
create or replace synonym &toUserName..v_op_operator
for v_op_operator
/
create or replace synonym &toUserName..v_op_operator_to_lock
for v_op_operator_to_lock
/
