--Выдает пользователю права, необходимые для установки и использования
--библиотеки <BouncyCastle>.
--
--Параметры:
--userName                    - имя пользователя, которому выдаются права
--
define userName = "&1"



declare

  userName varchar2( 30) := upper( '&userName');

begin
  dbms_output.put_line(
    'Grant privs for BouncyCastle to ' || userName || '...'
  );
                                        --Права для установки библиотеки
  dbms_java.grant_permission( 
    userName
    , 'oracle.aurora.security.JServerPermission'
    , 'LoadClassInPackage.java.security.*'
    , null
  );
  dbms_java.grant_permission(
    userName
    , 'SYS:java.security.SecurityPermission'
    , 'putProviderProperty.BC'
    , ''
  );
  dbms_java.grant_permission(
    userName
    , 'SYS:java.security.SecurityPermission'
    , 'insertProvider.BC'
    , ''
  );
end;
/



undefine userName
