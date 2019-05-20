alter table
  lg_level
drop constraint
  lg_level_uk_message_level_code
drop index
/

alter table
  lg_level
drop (
    message_level_code
    , level_name
  )
/
