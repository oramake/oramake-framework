-- script: Install/Grant/3.4.19/public_synonym.sql
-- Выдаёт права на использование объектов модуля всем пользователям БД

create or replace public synonym pkg_Operator for pkg_Operator
/
create or replace public synonym op_operator for op_operator
/
create or replace public synonym op_role for op_role
/
create or replace public synonym op_group for op_group
/