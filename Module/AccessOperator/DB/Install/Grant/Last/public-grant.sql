-- script: Install/Grant/Last/public_grant.sql
-- Выдаёт права на использование объектов модуля всем пользователям БД


prompt select on op_operator to public

grant select on op_operator to public
/

prompt references on op_operator to public

grant references on op_operator to public
/


prompt select on op_role to public

grant select on op_role to public
/

prompt references on op_role to public

grant references on op_role to public
/


prompt select on op_group to public

grant select on op_group to public
/

prompt references on op_group to public

grant references on op_group to public
/


prompt select on v_op_operator_role to public

grant select on v_op_operator_role to public
/


prompt execute on pkg_Operator to public

grant execute on pkg_Operator to public
/



prompt create or replace public synonym op_operator for op_operator

create or replace public synonym op_operator for op_operator
/


prompt create or replace public synonym op_role for op_role

create or replace public synonym op_role for op_role
/


prompt create or replace public synonym op_group for op_group

create or replace public synonym op_group for op_group
/


prompt create or replace public synonym v_op_operator_role for v_op_operator_role

create or replace public synonym v_op_operator_role for v_op_operator_role
/


prompt create or replace public synonym pkg_Operator for pkg_Operator

create or replace public synonym pkg_Operator for pkg_Operator
/


