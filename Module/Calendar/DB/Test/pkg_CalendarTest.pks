create or replace package pkg_CalendarTest is
/* package: pkg_CalendarTest
  Пакет для тестирования модуля.

  SVN root: Oracle/Module/Calendar
*/



/* group: Функции */

/* pproc: testWebApi
  Тест API для web-интерфейса.

  Параметры:
  saveDataFlag                - сохранить тестовые данные в таблицах при
                                успешном завершении теста
                                ( 1 да, 0 нет ( по умолчанию))

  ( <body::testWebApi>)
*/
procedure testWebApi(
  saveDataFlag integer := null
);

end pkg_CalendarTest;
/
