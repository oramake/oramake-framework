create or replace package body pkg_Tests
as
/* package body: pkg_TestUtility::body */


/* group: Переменные */


/* ivar: logger
   Логер пакета.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => pkg_TestUtility.Module_Name
  , objectName  => 'pkg_TestUtility'
);


/* group: Функции */


/* proc: testTriggerUpdatePrimaryKey
   Выполняет тест на наличие первичного ключа в триггере на update указанной таблицы
*/
procedure testTriggerUpdatePrimaryKey (
  tableName in varchar2
  )
is
  columnName varchar2(30);
  triggerName varchar2(30);
  
-- testTriggerUpdatePrimaryKey
begin
  pkg_TestUtility.beginTest( 'Check update-triggers to include PK columns of ' || tableName );

  begin
    select cc.column_name
         , t.trigger_name
      into columnName
         , triggerName
      from all_constraints c
     inner join all_cons_columns cc
             on cc.owner           = c.owner
            and cc.table_name      = c.table_name
            and cc.constraint_name = c.constraint_name
     inner join all_triggers t
             on t.table_owner = c.owner
            and t.table_name  = c.table_name
     inner join all_trigger_cols tc
             on tc.trigger_owner = t.owner
            and tc.trigger_name = t.trigger_name
     where c.owner = user
       and c.table_name = tableName
       and c.constraint_type = 'P'
       and t.triggering_event like '%UPDATE%'
       and tc.column_name = cc.column_name
       and regexp_like( tc.column_usage, 'NEW[[:space:]](IN[[:space:]]){0,1}OUT' )
       and rownum <= 1
    ;
  exception
    when no_data_found then
      null;
    when others then
      pkg_TestUtility.failTest( 'EXCEPTION: ' || pkg_Logging.getErrorStack() );
    
  end;
  
  if triggerName is not null then
    pkg_TestUtility.failTest( 'Found PK column ' || columnName || ' in trigger ' || triggerName || '!' );
  end if;

  pkg_TestUtility.endTest();

exception
  when others then
    pkg_TestUtility.failTest( 'EXCEPTION: ' || pkg_Logging.getErrorStack() );

end testTriggerUpdatePrimaryKey;
  


end pkg_Tests;
/
