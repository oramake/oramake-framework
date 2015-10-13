OPTIONS( SKIP=2)
LOAD DATA
REPLACE

INTO TABLE fd_alias
FIELDS 
  TERMINATED BY WHITESPACE
  OPTIONALLY ENCLOSED BY '"'
  TRAILING NULLCOLS
(
  alias_type_code
  , alias_name
  , base_name
  , operator_id "( select t.operator_id from op_operator t where upper( t.login) = upper( :operator_id))"
)
