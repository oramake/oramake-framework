create or replace package body $(packageName) is
/* package body: $(packageName)::body */



/* group: Переменные */

/* ivar: logger
  Логер пакета.
*/
logger lg_logger_t := lg_logger_t.getLogger(
  moduleName    => Module_Name
  , objectName  => '$(packageName)'
);



/* group: Функции */



end $(packageName);
/
