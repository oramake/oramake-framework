create or replace package pkg_DataSyncTest
authid current_user
is
/* package: pkg_DataSyncTest
  Функции тестирования модуля.

  SVN root: Oracle/Module/DataSync
*/



/* group: Функции */

/* pproc: apiTest
  Тестирование API.

  ( <body::apiTest>)
*/
procedure apiTest;

/* pproc: refreshTest
  Тестирование обновления данных.

  Параметры:
  refreshMethod         - метод обновления ( "d" сравнением данных ( по
                          умолчанию), "m" с помощью материализованного
                          представления, "t" сравнением с использованием
                          временной таблицы)

  ( <body::refreshTest>)
*/
procedure refreshTest(
  refreshMethod varchar2
);

end pkg_DataSyncTest;
/
