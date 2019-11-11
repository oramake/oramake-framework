select 
'alter table ' || table_name || ' add constraint ' || constraint_name || 
 ' foreign key(operator_Id) references op_operator(operator_Id );'
 from document.dba_constraints_copy@extest2t a1 where r_constraint_name = 'OP_OPERATOR_PK'
 and not exists ( select null from dba_constraints a2 where a2.constraint_name = a1.constraint_name )
 
 
 
 alter table DOC_PROPERTY_GROUP add constraint DOC_PROPERTY_GROUP_OPERATOR_FK foreign key(operator_Id) references op_operator(operator_Id );
 select * from Op_operator
 insert into op_operator(operator_id, operator_name_rus, login, password, date_begin, date_finish, date_ins, operator_id_ins,operator_name_eng
 , change_password )
 select operator_id, operator_name_rus, login, password, date_begin, date_finish, date_ins, operator_id_ins,operator_name_eng
 , change_password from document.op_operator@extest2t where operator_id not in ( 1,5)
 
 insert into op_role select * from op_role@extest2
