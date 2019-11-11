-- script: Install/Grant/3.4.19/public_grant.sql
-- Выдаёт права на использование объектов модуля всем пользователям БД

grant select on op_operator to public
/
grant references on op_operator to public
/

grant select on op_role to public
/
grant references on op_role to public
/

grant select on op_group to public
/
grant references on op_group to public
/

grant execute on pkg_Operator to public
/