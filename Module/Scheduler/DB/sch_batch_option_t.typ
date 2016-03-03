create or replace type
  sch_batch_option_t
under opt_option_list_t
(
/* db object type: sch_batch_option_t
  ��������� ��������� �������
  ( �������� ���������� ����������� �� �������� ������ opt_option_list_t
    ������ Option).

  SVN root: Oracle/Module/Scheduler
*/




/* group: ������� */



/* group: �������� ���������� */

/* pproc: initialize
  �������������� ����� ���������� ��������� �������.

  ���������:
  batchShortName              - �������� �������� ��������� �������
  moduleId                    - Id ������, � �������� ��������� �������� �������

  ( <body::initialize>)
*/
member procedure initialize(
  batchShortName varchar2
  , moduleId integer
),



/* group: ������������ */

/* pfunc: sch_batch_option_t( BATCH_MODULE)
  ������� ������ ��� ������ ���������� ��������� �������.

  ���������:
  batchShortName              - �������� �������� ��������� �������
  moduleId                    - Id ������, � �������� ��������� �������� �������

  ( <body::sch_batch_option_t( BATCH_MODULE)>)
*/
constructor function sch_batch_option_t(
  batchShortName varchar2
  , moduleId integer
)
return self as result,

/* pfunc: sch_batch_option_t( BATCH)
  ������� ������ ��� ������ ���������� ��������� �������.

  ���������:
  batchShortName              - �������� �������� ��������� �������

  ���������:
  - ��� ��������� ���������� ������ � ������� ��������� ������� ������
    �������������� � ������� <sch_batch>;

  ( <body::sch_batch_option_t( BATCH)>)
*/
constructor function sch_batch_option_t(
  batchShortName varchar2
)
return self as result,

/* pfunc: sch_batch_option_t( BATCH_ID)
  ������� ������ ��� ������ ���������� ��������� �������.

  ���������:
  batchId                     - Id ��������� �������

  ���������:
  - ��� ��������� ���������� ������ � ������� ��������� ������� ������
    �������������� � ������� <sch_batch>;

  ( <body::sch_batch_option_t( BATCH_ID)>)
*/
constructor function sch_batch_option_t(
  batchId integer
)
return self as result

)
/
