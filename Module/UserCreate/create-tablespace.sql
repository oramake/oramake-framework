define tablespaceName=&1

create tablespace &tablespaceName
datafile '&tablespaceName' size 10M autoextend on maxsize 100M
/

undefine tablespaceName
