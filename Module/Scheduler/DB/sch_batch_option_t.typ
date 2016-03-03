create or replace type
  sch_batch_option_t
under opt_option_list_t
(
/* db object type: sch_batch_option_t
  Параметры пакетного задания
  ( основной функционал наследуется от базового класса opt_option_list_t
    модуля Option).

  SVN root: Oracle/Module/Scheduler
*/




/* group: Функции */



/* group: Закрытые объявления */

/* pproc: initialize
  Инициализирует набор параметров пакетного задания.

  Параметры:
  batchShortName              - короткое название пакетного задания
  moduleId                    - Id модуля, к которому относится пакетное задание

  ( <body::initialize>)
*/
member procedure initialize(
  batchShortName varchar2
  , moduleId integer
),



/* group: Конструкторы */

/* pfunc: sch_batch_option_t( BATCH_MODULE)
  Создает объект для набора параметров пакетного задания.

  Параметры:
  batchShortName              - короткое название пакетного задания
  moduleId                    - Id модуля, к которому относится пакетное задание

  ( <body::sch_batch_option_t( BATCH_MODULE)>)
*/
constructor function sch_batch_option_t(
  batchShortName varchar2
  , moduleId integer
)
return self as result,

/* pfunc: sch_batch_option_t( BATCH)
  Создает объект для набора параметров пакетного задания.

  Параметры:
  batchShortName              - короткое название пакетного задания

  Замечания:
  - для успешного выполнения запись с данными пакетного задания должна
    присутствовать в таблице <sch_batch>;

  ( <body::sch_batch_option_t( BATCH)>)
*/
constructor function sch_batch_option_t(
  batchShortName varchar2
)
return self as result,

/* pfunc: sch_batch_option_t( BATCH_ID)
  Создает объект для набора параметров пакетного задания.

  Параметры:
  batchId                     - Id пакетного задания

  Замечания:
  - для успешного выполнения запись с данными пакетного задания должна
    присутствовать в таблице <sch_batch>;

  ( <body::sch_batch_option_t( BATCH_ID)>)
*/
constructor function sch_batch_option_t(
  batchId integer
)
return self as result

)
/
