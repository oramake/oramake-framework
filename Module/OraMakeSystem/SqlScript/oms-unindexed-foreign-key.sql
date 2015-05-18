-- script: oms-unindexed-foreign-key.sql
-- Выводит список неиндексированных внешних ключей, которые следует
-- проиндексировать
--
-- Замечания:
--   - прикладной скрипт, предназначен для вызова из пользовательских скриптов;
--
prompt * The following foreign keys should be indexed

column parent_table format a30
column child_table format a30
column foreign_key format a30
column column_name format a30

select t.parent_table
     , t.child_table
     , t.foreign_key
     , t.column_name
  from (
         select c.owner
              , p.table_name        as parent_table
              , c.table_name        as child_table
              , c.constraint_name   as foreign_key
              , cc.column_name
              , cc.position
              , cp.column_name      as primary_key_column_name
              , t.trigger_name
              , regexp_replace(
                  upper( t.referencing_names )
                  , '^REFERENCING NEW AS (.+) OLD AS (.+)$', '\1'
                  ) as new_value_ref
           from all_constraints c
          inner join all_cons_columns cc
                  on cc.owner           = c.owner
                 and cc.constraint_name = c.constraint_name
                 and cc.table_name      = c.table_name
          inner join all_constraints p
                  on p.owner           = c.r_owner
                 and p.constraint_name = c.r_constraint_name
          inner join all_cons_columns cp
                  on cp.owner = c.r_owner
                 and cp.constraint_name = c.r_constraint_name
          inner join all_triggers t
                  on t.table_owner = p.owner
                 and t.base_object_type = 'TABLE'
                 and t.table_name = p.table_name
          where c.owner = user
            and c.constraint_type = 'R'
            and instr( t.triggering_event, 'UPDATE' ) > 0
            and instr( t.trigger_type, 'EACH ROW' ) > 0
            and not exists (
                  select 1
                    from all_ind_columns ic
                   where ic.table_owner     = cc.owner
                     and ic.table_name      = cc.table_name
                     and ic.column_name     = cc.column_name
                     and ic.column_position = cc.position
                  )
       ) t
 where regexp_instr(
         (
           select xmltype.createxml(
                    replace(
                      dbms_xmlgen.getXML(
                        'select t.trigger_body
                           from all_triggers t
                          where t.owner = ''' || t.owner || '''
                            and t.trigger_name = ''' || t.trigger_name || ''''
                        )
                      , '<>', '!='
                      )
                    ).extract( '/ROWSET/ROW/TRIGGER_BODY/text()' ).getClobVal()
             from dual
         )
         , '(into[[:space:]/-]+' || ':' || t.new_value_ref || '.' || t.primary_key_column_name || ')'
             || '|'
             || '(:' || t.new_value_ref || '.' || t.primary_key_column_name || '[[:space:]/-]*:=)'
         , 1, 1, 0, 'i'
         ) > 0
 order by t.parent_table
        , t.child_table
        , t.foreign_key
;