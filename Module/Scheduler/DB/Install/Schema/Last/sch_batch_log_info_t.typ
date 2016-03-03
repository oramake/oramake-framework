create or replace type
  sch_batch_log_info_t
as object
(
/* db object type: sch_batch_log_info_t
  Информация из лога выполнения пакетного задания.
  Тип используется в представлении <v_sch_batch> для исключения неэффективного
  выполнения запроса. Проблема выражалась в длительном выполнении функции
  <pkg_Scheduler.findBatch> в случае вызова с минимальным набором
  заданных параметров ( например, rowCount и operatorId).

  SVN root: Oracle/Module/Scheduler
*/



/* group: Переменные */

/* var: root_log_id
  Id корневой записи лога, из которого получена информация
*/
root_log_id                       integer,

/* var: min_log_date
  Минимальная дата сообщений в логе
*/
min_log_date                   date,

/* var: max_log_date
  Максимальная дата сообщений в логе
*/
max_log_date                     date,

/* var: batch_result_id
  Id результата последнего выполнения пакета ( из лога)
*/
batch_result_id                   integer,

/* var: error_job_count
  Число заданий, завершившихся с ошибкой при последнем ( текущем) выполнении
  пакета
*/
error_job_count                   integer,

/* var: error_count
  Число логгированных сообщений об ошибках при последнем (текущем) выполнении
  пакета
*/
error_count                       integer,

/* var: warning_count
  Число логгированных предупреждений при последнем (текущем) выполнении пакета
*/
warning_count                     integer,



/* group: Функции */

/* pfunc: sch_batch_log_info_t
  Создает пустой объект.

  ( <body::sch_batch_log_info_t>)
*/
constructor function sch_batch_log_info_t
return self as result

)
/



-- Тип используется в представлении v_sch_batch, поэтому для исключения ошибки
-- "ORA-01031: insufficient privileges" при выборке из представления
-- v_sch_batch под пользователем, не являющимся владельцем представления,
-- но имеющим права на выборку из представления, выдаем права всем.
grant execute on sch_batch_log_info_t to public
/
