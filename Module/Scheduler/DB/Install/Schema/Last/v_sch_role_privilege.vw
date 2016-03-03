-- view: v_sch_role_privilege
-- Права на пакетные задания, выданные ролям тем или иным способом.
--
create or replace force view
  v_sch_role_privilege
as
select
  d.role_id
  , d.privilege_code
  , d.batch_id
  , d.module_id
  , d.batch_role_id
  , d.module_role_privilege_id
  , d.date_ins
  , d.operator_id
from
  (
  select
    br.role_id
    , br.privilege_code
    , br.batch_id
    , cast( null as integer) as module_id
    , br.batch_role_id
    , cast( null as integer) as module_role_privilege_id
    , br.date_ins
    , br.operator_id
  from
    sch_batch_role br
  union all
  select
    mr.role_id
    , mr.privilege_code
    , b.batch_id
    , mr.module_id
    , cast( null as integer) as batch_role_id
    , mr.module_role_privilege_id
    , mr.date_ins
    , mr.operator_id
  from
    sch_batch b
    inner join sch_module_role_privilege mr
      on mr.module_id = b.module_id
  union all
  select
    rl.role_id
    , pr.privilege_code
    , b.batch_id
    , md.module_id
    , cast( null as integer) as batch_role_id
    , cast( null as integer) as module_role_privilege_id
    , cast( null as date) as date_ins
    , cast( null as integer) as operator_id
  from
    op_role rl
    cross join
      (
      select
        max( ov.string_value) as local_role_suffix
      from
        v_opt_option_value ov
      where
        ov.module_svn_root = 'Oracle/Module/Scheduler'
        and ov.object_short_name is null
        -- константа pkg_SchedulerMain.LocalRoleSuffix_OptionSName
        and ov.option_short_name = 'LocalRoleSuffix'
      ) opt
    cross join mod_module md
    cross join sch_privilege pr
    left outer join sch_batch b
      on b.module_id = md.module_id
  where
    rl.short_name in (
        'AllBatchAdmin'
        , 'AdminAllBatch' || opt.local_role_suffix
      )
    or rl.short_name = 'ExecuteAllBatch' || opt.local_role_suffix
      and pr.privilege_code in (
          'READ'
          , 'EXEC'
        )
    or rl.short_name = 'ShowAllBatch' || opt.local_role_suffix
      and pr.privilege_code = 'READ'
  ) d
/



comment on table v_sch_role_privilege is
  'Права на пакетные задания, выданные ролями тем или иным способом [ SVN root: Oracle/Module/Scheduler]'
/
comment on column v_sch_role_privilege.role_id is
  'Id роли'
/
comment on column v_sch_role_privilege.privilege_code is
  'Код привилегии на пакетное задание'
/
comment on column v_sch_role_privilege.batch_id is
  'Id пакетного задания ( null при отсутствии пакетных заданий модуля)'
/
comment on column v_sch_role_privilege.module_id is
  'Id модуля ( если права выданы на любые пакетные задания модуля)'
/
comment on column v_sch_role_privilege.batch_role_id is
  'Id записи в таблице sch_batch_role ( null если права не связаны с этой таблицей)'
/
comment on column v_sch_role_privilege.module_role_privilege_id is
  'Id записи в таблице sch_module_role_privilege ( null если права не связаны с этой таблицей)'
/
comment on column v_sch_role_privilege.date_ins is
  'Дата добавления записи ( null если права не связаны с записью в настроечных таблицах)'
/
comment on column v_sch_role_privilege.operator_id is
  'Id оператора, добавившего запись ( null если права не связаны с записью в настроечных таблицах)'
/
