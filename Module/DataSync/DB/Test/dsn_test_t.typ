create or replace type dsn_test_t force
under dsn_data_sync_t
(
/* db object type: dsn_test_t
  Функции для работы с интерфейсными таблицами
  ( прикладной класс, базовый класс dsn_data_sync_t).

  Объект работает с правами вызывающего ( authid current_user, т.к. так
  задано в базовом классе).

  SVN root: Oracle/Module/DataSync
*/



/* group: Функции */

/* pfunc: dsn_test_t
  Конструктор объекта.

  ( <body::dsn_test_t>)
*/
constructor function dsn_test_t
return self as result

)
/
