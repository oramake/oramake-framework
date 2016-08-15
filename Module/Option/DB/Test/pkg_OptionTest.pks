create or replace package pkg_OptionTest is
/* package: pkg_OptionTest
  Тестовый пакет модуля.

  SVN root: Oracle/Module/Option
*/



/* group: Функции */

/* pproc: testOptionList
  Тест работы с параметрами с помощью типа <opt_option_list_t>.

  Параметры:
  saveDataFlag                - сохраить тестовые данные в таблицах при
                                успешном завершении теста
                                ( 1 да, 0 нет ( по умолчанию))

  ( <body::testOptionList>)
*/
procedure testOptionList(
  saveDataFlag integer := null
);

/* pproc: testWebApi
  Тест API для web-интерфейса.

  Параметры:
  saveDataFlag                - сохраить тестовые данные в таблицах при
                                успешном завершении теста
                                ( 1 да, 0 нет ( по умолчанию))

  ( <body::testWebApi>)
*/
procedure testWebApi(
  saveDataFlag integer := null
);

end pkg_OptionTest;
/
