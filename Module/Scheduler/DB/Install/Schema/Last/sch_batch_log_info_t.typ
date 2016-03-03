create or replace type
  sch_batch_log_info_t
as object
(
/* db object type: sch_batch_log_info_t
  ���������� �� ���� ���������� ��������� �������.
  ��� ������������ � ������������� <v_sch_batch> ��� ���������� ��������������
  ���������� �������. �������� ���������� � ���������� ���������� �������
  <pkg_Scheduler.findBatch> � ������ ������ � ����������� �������
  �������� ���������� ( ��������, rowCount � operatorId).

  SVN root: Oracle/Module/Scheduler
*/



/* group: ���������� */

/* var: root_log_id
  Id �������� ������ ����, �� �������� �������� ����������
*/
root_log_id                       integer,

/* var: min_log_date
  ����������� ���� ��������� � ����
*/
min_log_date                   date,

/* var: max_log_date
  ������������ ���� ��������� � ����
*/
max_log_date                     date,

/* var: batch_result_id
  Id ���������� ���������� ���������� ������ ( �� ����)
*/
batch_result_id                   integer,

/* var: error_job_count
  ����� �������, ������������� � ������� ��� ��������� ( �������) ����������
  ������
*/
error_job_count                   integer,

/* var: error_count
  ����� ������������� ��������� �� ������� ��� ��������� (�������) ����������
  ������
*/
error_count                       integer,

/* var: warning_count
  ����� ������������� �������������� ��� ��������� (�������) ���������� ������
*/
warning_count                     integer,



/* group: ������� */

/* pfunc: sch_batch_log_info_t
  ������� ������ ������.

  ( <body::sch_batch_log_info_t>)
*/
constructor function sch_batch_log_info_t
return self as result

)
/



-- ��� ������������ � ������������� v_sch_batch, ������� ��� ���������� ������
-- "ORA-01031: insufficient privileges" ��� ������� �� �������������
-- v_sch_batch ��� �������������, �� ���������� ���������� �������������,
-- �� ������� ����� �� ������� �� �������������, ������ ����� ����.
grant execute on sch_batch_log_info_t to public
/
