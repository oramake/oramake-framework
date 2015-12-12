create or replace package pkg_TaskProcessorBase is
/* package: pkg_TaskProcessorBase
  Константы модуля TaskProcessor.

  SVN root: Oracle/Module/TaskProcessor
*/



/* group: Константы */

/* const: Module_Name
  Название модуля, к которому относится пакет.
*/
Module_Name constant varchar2(30) := 'TaskProcessor';

/* group: Роли */

/* const: Administrator_RoleName
  Имя роли, дающей полные права на работу с модулем.
*/
Administrator_RoleName constant varchar2(30) := 'TaskProcessorAdministrator';



/* group: Параметры модуля */

/* const: MaxOpTpTaskExec_OptionSName
  Короткое название параметра
  "Максимальное число одновременно выполняемых заданий одного типа от одного оператора ( по умолчанию без ограничений)"
*/
MaxOpTpTaskExec_OptionSName constant varchar2(50) :=
  'MaxOperatorTypeTaskExecCount'
;



/* group: Результат выполнения */

/* const: True_ResultCode
  Код результата "Положительный результат".
  Задание было успешно выполнено.
*/
True_ResultCode constant varchar2(10) := 'OK';

/* const: False_ResultCode
  Код результата "Отрицательный результат".
  Задание было выполнено без ошибок, но результат не был достигнут.
*/
False_ResultCode constant varchar2(10) := 'FL';

/* const: Error_ResultCode
  Код результата "Ошибка".
  При выполнении задания возникла ошибка.
*/
Error_ResultCode constant varchar2(10) := 'ERR';

/* const: Stop_ResultCode
  Код результата "Остановлено".
  Выполнение задания было остановлено.
*/
Stop_ResultCode constant varchar2(10) := 'STP';

/* const: Abort_ResultCode
  Код результата "Прервано".
  Выполнение задания было прервано.
*/
Abort_ResultCode constant varchar2(10) := 'ABR';



/* group: Состояние заданий */

/* const: Idle_TaskStatusCode
  Код состояния задания "Бездействие".
  Задание ожидает вмешательства пользователя.
*/
Idle_TaskStatusCode constant varchar2(10) := 'I';

/* const: Queued_TaskStatusCode
  Код состояния задания "В очереди".
  Задание в очереди в ожидании запуска.
*/
Queued_TaskStatusCode constant varchar2(10) := 'Q';

/* const: Running_TaskStatusCode
  Код состояния задания "Выполняется".
  Задание выполняется.
*/
Running_TaskStatusCode constant varchar2(10) := 'R';



/* group: Состояния файла */

/* const: Loading_FileStatusCode
  Код состояния файла "Загрузка данных...".
*/
Loading_FileStatusCode constant varchar2(10) := 'LOADING';

/* const: Loaded_FileStatusCode
  Код состояния файла "Данные загружены ( не обработаны)".
*/
Loaded_FileStatusCode constant varchar2(10) := 'LOADED';

/* const: Processing_FileStatusCode
  Код состояния файла "Обработка данных...".
*/
Processing_FileStatusCode constant varchar2(10) := 'PROCESSING';

/* const: Processed_FileStatusCode
  Код состояния файла "Данные обработаны".
*/
Processed_FileStatusCode constant varchar2(10) := 'PROCESSED';

end pkg_TaskProcessorBase;
/
