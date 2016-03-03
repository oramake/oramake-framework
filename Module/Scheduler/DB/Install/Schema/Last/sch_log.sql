create synonym
  sch_log
for
  lg_log
/

--index: sch_log_ix_root_batch_date_log
--Индекс для эффективной выборки корневых записей логов запуска и управлнения
--пакетами ( для представления <v_sch_batch_root_log>).
create index sch_log_ix_root_batch_date_log on sch_log (
   case when parent_log_id is null and message_type_code in ( 'BSTART', 'BMANAGE') then message_value end asc,
   case when parent_log_id is null and message_type_code in ( 'BSTART', 'BMANAGE') then date_ins end desc,
   case when parent_log_id is null and message_type_code in ( 'BSTART', 'BMANAGE') then log_id end desc
);
