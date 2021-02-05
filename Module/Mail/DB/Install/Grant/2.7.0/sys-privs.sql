-- script: Install/Grant/2.7.0/sys-privs.sql
-- Выдает дополнительные права типа "SYS:java.lang.RuntimePermission".
--
-- Параметры:
-- userName                   - имя пользователя, которому выдаются права
--                              ( по умолчанию текущий)
--

define userName = "&1"


declare

  userName varchar2(30) := upper( '&userName');

begin
  dbms_java.grant_permission(
    userName
    , 'SYS:java.lang.RuntimePermission'
    , 'accessClassInPackage.sun.security.x509'
    , ''
  );
  dbms_java.grant_permission(
    userName
    , 'SYS:java.lang.RuntimePermission'
    , 'getClassLoader'
    , ''
  );
  dbms_java.grant_permission(
    userName
    , 'SYS:java.lang.RuntimePermission'
    , 'setFactory'
    , ''
  );
end;
/



undefine userName
