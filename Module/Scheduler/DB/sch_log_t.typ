@oms-drop-type sch_log_t

/* dbtype: sch_log_t
*/
create or replace type
  sch_log_t
as object
(
  log_id integer
  , parent_log_id integer
  , message_type_code varchar2(10)
  , message_value number
  , message_text varchar2(4000)
  , log_level integer
  , date_ins date
  , operator_id integer
)
/
