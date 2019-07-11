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

/* const: Module_SvnRoot
  Путь к корневому каталогу модуля в Subversion.
*/
Module_SvnRoot constant varchar2(100) := 'Oracle/Module/TaskProcessor';

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



/* group: Типы контекста выполнения в логе */

/* const: Task_CtxTpSName
  Тип контекста выполнения "Задание".
  Операции над заданием, в context_value_id указывается Id задания (значение
  поля task_id из таблицы tp_task), в message_label указывается вид операции
  (см. <Метки сообщений об операциях с заданием>).
*/
Task_CtxTpSName constant varchar2(10) := 'TASK';



/* group: Метки сообщений об операциях с заданием
  Значения используются для заполнения поля message_label лога в случае
  открытия контекста <Task_CtxTpSName>.
*/

/* const: Create_TaskMsgLabel
  Метка сообщения для операции "Создание".
*/
Create_TaskMsgLabel constant varchar2(50) := 'CREATE';

/* const: Exec_TaskMsgLabel
  Метка сообщения для операции "Выполнение".
*/
Exec_TaskMsgLabel constant varchar2(50) := 'EXEC';

/* const: Start_TaskMsgLabel
  Метка сообщения для операции "Постановка на выполнение".
*/
Start_TaskMsgLabel constant varchar2(50) := 'START';

/* const: Stop_TaskMsgLabel
  Метка сообщения для операции "Снятие с выполнения".
*/
Stop_TaskMsgLabel constant varchar2(50) := 'STOP';

/* const: Update_TaskMsgLabel
  Метка сообщения для операции "Обновление параметров".
*/
Update_TaskMsgLabel constant varchar2(50) := 'UPDATE';

end pkg_TaskProcessorBase;
/
