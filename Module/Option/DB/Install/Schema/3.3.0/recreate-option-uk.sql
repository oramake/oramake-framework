alter table
  opt_option
drop constraint
  opt_option_uk
drop index
/

alter table
  opt_option
add (
  constraint opt_option_uk unique
    ( module_id, object_short_name, option_short_name, object_type_id)
     using index tablespace &indexTablespace
)
/
