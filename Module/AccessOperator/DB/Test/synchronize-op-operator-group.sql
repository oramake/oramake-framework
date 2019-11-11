select * from document.v_op_operator_role@extest2t ;

select * from
(
  select
    ogr.operator_id
    , grr.role_id
    , ogr.group_id as source_group_id
    , ogr.date_ins
    , ogr.operator_id_ins
  from
    op_operator_group ogr
    inner join op_group gr
      on gr.group_id = ogr.group_id
    inner join op_group_role grr
      on grr.group_id = ogr.group_id
  where
    gr.is_grant_only = 0
) where operator_Id = 4;    
