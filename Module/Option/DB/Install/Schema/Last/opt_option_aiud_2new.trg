-- trigger: opt_option_aiud_2new.trg
-- “риггер используетс€ дл€ отражени€ изменений в новых таблицах.
create or replace trigger
  opt_option_aiud_2new
after
  insert
  or update
  or delete
on
  opt_option
for each row
begin
  if updating
      -- провер€ем наличие изменений в любых пол€х кроме option_name
      and (
        :new.option_id != :old.option_id
        or :new.option_short_name != :old.option_short_name
        or :new.is_global != :old.is_global
        or coalesce(
            :new.link_global_local != :old.link_global_local
            , coalesce( :new.link_global_local, :old.link_global_local)
              is not null
          )
        or coalesce(
            :new.mask_id != :old.mask_id
            , coalesce( :new.mask_id, :old.mask_id)
              is not null
          )
          and pkg_OptionMain.getCopyOld2NewChangeFlag() = 1
        or :new.date_ins != :old.date_ins
        or :new.operator_id != :old.operator_id
      )
      then
    raise_application_error(
      pkg_Error.ProcessError
      , '¬ таблице opt_option_value разрешено измен€ть только значение'
        || ' пол€ option_name.'
    );
  end if;
  pkg_OptionMain.onOldAfterRow(
    tableName       => 'OPT_OPTION'
    , statementType =>
        case
          when inserting  then 'INSERT'
          when updating   then 'UPDATE'
          when deleting   then 'DELETE'
        end
    , newRowId            => :new.option_id
    , oldRowId            => :old.option_id
    , oldOptionShortName  => :old.option_short_name
  );
end;
/
