-- script: Install/Grant/Last/grant-common-java-privs.sql
-- ¬ыдает пользователю дополнительные права на уровне Java, не св€занные
-- с отдельными используемыми библиотеками.
--
-- ѕараметры:
-- userName                    - им€ пользовател€, которому выдаютс€ права
--
define userName = "&1"



declare

  userName varchar2( 30) := upper( '&userName');

begin
  dbms_output.put_line(
    'Grant common Java privs to ' || userName || '...'
  );

  -- изменение текущего уровн€ логировани€
  dbms_java.grant_permission(
    userName
    , 'SYS:java.util.logging.LoggingPermission'
    , 'control'
    , ''
  );
end;
/



undefine userName
