--trigger: fd_alias_biu_format
--Выполняте форматирование данных при вставке или изменении записи в <fd_alias>.
--Поля alias_name и base_name форматируются с помощью функции
--<pkg_FormatData.FormatName>.
--
create or replace trigger fd_alias_biu_format
  before
    insert
    or update of
      alias_name
      , base_name
  on fd_alias
  for each row
begin
  if :new.base_name is null then
    :new.base_name := pkg_FormatBase.Zero_Value;
  end if;
  :new.alias_name := pkg_FormatData.formatName( :new.alias_name);
  :new.base_name := pkg_FormatData.formatName( :new.base_name);
end;
/
