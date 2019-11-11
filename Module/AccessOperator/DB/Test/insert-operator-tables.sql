insert into OP_OPERATOR_GROUP select * from document.OP_OPERATOR_GROUP@extest2t;
insert into OP_GRANT_GROUP select * from document.OP_GRANT_GROUP@extest2t;

insert into OP_ROLE select * from document.OP_ROLE@extest2t;
insert into OP_OPERATOR_ROLE select * from document.OP_OPERATOR_ROLE@extest2t;

OP_GROUP_ROLE

OP_GROUP

OP_OPERATOR
OP_GRANT_GROUP
