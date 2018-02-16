-- view: v_tp_task_type
-- Типы заданий ( интерфейсное представление).
create or replace force view v_tp_task_type
as
select
  -- SVN root: Oracle/Module/TaskProcessor
  t.task_type_id
  , t.module_name
  , t.process_name
  , t.task_type_name_eng
  , t.task_type_name_rus
  , t.exec_command
  , t.file_name_pattern
  , t.access_role_short_name
  , t.task_keep_day
  , t.date_ins
  , t.operator_id
from
  tp_task_type t
/



comment on table v_tp_task_type is
  'Типы заданий ( интерфейсное представление) [ SVN root: Oracle/Module/TaskProcessor]'
/
comment on column v_tp_task_type.task_type_id is
  'Id типа задания'
/
comment on column v_tp_task_type.module_name is
  'Название прикладного модуля'
/
comment on column v_tp_task_type.process_name is
  'Название прикладного процесса, обрабатывающего этот тип задания'
/
comment on column v_tp_task_type.task_type_name_eng is
  'Название типа задания ( анг.)'
/
comment on column v_tp_task_type.task_type_name_rus is
  'Название типа задания ( рус.)'
/
comment on column v_tp_task_type.exec_command is
  'Команда, вызываемая для обработки ( корректный PL/SQL текст, возможно с использованием предопределенных переменных)'
/
comment on column v_tp_task_type.file_name_pattern is
  'Маска имени файла ( для like, экранирующий символ "\") с данными для обработки заданием ( если указана, то для выполнения задания нужно загрузить файл с подходящим именем через интерфейс, иначе файл для задания не используется)'
/
comment on column v_tp_task_type.access_role_short_name is
  'Название роли из модуля AccessOperator, необходимой для доступа к заданиям этого типа'
/
comment on column v_tp_task_type.task_keep_day is
  'Время хранения заданий в днях, по истечении которого неиспользуемые бездействующие задания автоматически удаляются ( по умолчанию неограничено)'
/
comment on column v_tp_task_type.date_ins is
  'Дата добавления записи'
/
comment on column v_tp_task_type.operator_id is
  'Id оператора, добавившего запись'
/
