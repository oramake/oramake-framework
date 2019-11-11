grant all on op_grant_group to exchange;


select
'alter table ' || table_name || ' add constraint ' || constraint_name ||
 ' foreign key(operator_Id) references op_operator(operator_Id );'
 from dba_constraints  a1 where r_constraint_name = 'OP_OPERATOR_PK'

 select * from all_constraints where table_name =  upper('dm_ws_rs_header') and  r_constraint_name = 'OP_OPERATOR_PK'
 drop table dba_constraints_copy
create table dba_constraints_copy as select table_name,constraint_name,r_constraint_name from dba_constraints


grant select any dictionary to developer with admin option;

grant all on dba_constraints_copy to exchange;


